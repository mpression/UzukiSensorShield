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
bool    count;
int     konashiSuccess;

double rh;
double temp;
double dcindex;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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
    
    NSLog(@"Start check sensor.");
    
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
    
    if (!count) {
        
        // Sequence to Start a Relative Humidity Conversion
        [Konashi i2cStartCondition];
        [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
        data[0] = 0xE5;
        konashiSuccess = [Konashi i2cWrite:1 data:data address:HUMID_TEMP_SENSOR_ADDRESS];
        NSLog(@"Konashi %d", konashiSuccess);
        if (konashiSuccess) [Konashi reset];
        [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
        konashiSuccess = [Konashi i2cRestartCondition];
        NSLog(@"Konashi %d", konashiSuccess);
        if (konashiSuccess) [Konashi reset];
        [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
        konashiSuccess = [Konashi i2cReadRequest:3 address:HUMID_TEMP_SENSOR_ADDRESS];
        NSLog(@"Konashi %d", konashiSuccess);
        if (konashiSuccess) [Konashi reset];
        [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL_LONG];
        count = !count;
    }
    else{
        // Sequence to Start a Temperature Conversion
        [Konashi i2cStartCondition];
        [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
        data[0] = 0xE0;
        konashiSuccess = [Konashi i2cWrite:1 data:data address:HUMID_TEMP_SENSOR_ADDRESS];
        NSLog(@"Konashi %d", konashiSuccess);
        if (konashiSuccess) [Konashi reset];
        [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
        konashiSuccess = [Konashi i2cRestartCondition];
        NSLog(@"Konashi %d", konashiSuccess);
        if (konashiSuccess) [Konashi reset];
        [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
        konashiSuccess = [Konashi i2cReadRequest:3 address:HUMID_TEMP_SENSOR_ADDRESS];
        NSLog(@"Konashi %d", konashiSuccess);
        if (konashiSuccess) [Konashi reset];
        [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL_LONG];
        count = !count;
    }
}

- (void)readSensor // Read RH & Temperature
{
    unsigned char data[3];
    if(count){ // Read RH
        konashiSuccess = [Konashi i2cRead:3 data:data];
        NSLog(@"Konashi %d", konashiSuccess);
        if (konashiSuccess) [Konashi reset];
        [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
        konashiSuccess = [Konashi i2cStopCondition];
        NSLog(@"Konashi %d", konashiSuccess);
        if (konashiSuccess) [Konashi reset];
        
        NSLog(@"RH:%X,%X", data[0], data[1]);
        
        rh = (double) ((unsigned short)(data[0] << 8 ^ data[1])) * 125.0 / 65536.0 - 6.0;
        
        _rhLabel.text = [NSString stringWithFormat:@"%.1f", rh];
        
        NSLog(@"RH: %f", rh);
        NSLog(@" ");
        //_silabsLogo.hidden = NO;
        _rhLabel.hidden = NO;
        _rhUnit.hidden = NO;
    }
    
    else{ // Read Temp.
        konashiSuccess = [Konashi i2cRead:3 data:data];
        NSLog(@"Konashi %d", konashiSuccess);
        if (konashiSuccess) [Konashi reset];
        [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
        konashiSuccess = [Konashi i2cStopCondition];
        NSLog(@"Konashi %d", konashiSuccess);
        if (konashiSuccess) [Konashi reset];
        
        NSLog(@"Temp:%X,%X", data[0], data[1]);
        
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
    }
}
@end
