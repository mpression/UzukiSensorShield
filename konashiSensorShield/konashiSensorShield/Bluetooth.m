//
//  Bluetooth.m
//  konashiSensorShield
//
//  Created by Kenji Ohno on 2014/05/21.
//  Copyright (c) 2014年 Macnica. All rights reserved.
//

#import "Bluetooth.h"
#import "konashiInterface.h"

@interface Bluetooth()
@property(weak, nonatomic)  NSTimer *timer;
@end

@implementation Bluetooth

#pragma mark - Bluetooth communication (Konashi )

-(id)init {
    [self initKonashi];
    return self;
}

-(void)dealloc {
    [_timer invalidate];
}

-(void)initKonashi {
    // KONASHIの初期化（接続とREADYのEVENT通知を登録する)
    [Konashi initialize];
    [Konashi addObserver:self selector:@selector(connected) name:KONASHI_EVENT_CONNECTED];
    [Konashi addObserver:self selector:@selector(ready) name:KONASHI_EVENT_READY];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerJob) userInfo:nil repeats:YES];
}

// Bluetooth接続が切れた際に、再接続を自動的に行う
-(void)timerJob {
    if([Konashi isConnected]) {
    }
    else {
        [self autoFind];
    }
}

-(void)autoFind {
    [Konashi findWithName:@"konashi#4-0126"];
}

-(void)connected {
    NSLog(@"BLE Connected");
}

-(void) ready {
    NSLog(@"BLE Ready");
    
    // 接続されたことを示すために、Konashi本体のLEDを全て点灯する
    [Konashi pinMode:LED2 mode:OUTPUT];
    [Konashi pinMode:LED3 mode:OUTPUT];
    [Konashi pinMode:LED4 mode:OUTPUT];
    [Konashi pinMode:LED5 mode:OUTPUT];
    for(int i=LED2; i <= LED5; i++) {
        [Konashi digitalWrite:i value:HIGH];
    }
    
    
    // I2Cモードの接続を行う
    int ret = [Konashi i2cMode:KONASHI_I2C_ENABLE_100K];
    if(ret != 0)
        NSLog(@"i2cMode ret=%d", ret);
}
@end
