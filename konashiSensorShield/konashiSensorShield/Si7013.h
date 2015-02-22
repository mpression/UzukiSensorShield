//
//  Si7013.h
//  konashiSensorShield
//
//  Created by Kenji Ohno on 2015/02/22.
//  Copyright (c) 2015年 Macnica. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Konashi.h"

#ifndef konashiSensorShield_Si7013_h
#define konashiSensorShield_Si7013_h

#define I2C_WAIT_INTERVAL         0.1

#define HUMID_TEMP_SENSOR_ADDRESS       0x40 //Si7013

#define MEASURE_RH_HOLD  0xE5
#define MEASURE_RH_NOHOLD  0xF5
#define MEASURE_TEMP_HOLD  0xE3
#define MEASURE_TEMP_NOHOLD  0xF3
#define MEASURE_ANALOG  0xEE
#define READ_TEMP_FROM_PREV_RH  0xE0
#define RESET  0xFE
#define WRITE_USER_REG1  0xE6
#define READ_USER_REG1  0xE7
#define WRITE_USER_REG2  0x50
#define READ_USER_REG2  0x10
#define WRITE_USER_REG3  0x51
#define READ_USER_REG3  0x11
#define WRITE_THERMISTOR_COEFF  0xC5
#define READ_THERMISTOR_COEFF  0x84
#define READ_ID0  0xFA
#define READ_ID1  0x0F
#define READ_ID2  0xFC
#define READ_ID3  0xC9
#define READ_FIRMWARE  0x84
//#define READ_FIRMWARE  0xB8

/******************
 Si7013 interface
 ******************/

@interface Si7013 : NSObject

+ (void) checkHumidity;
+ (void) checkTemperature;

@end

#endif
