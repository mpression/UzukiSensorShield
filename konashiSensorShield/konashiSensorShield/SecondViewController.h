//
//  SecondViewController.h
//  konashiSensorShield
//
//  Created by Kenji Ohno on 2014/03/28.
//  Copyright (c) 2014年 Macnica. All rights reserved.
//

#import <GameKit/GameKit.h>
#import <UIKit/UIKit.h>
#import "si114x_defs.h"

#define CHECK_SENSOR_INTERVAL           0.1001f
#define I2C_WAIT_INTERVAL               0.1
#define I2C_WAIT_INTERVAL_LONG          0.5

#define PROX_LIGHT_UV_SENSOR_ADDRESS    0x60 //Si1045

#define I2C_GLOBAL_ADDRESS              0x00
#define I2C_GLOBAL_RESET_CMD            0x06

#define REG_HW_KEY                      0x07 
#define REG_HW_KEY_VALUE                0x17
//Write 0x17 value to this Register first after entering the stand-by mode followed by the init mode followed by the off mode.


#define MEAS_RATE0                      0x08
#define MEAS_RATE1                      0x09

#define MEAS_RATE0_VALUE                0x00
#define MEAS_RATE1_VALUE                0x02

#define REG_PARAM_WR                    0x17
#define REG_COMMAND                     0x18
#define REG_PARAM_RD                    0x2E

#define REG_COEF0                       0x13
#define REG_COEF1                       0x14
#define REG_COEF2                       0x15
#define REG_COEF3                       0x16

#define REG_COEF0_VALUE                 0x00
#define REG_COEF1_VALUE                 0x02
#define REG_COEF2_VALUE                 0x89
#define REG_COEF3_VALUE                 0x29

#define PARAM_CH_LIST                   0x01

#define EN_UV                           0x80
#define EN_AUX                          0x40
#define EN_ALS_IR                       0x20
#define EN_ALS_VIS                      0x10
#define EN_PS3                          0x04
#define EN_PS2                          0x02
#define EN_PS1                          0x01

#define ALS_VIS_DATA0                   0x22
#define ALS_VIS_DATA1                   0x23

#define REG_AUX_DATA0                   0x2C
#define REG_AUX_DATA1                   0x2D

#define REG_UVI_DATA0                   0x2C
#define REG_UVI_DATA1                   0x2D

#define PS_FORCE                        0x05
#define ALS_FORCE                       0x06
#define PSALS_FORCE                     0x07

#define PS_AUTO                         0x0D
#define ALS_AUTO                        0x0E
#define PSALS_AUTO                      0x0F


@interface SecondViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *uviLabel;
@property (weak, nonatomic) IBOutlet UIButton *devicePairingButton;
@property (weak, nonatomic) IBOutlet UIButton *tapDevicePairing;


@end
