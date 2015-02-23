//
//  Adxl345.m
//  konashiSensorShield
//
//  Created by Kenji Ohno on 2014/04/10.
//  Copyright (c) 2014年 Macnica. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Adxl345.h"
#import "Konashi.h"

@implementation Adxl345 : NSObject

+ (void) setup{
    
    unsigned char data[2];
    
    [Konashi i2cStartCondition];
    data[0] = 0x31; // DATA FORMAT REGISTER
    data[1] = 0x0B; // Set Full Resolution, +/- 16g
    [Konashi i2cWrite:2 data:data address:ACC_SENSOR_ADDRESS];
    [Konashi i2cStopCondition];
    
    [Konashi i2cStartCondition];
    data[0] = 0x2D; // POWER CONTROL REGISTER
    data[1] = 0x08; // Set to Measure Mode
    [Konashi i2cWrite:2 data:data address:ACC_SENSOR_ADDRESS];
    [Konashi i2cStopCondition];
    
    [Konashi i2cStartCondition];
    data[0] = 0x24; // THRESHOLD ACTIVE : 6.25mg/LSB
    data[1] = 0x20; // 2.0g
    //data[1] = 0x10;   // 1.0g
    //data[1] = 0x08;   // 0.5g
    [Konashi i2cWrite:2 data:data address:ACC_SENSOR_ADDRESS];
    [Konashi i2cStopCondition];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    
    [Konashi i2cStartCondition];
    data[0] = 0x27; // ACTIVE/INACTIVE CONTROL REGISTER
    data[1] = 0xF0; // D7 : 1 : Act AC Coupling
    // D6 : 1 : Act_X Enable
    // D5 : 1 : Act_Y Enable
    // D4 : 1 : Act_Z Enable
    // D3 : 0 : Inact DC Coupling
    // D2 : 0 : Inact_X Disable
    // D1 : 0 : Inact_Y Disable
    // D0 : 0 : Inact_Z Disable
    [Konashi i2cWrite:2 data:data address:ACC_SENSOR_ADDRESS];
    [Konashi i2cStopCondition];
}

+ (void) chkThreshold{
    
    unsigned char data[2];
    [Konashi i2cStartCondition];
    data[0] = 0x2E; // Int Enable
    data[1] = 0x10; // Enable only Activity
    [Konashi i2cWrite:2 data:data address:ACC_SENSOR_ADDRESS];
    [Konashi i2cStopCondition];
    
    [Konashi i2cStartCondition];
    data[0] = 0x30; // Int Source Register
    //data[0] = 0x32; // data_x lo
    [Konashi i2cWrite:1 data:data address:ACC_SENSOR_ADDRESS];
    [Konashi i2cRestartCondition];
    
    [Konashi i2cReadRequest:1 address:ACC_SENSOR_ADDRESS];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
}

+ (void) chkAcceleration{
    
    unsigned char data[6];
    [Konashi i2cStartCondition];
    data[0] = 0x32; // data_x lo
    [Konashi i2cWrite:1 data:data address:ACC_SENSOR_ADDRESS];
    [Konashi i2cRestartCondition];
    
    //read Acceleration 3-Axis
    [Konashi i2cReadRequest:6 address:ACC_SENSOR_ADDRESS];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    
}

@end
