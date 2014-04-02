//
//  SecondViewController.m
//  konashiSensorShield
//
//  Created by Kenji Ohno on 2014/03/28.
//  Copyright (c) 2014年 Macnica. All rights reserved.
//
/* To enable UV reading, set the EN_UV(bit7) bit in CHLIST(offset:0x01),
 
 address                    EN_UV(bit7)     value
    0x01(parameter RAM)                       01000000b = 0x40
 
 and configure UCOEF [3:0] to the default values of 0x29,0x89, 0x02, and 0x00. 

 address     UCOEF       value
    0x13        UCOEF0      0x00
    0x14        UCOEF1      0x02
    0x15        UCOEF2      0x89
    0x16        UCOEF3      0x29
 
 
 void Si1143_SetParam(uint8_t addr, uint8_t value)
 {
 Si1143_WriteRegister(REG_PARAM_WR, value);
 Si1143_WriteRegister(REG_COMMAND, 0xA0 | addr);
 
 }
 
 If the sensor will be under an overlay that is not 100% transmissive to sunlight, 
 contactSilicon Labs for more information on adjusting these coefficients.
 Typically, after 285 μs, AUX_DATA will contain a 16-bit value representing 100 times the sunlight UV Index.
 
 AUX_DATA(UVINDEX) : 0x2C:UVINDEX0(LSB8bit), 0x2D:UVINDEX1(MSB8bit) => UVINDEX[15:0]
 Host software must divide the results from AUX_DATA by 100.
 
 The accuracy of UV readings can be improved by using calibration parameters 
 that are programmed into the Si1132/Si114x at Silicon Labs' production facilities 
 to adjust for normal part-to-part variation. 
 The calibration parameters are recovered from the Si113x/Si114x 
 by writing Command Register @ address 0x18 with the value 0x12.
 When the calibration parameters are recovered they show up at I2C registers 0x22 to 0x2D. 
 These are the same registers used to report the VIS, IR, PS1, PS2, PS3, and AUX measurements.
 The use of calibration parameters is documented in the file, 
 Si114x_functions.h, which is part of the Si114x Programmer's Toolkit example source code and is downloadable from Silabs.com. 
 The host code is expected to allocate memory for the SI114X_CAL_S structure. 
 The si114x_calibration routine will then fill it up with the appropriate values.
 Once the calibration parameters have been recovered the routine Si114x_set_ucoef is used 
 to modify the default values that go into the UCOEF0 to UCOEF3 UV configuration registers 
 to remove normal part-to-part variation.
 The typical calibrated UV sensor response vs. calculated ideal UV Index is shown in Figure 11 
 for a large database of sunlight spectra from cloudy to sunny days and 
 at various angles of the sun/time of day. */

/*Upon reset, the minimum code necessary to obtain measurements out of each optical channel is shown. Note that
 many of the defines are in the file called Si114x_defs.h. It is recommended that the symbols within the files be used
 so that the code is more readable.
 Some functions are assumed to exist:
 U8 ReadFromRegister(U8 reg) returns byte from I2C Register 'reg'
 
 void WriteToRegister(U8 reg, U8 value) writes 'value' into I2C Register reg'
 void ParamSet(U8 address, U8 value) writes 'value' into Parameter 'address'
 PsAlsForce() equivalent to WriteToRegister(REG_COMMAND,0x07)
 This forces PS and ALS measurements
 // Send Hardware Key
 // I2C Register 0x07 = 0x17
 WriteToRegister(REG_HW_KEY, HW_KEY_VAL0);
 // Initialize LED Current
 // I2C Register 0x0F = 0xFF
 // I2C Register 0x10 = 0x0F
 WriteToRegister(REG_PS_LED21,(MAX_LED_CURRENT<<4) + MAX_LED_CURRENT);
 WriteToRegister(REG_PS_LED3, MAX_LED_CURRENT);
 
 // Parameter 0x01 = 0x37
 ParamSet(PARAM_CH_LIST, ALS_IR_TASK + ALS_VIS_TASK + PS1_TASK + PS2_TASK + PS3_TASK);
 // I2C Register 0x18 = 0x0x07
 PsAlsForce(); // can also be written as WriteToRegister(REG_COMMAND,0x07);
 // Once the measurements are completed, here is how to reconstruct them
 // Note very carefully that 16-bit registers are in the 'Little Endian' byte order
 // It may be more efficient to perform block I2C Reads, but this example shows
 // individual reads of registers
 ALS_VIS = ReadFromRegister(REG_ALS_VIS_DATA0) +
 256 * ReadFromRegister(REG_ALS_VIS_DATA1);
 ALS_IR = ReadFromRegister(REG_ALS_IR_DATA0) +
 256 * ReadFromRegister(REG_ALS_IR_DATA1);
 PS1 = ReadFromRegister(REG_PS1_DATA0) +
 256 * ReadFromRegister(REG_PS1_DATA1);
 PS2 = ReadFromRegister(REG_PS2_DATA0) +
 256 * ReadFromRegister(REG_PS2_DATA1);
 PS3 = ReadFromRegister(REG_PS3_DATA0) +
 256 * ReadFromRegister(REG_PS3_DATA1);
 Be aware of the little-endian ordering when constructing the 16-bit variable.
 
 */

#import "SecondViewController.h"
#import "Konashi.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

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
    unsigned char data[2];
    NSLog(@"Start check sensor.");
    
    //initialize: wait for 25ms or more.
    [NSThread sleepForTimeInterval:0.1];
    
    
    // HW_KEYレジスタに0x17をWR　→オペレーション開始
    konashiSuccess = [Konashi i2cStartCondition];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    data[0] = REG_HW_KEY;
    data[1] = REG_HW_KEY_VALUE;
    konashiSuccess = [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    //[NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    konashiSuccess = [Konashi i2cStopCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    
    // REG_COEF0-3レジスタにSiLabs指定の補正値をWR
    [Konashi i2cStartCondition];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    data[0] = REG_COEF0;
    data[1] = REG_COEF0_VALUE;
    konashiSuccess = [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    konashiSuccess = [Konashi i2cStopCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    
    konashiSuccess = [Konashi i2cStartCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    data[0] = REG_COEF1;
    data[1] = REG_COEF1_VALUE;
    konashiSuccess = [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    konashiSuccess = [Konashi i2cStopCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    
    konashiSuccess = [Konashi i2cStartCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    data[0] = REG_COEF2;
    data[1] = REG_COEF2_VALUE;
    konashiSuccess = [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    konashiSuccess = [Konashi i2cStopCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    
    konashiSuccess = [Konashi i2cStartCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    data[0] = REG_COEF3;
    data[1] = REG_COEF3_VALUE;
    konashiSuccess = [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    konashiSuccess = [Konashi i2cStopCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    
    
    // Sequence to Start a UV Index Conversion
    konashiSuccess = [Konashi i2cStartCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    data[0] = REG_PARAM_WR; //パラメータレジスタに書き込む値をセットするレジスタ
    data[1] = EN_UV | EN_ALS_IR | EN_ALS_VIS; //パラメータレジスタに書き込む値
    konashiSuccess = [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    konashiSuccess = [Konashi i2cStopCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];

    konashiSuccess = [Konashi i2cStartCondition];
    //[NSThread sleepForTimeInterval:0.1];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    data[0] = REG_COMMAND;
    data[1] = 0xA0 | PARAM_CH_LIST; // 0xA0 is the PARAM_SET cmd.
    konashiSuccess = [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    konashiSuccess = [Konashi i2cStopCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    
    //Sensor Event Handler
    [Konashi addObserver:self selector:@selector(readLightSensor) name:KONASHI_EVENT_I2C_READ_COMPLETE];
    checkSensorTimer = [NSTimer scheduledTimerWithTimeInterval:CHECK_SENSOR_INTERVAL
                                                        target:self
                                                      selector:@selector(checkLightSensor:)
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

//To check the UV Index Sensor on the I2C bus.
- (void)checkLightSensor:(NSTimer *)timer
{
    unsigned char data[2];
    
    konashiSuccess = [Konashi i2cStartCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    
    
    data[0] = REG_COMMAND;
    data[1] = ALS_FORCE; // Enter ALS Force Mode.
    //data[1] = ALS_AUTO;   // Enter ALS Autonomous Mode.
    konashiSuccess = [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    konashiSuccess = [Konashi i2cStopCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];

    konashiSuccess = [Konashi i2cStartCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    
    
    //data[0] = 0x00; // Part ID : 0x45 for Si1145
    //data[0] = REG_UVI_DATA0;
    data[0] = REG_ALS_VIS_DATA0;
    konashiSuccess = [Konashi i2cWrite:1 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    konashiSuccess = [Konashi i2cRestartCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];

    konashiSuccess = [Konashi i2cReadRequest:2 address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL_LONG];
}

- (void)readLightSensor // UV Index
{
    unsigned char data[2];
    konashiSuccess = [Konashi i2cRead:2 data:data];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
        
    NSLog(@"UVI_HL:%X,%X", data[1], data[0]);
        
    int uvi = (int) ( (double) ((unsigned short)(data[1] << 8 | data[0])) / 100.0);
        
    _uviLabel.text = [NSString stringWithFormat:@"%d", uvi];
        
    NSLog(@"UVI: %d", uvi);
    NSLog(@" ");
    //_silabsLogo.hidden = NO;
    _uviLabel.hidden = NO;
    
    konashiSuccess = [Konashi i2cStopCondition];
    //NSLog(@"Konashi %d", konashiSuccess);
    if (konashiSuccess) [Konashi reset];
    [NSThread sleepForTimeInterval:I2C_WAIT_INTERVAL];
    
    //[Konashi i2cStartCondition];
    //[NSThread sleepForTimeInterval:0.1];
    //data[0] = REG_PARAM_WR;
    //data[1] = DIS_UV;
    //konashiSuccess = [Konashi i2cWrite:2 data:data address:PROX_LIGHT_UV_SENSOR_ADDRESS];
    //if (konashiSuccess) [Konashi reset];
    //[NSThread sleepForTimeInterval:0.1];
    //konashiSuccess = [Konashi i2cStopCondition];
    //if (konashiSuccess) [Konashi reset];
    
}
@end
