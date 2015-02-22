//
//  Si114x.m
//  konashiSensorShield
//
//  Created by Kenji Ohno on 2015/02/22.
//  Copyright (c) 2015年 Macnica. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Si114x.h"
#import "Konashi.h"

@implementation Si114x : NSObject

- (void) initialize{
    
    //***********************************************************
    // Si114x Ambient Light / UV Index / Proximity Sensor Setting
    //***********************************************************
    
    unsigned char data[2];
    //initialize: wait for 25ms or more.
    [NSThread sleepForTimeInterval:0.1];
    
    // HW_KEYレジスタに0x17をWR　→オペレーション開始
    [Konashi i2cStartCondition];
    data[0] = REG_HW_KEY;
    data[1] = REG_HW_KEY_VALUE;
    [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    [Konashi i2cStopCondition];
    
    // REG_COEF0-3レジスタにSiLabs指定の補正値をWR
    [Konashi i2cStartCondition];
    data[0] = REG_COEF0;
    data[1] = REG_COEF0_VALUE;
    [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    [Konashi i2cStopCondition];
    
    [Konashi i2cStartCondition];
    data[0] = REG_COEF1;
    data[1] = REG_COEF1_VALUE;
    [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    [Konashi i2cStopCondition];
    
    
    [Konashi i2cStartCondition];
    data[0] = REG_COEF2;
    data[1] = REG_COEF2_VALUE;
    [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    [Konashi i2cStopCondition];
    
    [Konashi i2cStartCondition];
    data[0] = REG_COEF3;
    data[1] = REG_COEF3_VALUE;
    [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    [Konashi i2cStopCondition];
    
    [Konashi i2cStartCondition];
    data[0] = REG_PARAM_WR; //パラメータレジスタに書き込む値をセットするレジスタ
    data[1] = EN_UV | EN_ALS_IR | EN_ALS_VIS; //パラメータレジスタに書き込む値
    [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    [Konashi i2cStopCondition];
    
    [Konashi i2cStartCondition];
    data[0] = REG_COMMAND;
    data[1] = 0xA0 | PARAM_CH_LIST; // 0xA0 is the PARAM_SET cmd.
    [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    [Konashi i2cStopCondition];
    
}

+ (void) chkAmbientLight{
    
    unsigned char data[2];
    [Konashi i2cStartCondition];
    data[0] = REG_COMMAND;
    data[1] = ALS_FORCE; // Enter ALS Force Mode.
    //data[1] = ALS_AUTO;   // Enter ALS Autonomous Mode.
    [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    [Konashi i2cStopCondition];
    
    [Konashi i2cStartCondition];
    //data[0] = 0x00; // Part ID : 0x45 for Si1145
    //data[0] = REG_UVI_DATA0;
    data[0] = ALS_VIS_DATA0;
    [Konashi i2cWrite:1 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    [Konashi i2cRestartCondition];
    [Konashi i2cReadRequest:2 address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
}

@end
