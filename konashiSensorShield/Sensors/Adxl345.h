//
//  Adxl345.h
//  konashiSensorShield
//
//  Created by Kenji Ohno on 2014/04/10.
//  Copyright (c) 2014年 Macnica. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Konashi.h"

#define CHECK_SENSOR_INTERVAL           0.1001f
#define I2C_WAIT_INTERVAL               0.1
#define I2C_WAIT_INTERVAL_LONG          0.5

#define I2C_GLOBAL_ADDRESS              0x00
#define I2C_GLOBAL_RESET_CMD            0x06

#define ACC_SENSOR_ADDRESS              0x1D //ADXL345

// ADXL345 common
#define HIGH 1
#define LOW 0
#define OUTPUT 1
#define INPUT 0
#define PULLUP 1
#define NO_PULLS 0
#define ENABLE 1
#define DISABLE 0
#define TRUE 1
#define FALSE 0
#define ADXL345_SUCCESS 0
#define ADXL345_FAILURE -1

// ADXL345 Register Address
#define REG_ADRS_DEVID           0x00
#define REG_ADRS_THRESH_TAP      0x1D
#define REG_ADRS_OFSX            0x1E
#define REG_ADRS_OFSY            0x1F
#define REG_ADRS_OFXZ            0x20
#define REG_ADRS_DUR             0x21
#define REG_ADRS_LATENT          0x22
#define REG_ADRS_WINDOW          0x23
#define REG_ADRS_THRESH_ACT      0x24
#define REG_ADRS_THRESH_INACT    0x25
#define REG_ADRS_TIME_INACT      0x26
#define REG_ADRS_ACT_INACT_CTL   0x27
#define REG_ADRS_THRESH_FF       0x28
#define REG_ADRS_TIME_FF         0x29
#define REG_ADRS_TAP_AXES        0x2A
#define REG_ADRS_ACT_TAP_STATUS  0x2B
#define REG_ADRS_BW_RATE         0x2C
#define REG_ADRS_POWER_CTL       0x2D
#define REG_ADRS_INT_ENABLE      0x2E
#define REG_ADRS_INT_MAP         0x2F
#define REG_ADRS_INT_SOURCE      0x30
#define REG_ADRS_DATA_FORMAT     0x31
#define REG_ADRS_DATAX0          0x32
#define REG_ADRS_DATAX1          0x33
#define REG_ADRS_DATAY0          0x34
#define REG_ADRS_DATAY1          0x35
#define REG_ADRS_DATAZ0          0x36
#define REG_ADRS_DATAZ1          0x37
#define REG_ADRS_FIFO_CTL        0x38
#define REG_ADRS_FIFO_STATUS     0x39

// ADXL345 interface
@interface Adxl345 : NSObject
{
    //register
    unsigned char devID;
    unsigned char tapThreshold;
    unsigned char offsetX;
    unsigned char offsetY;
    unsigned char offsetZ;
    unsigned char tapDuration;
    unsigned char tapLatency;
    unsigned char tapWindow;
    unsigned char activityThreshold;
    unsigned char inactivityThreshold;
    unsigned char inactivityTime;
    unsigned char axisEnableControl;
    unsigned char freeFallThreshold;
    unsigned char freeFallTime;
    unsigned char tapAxisControl;
    unsigned char activityTapStatus;
    unsigned char bandWidthRate;
    unsigned char powerControl;
    unsigned char interruptEnableControl;
    unsigned char interruptMappingControl;
    unsigned char sourceOfInterrupt;
    unsigned char dataFormatControl;
    unsigned char dataX0;
    unsigned char dataX1;
    unsigned char dataY0;
    unsigned char dataY1;
    unsigned char dataZ0;
    unsigned char dataZ1;
    unsigned char fifoControl;
    unsigned char fifoStatus;
}
    


@end
