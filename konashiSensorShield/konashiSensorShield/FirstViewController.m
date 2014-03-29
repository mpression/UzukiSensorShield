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
        [NSThread sleepForTimeInterval:0.01];
        data[0] = 0xE5;
        konashiSuccess = [Konashi i2cWrite:1 data:data address:HUMID_TEMP_SENSOR_ADDRESS];
        if (konashiSuccess) [Konashi reset];
        [NSThread sleepForTimeInterval:0.1];
        konashiSuccess = [Konashi i2cRestartCondition];
        if (konashiSuccess) [Konashi reset];
        [NSThread sleepForTimeInterval:0.1];
        konashiSuccess = [Konashi i2cReadRequest:3 address:HUMID_TEMP_SENSOR_ADDRESS];
        if (konashiSuccess) [Konashi reset];
        [NSThread sleepForTimeInterval:0.5];
        count = !count;
    }
    else{
        // Sequence to Start a Temperature Conversion
        [Konashi i2cStartCondition];
        [NSThread sleepForTimeInterval:0.01];
        data[0] = 0xE0;
        konashiSuccess = [Konashi i2cWrite:1 data:data address:HUMID_TEMP_SENSOR_ADDRESS];
        if (konashiSuccess) [Konashi reset];
        [NSThread sleepForTimeInterval:0.1];
        konashiSuccess = [Konashi i2cRestartCondition];
        if (konashiSuccess) [Konashi reset];
        [NSThread sleepForTimeInterval:0.1];
        konashiSuccess = [Konashi i2cReadRequest:3 address:HUMID_TEMP_SENSOR_ADDRESS];
        if (konashiSuccess) [Konashi reset];
        [NSThread sleepForTimeInterval:0.5];
        count = !count;
    }
}

- (void)readSensor // Read RH & Temperature
{
    unsigned char data[3];
    if(count){ // Read RH
        konashiSuccess = [Konashi i2cRead:3 data:data];
        if (konashiSuccess) [Konashi reset];
        [NSThread sleepForTimeInterval:0.1];
        [NSThread sleepForTimeInterval:0.01];
        konashiSuccess = [Konashi i2cStopCondition];
        if (konashiSuccess) [Konashi reset];
        
        NSLog(@"RH:%X,%X", data[0], data[1]);
        
        double rh = (double) ((unsigned short)(data[0] << 8 ^ data[1])) * 125.0 / 65536.0 - 6.0;
        
        _rhLabel.text = [NSString stringWithFormat:@"%.1f", rh];
        
        NSLog(@"RH: %f", rh);
        NSLog(@" ");
        //_silabsLogo.hidden = NO;
        _rhLabel.hidden = NO;
    }
    
    else{ // Read Temp.
        konashiSuccess = [Konashi i2cRead:3 data:data];
        if (konashiSuccess) [Konashi reset];
        [NSThread sleepForTimeInterval:0.1];
        [NSThread sleepForTimeInterval:0.01];
        konashiSuccess = [Konashi i2cStopCondition];
        if (konashiSuccess) [Konashi reset];
        
        NSLog(@"Temp:%X,%X", data[0], data[1]);
        
        double temp = (double) ((unsigned short)(data[0] << 8 ^ data[1])) * 175.72 / 65536.0 - 46.85;
        
        _tempLabel.text = [NSString stringWithFormat:@"%.1f", temp];
        
        NSLog(@"Temp:%f", temp);
        NSLog(@" ");
        //_silabsLogo.hidden = YES;
        _tempLabel.hidden = NO;
    }
}
@end
