//
//  FirstViewController.h
//  konashiSensorShield
//
//  Created by Kenji Ohno on 2014/03/28.
//  Copyright (c) 2014年 Macnica. All rights reserved.
//

#import <GameKit/GameKit.h>
#import <UIKit/UIKit.h>

#define CHECK_SENSOR_INTERVAL           0.1001f
#define I2C_WAIT_INTERVAL               0.1
#define I2C_WAIT_INTERVAL_LONG          0.5

#define I2C_GLOBAL_ADDRESS              0x00
#define I2C_GLOBAL_RESET_CMD            0x06
#define HUMID_TEMP_SENSOR_ADDRESS       0x40 //Si7013

@interface FirstViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *dciTitle;
@property (weak, nonatomic) IBOutlet UILabel *tempUnit;
@property (weak, nonatomic) IBOutlet UILabel *rhUnit;

@property (weak, nonatomic) IBOutlet UILabel *rhLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *dciLabel;
@property (weak, nonatomic) IBOutlet UIButton *devicePairingButton;
- (IBAction)tapDevicePairing:(id)sender;

@end
