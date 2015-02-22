//
//  Si7013.m
//  konashiSensorShield
//
//  Created by Kenji Ohno on 2015/02/22.
//  Copyright (c) 2015年 Macnica. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Si7013.h"
#import "Konashi.h"

@implementation Si7013

+ (void) checkHumidity{
    
    unsigned char data[2];
    [Konashi i2cStartCondition];
    data[0] = 0xE5;
    [Konashi i2cWrite:1 data:data address:HUMID_TEMP_SENSOR_ADDRESS];
    [Konashi i2cRestartCondition];
    [Konashi i2cReadRequest:3 address:HUMID_TEMP_SENSOR_ADDRESS];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL_500ms];
    
}

+ (void) checkTemperature{
    
    unsigned char data[2];
    [Konashi i2cStartCondition];
    data[0] = 0xE0;
    [Konashi i2cWrite:1 data:data address:HUMID_TEMP_SENSOR_ADDRESS];
    [Konashi i2cRestartCondition];
    [Konashi i2cReadRequest:3 address:HUMID_TEMP_SENSOR_ADDRESS];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL_500ms];
    
}

@end
