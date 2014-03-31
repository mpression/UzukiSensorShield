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

#define CHECK_SENSOR_INTERVAL           0.5f

#define I2C_GLOBAL_ADDRESS              0x00
#define I2C_GLOBAL_RESET_CMD            0x06

#define REG_HW_KEY                      0x07 
#define REG_HW_KEY_VALUE                0x17
//Write 0x17 value to this Register first after entering the stand-by mode followed by the init mode followed by the off mode.

#define PROX_LIGHT_UV_SENSOR_ADDRESS    0x60 //Si1045


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

#define EN_UV                           0x40
#define DIS_UV                          0x00

#define REG_AUX_DATA0                   0x2C
#define REG_AUX_DATA1                   0x2D

#define REG_UVI_DATA0                   0x2C
#define REG_UVI_DATA1                   0x2D

#define PS_FORCE_VALUE                  0x05
#define ALS_FORCE_VALUE                 0x06
#define PSALS_FORCE_VALUE               0x07






@interface SecondViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *uviLabel;
@property (weak, nonatomic) IBOutlet UIButton *devicePairingButton;
@property (weak, nonatomic) IBOutlet UIButton *tapDevicePairing;

@end
