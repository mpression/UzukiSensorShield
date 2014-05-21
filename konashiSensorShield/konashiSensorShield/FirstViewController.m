//
//  FirstViewController.m
//  konashiSensorShield
//
//  Created by Kenji Ohno on 2014/03/28.
//  Copyright (c) 2014年 Macnica. All rights reserved.
//

#import "FirstViewController.h"
#import "Konashi.h"


@interface FirstViewController ()

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
    //[Konashi pinModeAll:0b00001110];
    [Konashi i2cMode:KONASHI_I2C_ENABLE];
    
    //flash device's LED
    [Konashi digitalWrite:PIO0 value:HIGH];
    [NSThread sleepForTimeInterval:0.2];
    [Konashi digitalWrite:PIO0 value:LOW];
    [Konashi digitalWrite:PIO1 value:HIGH];
    [NSThread sleepForTimeInterval:0.2];
    [Konashi digitalWrite:PIO1 value:LOW];
    [Konashi digitalWrite:PIO2 value:HIGH];
    [NSThread sleepForTimeInterval:0.2];
    [Konashi digitalWrite:PIO2 value:LOW];
    
    [self startCheckSensor];
}

#pragma mark - Konashi Input Control

- (void)startCheckSensor
{
    unsigned char data[2];
    NSLog(@"Start check sensor.");
    
    //***********************************************************
    // Si114x Ambient Light / UV Index / Proximity Sensor Setting
    //***********************************************************
    //initialize: wait for 25ms or more.
    [NSThread sleepForTimeInterval:0.1];
    
    
    // HW_KEYレジスタに0x17をWR　→オペレーション開始
    konashiSuccess = [Konashi i2cStartCondition];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    data[0] = REG_HW_KEY;
    data[1] = REG_HW_KEY_VALUE;
    konashiSuccess = [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    //[NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    konashiSuccess = [Konashi i2cStopCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    
    // REG_COEF0-3レジスタにSiLabs指定の補正値をWR
    [Konashi i2cStartCondition];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    data[0] = REG_COEF0;
    data[1] = REG_COEF0_VALUE;
    konashiSuccess = [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    konashiSuccess = [Konashi i2cStopCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    
    konashiSuccess = [Konashi i2cStartCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    data[0] = REG_COEF1;
    data[1] = REG_COEF1_VALUE;
    konashiSuccess = [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    konashiSuccess = [Konashi i2cStopCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    
    konashiSuccess = [Konashi i2cStartCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    data[0] = REG_COEF2;
    data[1] = REG_COEF2_VALUE;
    konashiSuccess = [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    konashiSuccess = [Konashi i2cStopCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    
    konashiSuccess = [Konashi i2cStartCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    data[0] = REG_COEF3;
    data[1] = REG_COEF3_VALUE;
    konashiSuccess = [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    konashiSuccess = [Konashi i2cStopCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL_LONG];
    
    //*****************************************************
    // Si7013 Temperature / Related Humidity Sensor Setting
    //*****************************************************
    
    konashiSuccess = [Konashi i2cStartCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    data[0] = REG_PARAM_WR; //パラメータレジスタに書き込む値をセットするレジスタ
    data[1] = EN_UV | EN_ALS_IR | EN_ALS_VIS; //パラメータレジスタに書き込む値
    konashiSuccess = [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    konashiSuccess = [Konashi i2cStopCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    
    konashiSuccess = [Konashi i2cStartCondition];
    //[NSThread sleepForTimeInterval:0.1];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    data[0] = REG_COMMAND;
    data[1] = 0xA0 | PARAM_CH_LIST; // 0xA0 is the PARAM_SET cmd.
    konashiSuccess = [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    konashiSuccess = [Konashi i2cStopCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL_LONG];
    
    //*****************************************************
    // ADXL345 Accelerometer Setting
    //*****************************************************
    
    
    //initialize
    //Sensor Event Handler
    [Konashi addObserver:self selector:@selector(readSensor) name:KONASHI_EVENT_I2C_READ_COMPLETE];
    checkSensorTimer = [NSTimer scheduledTimerWithTimeInterval:CHECK_SENSOR_INTERVAL
                                                        target:self
                                                      selector:@selector(checkSensor:)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (void)stopCheckSensor
{
    [Konashi removeObserver:self];
    if([checkSensorTimer isValid]) [checkSensorTimer invalidate];
    //[self resetParameterDisplay];
    //[self hideParameterDisplay];
}

//TODO: to check the Relative Humidity Sensor and the Temperature Sensor on the I2C bus.
- (void)checkSensor:(NSTimer *)timer
{
    unsigned char data[2];
    
    switch (count){
            
        case 0:
            // Sequence to Start a Relative Humidity Conversion
            [Konashi i2cStartCondition];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            data[0] = 0xE5;
            konashiSuccess = [Konashi i2cWrite:1 data:data address:HUMID_TEMP_SENSOR_ADDRESS];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            konashiSuccess = [Konashi i2cRestartCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            konashiSuccess = [Konashi i2cReadRequest:3 address:HUMID_TEMP_SENSOR_ADDRESS];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL_LONG];
            break;
            
        case 1:
            // Sequence to Start a Temperature Conversion
            [Konashi i2cStartCondition];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            data[0] = 0xE0;
            konashiSuccess = [Konashi i2cWrite:1 data:data address:HUMID_TEMP_SENSOR_ADDRESS];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            konashiSuccess = [Konashi i2cRestartCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            konashiSuccess = [Konashi i2cReadRequest:3 address:HUMID_TEMP_SENSOR_ADDRESS];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL_LONG];
            break;
            
        case 2:
            // Sequence to Start a Ambient Light Conversion
            konashiSuccess = [Konashi i2cStartCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            
            
            data[0] = REG_COMMAND;
            data[1] = ALS_FORCE; // Enter ALS Force Mode.
            //data[1] = ALS_AUTO;   // Enter ALS Autonomous Mode.
            konashiSuccess = [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            konashiSuccess = [Konashi i2cStopCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            
            konashiSuccess = [Konashi i2cStartCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            
            
            //data[0] = 0x00; // Part ID : 0x45 for Si1145
            //data[0] = REG_UVI_DATA0;
            data[0] = REG_ALS_VIS_DATA0;
            konashiSuccess = [Konashi i2cWrite:1 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            konashiSuccess = [Konashi i2cRestartCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            
            konashiSuccess = [Konashi i2cReadRequest:2 address:PROX_LIGHT_UV_SENSOR_ADDRESS];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL_LONG];
            break;
            
        case 3:
            // Sequence to Start a Accerelometer Conversion
            
            konashiSuccess = [Konashi i2cStartCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            
            data[0] = 0x31; // DATA FORMAT REGISTER
            data[1] = 0x0B; // Set Full Resolution, +/- 16g
            konashiSuccess = [Konashi i2cWrite:2 data:data address:ACC_SENSOR_ADDRESS];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            konashiSuccess = [Konashi i2cStopCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
 
            konashiSuccess = [Konashi i2cStartCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            
            data[0] = 0x2D; // POWER CONTROL REGISTER
            data[1] = 0x08; // Set to Measure Mode
            konashiSuccess = [Konashi i2cWrite:2 data:data address:ACC_SENSOR_ADDRESS];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            konashiSuccess = [Konashi i2cStopCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];

            konashiSuccess = [Konashi i2cStartCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            
            data[0] = 0x24; // THRESHOLD ACTIVE : 6.25mg/LSB
            data[1] = 0x20; // 2.0g
            //data[1] = 0x10;   // 1.0g
            //data[1] = 0x08;   // 0.5g
            konashiSuccess = [Konashi i2cWrite:2 data:data address:ACC_SENSOR_ADDRESS];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            konashiSuccess = [Konashi i2cStopCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];

            konashiSuccess = [Konashi i2cStartCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            
            data[0] = 0x27; // ACTIVE/INACTIVE CONTROL REGISTER
            data[1] = 0xF0; // D7 : 1 : Act AC Coupling
            // D6 : 1 : Act_X Enable
            // D5 : 1 : Act_Y Enable
            // D4 : 1 : Act_Z Enable
            // D3 : 0 : Inact DC Coupling
            // D2 : 0 : Inact_X Disable
            // D1 : 0 : Inact_Y Disable
            // D0 : 0 : Inact_Z Disable
            konashiSuccess = [Konashi i2cWrite:2 data:data address:ACC_SENSOR_ADDRESS];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            konashiSuccess = [Konashi i2cStopCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            
            konashiSuccess = [Konashi i2cStartCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            
            data[0] = 0x2E; // Int Enable
            data[1] = 0x10; // Enable only Activity
            konashiSuccess = [Konashi i2cWrite:2 data:data address:ACC_SENSOR_ADDRESS];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL_LONG];
            konashiSuccess = [Konashi i2cStopCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            
            konashiSuccess = [Konashi i2cStartCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            
            data[0] = 0x30; // Int Source Register
            //data[0] = 0x32; // data_x lo
            konashiSuccess = [Konashi i2cWrite:1 data:data address:ACC_SENSOR_ADDRESS];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            konashiSuccess = [Konashi i2cRestartCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            
            konashiSuccess = [Konashi i2cReadRequest:1 address:ACC_SENSOR_ADDRESS];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL_LONG];
            
    }
}

- (void)readSensor // Read RH & Temperature
{
    unsigned char data[3];
    
    switch (count){
        case 0:
            // Read RH
            konashiSuccess = [Konashi i2cRead:3 data:data];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            konashiSuccess = [Konashi i2cStopCondition];
            if (konashiSuccess) [Konashi reset];
        
            //NSLog(@"RH:%X,%X", data[0], data[1]);
        
            rh = (double) ((unsigned short)(data[0] << 8 ^ data[1])) * 125.0 / 65536.0 - 6.0;
        
            _rhLabel.text = [NSString stringWithFormat:@"%.1f", rh];
        
            NSLog(@"RH: %f", rh);
            NSLog(@" ");
            
            //_silabsLogo.hidden = NO;
            _rhLabel.hidden = NO;
            _rhUnit.hidden = NO;
            count++;
            break;
    
        case 1:
            // Read Temp.
            konashiSuccess = [Konashi i2cRead:3 data:data];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            konashiSuccess = [Konashi i2cStopCondition];
            if (konashiSuccess) [Konashi reset];
        
            //NSLog(@"Temp:%X,%X", data[0], data[1]);
        
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
            
        case 2:
            //unsigned char data[2];
            konashiSuccess = [Konashi i2cRead:2 data:data];
            //NSLog(@"Konashi %d", konashiSuccess);
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            
            NSLog(@"UVI_HL:%X,%X", data[1], data[0]);
            
            int uvi = (int) ( (double) ((unsigned short)(data[1] << 8 | data[0])) / 100.0);
            
            _ambientLight.text = [NSString stringWithFormat:@"%d", uvi];
            
            NSLog(@"UVI: %d", uvi);
            NSLog(@" ");
            
            //_silabsLogo.hidden = NO;
            _ambientLight.hidden = NO;
            
            konashiSuccess = [Konashi i2cStopCondition];
            //NSLog(@"Konashi %d", konashiSuccess);
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            
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
            konashiSuccess = [Konashi i2cRead:1 data:data];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
            
            NSLog(@"SHOCKED:%X", data[0]);
            
            konashiSuccess = [Konashi i2cStopCondition];
            if (konashiSuccess) [Konashi reset];
            [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
  
            if (data[0]== 0x93){

                _stopAlarm.hidden = false;
                _weatherImage.hidden = true;
                
                CFBundleRef mainBundle;
                mainBundle = CFBundleGetMainBundle();
                soundURL = CFBundleCopyResourceURL(mainBundle, CFSTR("Fire_Alarm"),CFSTR("mp3"),NULL);
                AudioServicesCreateSystemSoundID(soundURL, &soundID);
                CFRelease(soundURL);
                AudioServicesPlaySystemSound(soundID);
                
            }



            count=0;
            break;
    }
}
@end
