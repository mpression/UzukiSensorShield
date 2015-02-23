//
//  FirstViewController.m
//  konashiSensorShield
//
//  Created by Kenji Ohno on 2014/03/28.
//  Copyright (c) 2014年 Macnica. All rights reserved.
//

#import "FirstViewController.h"
#import "Konashi.h"
#import "konashiInterface.h"
#import "Adxl345.h"
#import "Si114x.h"
#import "Si7013.h"



@interface FirstViewController ()

@property (strong, nonatomic) Bluetooth *ble;   //KONASHI接続オブジェクト

@end

@implementation FirstViewController

NSTimer *checkSensorTimer;
int     count=0;
int     konashiSuccess;

double rh;
double temp;
double dcindex;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _stopAlarm.hidden = true;
    [Konashi initialize];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Konashi-iPhone Pairing

- (IBAction)tapDevicePairing:(id)sender
{
    if(![Konashi isConnected])
    {
        [Konashi addObserver:self selector:@selector(konashiNotFound) name:KONASHI_EVENT_KONASHI_NOT_FOUND];
        [Konashi addObserver:self selector:@selector(konashiIsReady) name:KONASHI_EVENT_READY];
        [Konashi addObserver:self selector:@selector(konashiFindCanceled) name:KONASHI_EVENT_CANCEL_KONASHI_FIND];
        [Konashi find];
    }
    else
    {
        [Konashi addObserver:self selector:@selector(konashiIsDisconnected) name:KONASHI_EVENT_DISCONNECTED];
        [Konashi disconnect];
        //_silabsLogo.hidden = NO;
    }
}

- (IBAction)stopAlarm:(id)sender {
    _stopAlarm.hidden = true;
    _weatherImage.hidden = false;
    AudioServicesDisposeSystemSoundID(soundID);
}

- (void)konashiNotFound
{
    [Konashi removeObserver:self];
}

- (void)konashiFindCanceled
{
    [Konashi removeObserver:self];
}

- (void)konashiIsDisconnected
{
    [Konashi removeObserver:self];
    
    [_devicePairingButton setTitle:@"Connect" forState:UIControlStateNormal];
    //[[_devicePairingButton layer] setBackgroundColor:[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] CGColor]];
    
    [self stopCheckSensor];
}

- (void)konashiIsReady
{
    [Konashi removeObserver:self];
    [_devicePairingButton setTitle:@"Disconnect" forState:UIControlStateNormal];

    
    //Konash I/O setting
    [Konashi pinModeAll:0b11111110];
    [Konashi i2cMode:KONASHI_I2C_ENABLE];
    
    //flash device's LED
    [Konashi digitalWrite:PIO1 value:HIGH];
    [NSThread sleepForTimeInterval:0.1];
    [Konashi digitalWrite:PIO1 value:LOW];
    [Konashi digitalWrite:PIO2 value:HIGH];
    [NSThread sleepForTimeInterval:0.1];
    [Konashi digitalWrite:PIO2 value:LOW];
    [Konashi digitalWrite:PIO3 value:HIGH];
    [NSThread sleepForTimeInterval:0.1];
    [Konashi digitalWrite:PIO3 value:LOW];
    [Konashi digitalWrite:PIO4 value:HIGH];
    [NSThread sleepForTimeInterval:0.2];
    [Konashi digitalWrite:PIO4 value:LOW];
    
    [self startCheckSensor];
}

#pragma mark - Konashi Input Control

//***********************************************************
// Initialize Sensors
//***********************************************************

- (void)startCheckSensor
{
    NSLog(@"Start check sensor.");

    [Si114x setup];
    [Adxl345 setup];
    //[Si7013 initialize];

    //Sensor Event Handler
    [Konashi addObserver:self selector:@selector(readSensor) name:KONASHI_EVENT_I2C_READ_COMPLETE];
    checkSensorTimer = [NSTimer scheduledTimerWithTimeInterval:CHECK_SENSOR_INTERVAL
                                                        target:self
                                                      selector:@selector(checkSensor:)
                                                      userInfo:nil
                                                       repeats:YES];
}

//***********************************************************
// Initialize Sensors
//***********************************************************
- (void)stopCheckSensor
{
    [Konashi removeObserver:self];
    if([checkSensorTimer isValid]) [checkSensorTimer invalidate];
}

//***********************************************************
// Sensor Conversion
//***********************************************************
- (void)checkSensor:(NSTimer *)timer
{
    
    switch (count){
            
        case 0:
            [Si7013 checkHumidity];
            break;
            
        case 1:
            [Si7013 checkTemperature];
            break;
            
        case 2:
            [Si114x chkAmbientLight];
            break;
            
        case 3:
            [Adxl345 chkAcceleration];
            
    }
}

- (void)readSensor // Read RH & Temperature
{
    unsigned char data[7];
    
    switch (count){
            
        case 0: // Read Related Humidity
            
            [Konashi i2cRead:3 data:data];
            [Konashi i2cStopCondition];
            
            rh = (double) ((unsigned short)(data[0] << 8 ^ data[1])) * 125.0 / 65536.0 - 6.0;
        
            _rhLabel.text = [NSString stringWithFormat:@"%.1f", rh];
        
            NSLog(@"RH: %f", rh);
            NSLog(@" ");
            
            //_silabsLogo.hidden = NO;
            _rhLabel.hidden = NO;
            _rhUnit.hidden = NO;
            count++;
            break;
    
        case 1: // Read Temperature
            
            [Konashi i2cRead:3 data:data];
            [Konashi i2cStopCondition];
            
            temp = (double) ((unsigned short)(data[0] << 8 ^ data[1])) * 175.72 / 65536.0 - 46.85;
        
            _tempUnit.hidden = NO;
            _tempLabel.text = [NSString stringWithFormat:@"%.1f", temp];
        
            NSLog(@"Temp:%f", temp);
            NSLog(@" ");
            
            //_silabsLogo.hidden = YES;
            _tempLabel.hidden = NO;
        
            // 不快指数(Discomfort Index)の計算
            // 0.81T+0.01RH(0.99T-14.3)+46.3
            
            int dcindex = 0.81 * temp + 0.01 * rh * ( 0.99 * temp - 14.3 ) + 46.3;
            _dciLabel.text = [NSString stringWithFormat:@"%d", dcindex];
            
            NSLog(@"DCI:%d", dcindex);
            NSLog(@" ");
            
            _dciTitle.hidden = NO;
        
            if (dcindex<55){ // 寒い
                _dciLabel.textColor = [UIColor cyanColor];
                _dciTitle.textColor = [UIColor cyanColor];
            }
            else if(dcindex>=55 && dcindex<60){ // 肌寒い
                _dciLabel.textColor = [UIColor blueColor];
                _dciTitle.textColor = [UIColor blueColor];
            }
            else if(dcindex>=60 && dcindex<65) { // 何も感じない
                _dciLabel.textColor = [UIColor greenColor];
                _dciTitle.textColor = [UIColor greenColor];
            }
            else if (dcindex>=65 && dcindex<70) { // 快い
                _dciLabel.textColor = [UIColor greenColor];
                _dciTitle.textColor = [UIColor greenColor];
            }
            else if (dcindex>=70 && dcindex<75) { // 暑くない
                _dciLabel.textColor = [UIColor yellowColor];
                _dciTitle.textColor = [UIColor yellowColor];
            }
            else if (dcindex>=75 && dcindex<80) { // やや暑い
                _dciLabel.textColor = [UIColor orangeColor];
                _dciTitle.textColor = [UIColor orangeColor];
            }
            else if (dcindex>=80 && dcindex<85) { // 暑くて汗がでる
                _dciLabel.textColor = [UIColor redColor];
                _dciTitle.textColor = [UIColor redColor];
            }
            else{ // 暑くてたまらない
                _dciLabel.textColor = [UIColor purpleColor];
                _dciTitle.textColor = [UIColor purpleColor];
            }
            count++;
            break;
            
        case 2: // Read Ambient Light
            
            [Konashi i2cRead:2 data:data];
            
            NSLog(@"UVI_HL:%X,%X", data[1], data[0]);
            
            int uvi = (int) ( (double) ((unsigned short)(data[1] << 8 | data[0])) / 100.0);
            
            _ambientLight.text = [NSString stringWithFormat:@"%d", uvi];
            
            NSLog(@"UVI: %d", uvi);
            NSLog(@" ");
            
            //_silabsLogo.hidden = NO;
            _ambientLight.hidden = NO;
            
            [Konashi i2cStopCondition];
            
            if (uvi<4){ // 曇り
                NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"weather_ca_005" ofType:@"png"];
                _weatherImage.image = [UIImage imageWithContentsOfFile:imagePath];
            }
            else if(uvi>=4 && uvi<10){ // 曇り・晴れ
                NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"weather_ca_007" ofType:@"png"];
                _weatherImage.image = [UIImage imageWithContentsOfFile:imagePath];
            }
            else if(uvi>=10 && uvi<30) { // 晴れ
                NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"weather_ca_001" ofType:@"png"];
                _weatherImage.image = [UIImage imageWithContentsOfFile:imagePath];
            }
            else{ // 快晴
                NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"weather_ca_003" ofType:@"png"];
                _weatherImage.image = [UIImage imageWithContentsOfFile:imagePath];
            }

            count++;
            break;
            
        case 3:
            /*
            [Konashi i2cRead:1 data:data];
            
            NSLog(@"SHOCKED:%X", data[0]);
            
            [Konashi i2cStopCondition];
  
            if (data[0]== 0x93){

                _stopAlarm.hidden = false;
                //_weatherImage.hidden = true;
                
                CFBundleRef mainBundle;
                mainBundle = CFBundleGetMainBundle();
                soundURL = CFBundleCopyResourceURL(mainBundle, CFSTR("Fire_Alarm"),CFSTR("mp3"),NULL);
                AudioServicesCreateSystemSoundID(soundURL, &soundID);
                CFRelease(soundURL);
                AudioServicesPlaySystemSound(soundID);
             
             */
            
            // Read Acceleration xyz-Axis
            [Konashi i2cRead:6 data:data];
            
            double ax =  (double)(((signed short) ((unsigned short)data[1]<<8 ^ data[0]))) / 256.0;//16384.0;
            double ay =  (double)(((signed short) ((unsigned short)data[3]<<8 ^ data[2]))) / 256.0;//16384.0;
            double az =  (double)(((signed short) ((unsigned short)data[5]<<8 ^ data[4]))) / 256.0;//16384.0;
            
            _ax.text = [NSString stringWithFormat:@"%f", ax];
            _ay.text = [NSString stringWithFormat:@"%f", ay];
            _az.text = [NSString stringWithFormat:@"%f", az];

            float value = sqrt(ax * ax + ay * ay + az * az);

            count=0;

    }
}
@end
