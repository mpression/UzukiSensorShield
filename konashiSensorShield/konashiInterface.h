//
//  konashiInterface.h
//  konashiSensorShield
//
//  Created by Kenji Ohno on 2015/02/02.
//  Copyright (c) 2015年 Macnica. All rights reserved.
//

#ifndef konashiSensorShield_konashiInterface_h
#define konashiSensorShield_konashiInterface_h


#endif

// Konashi common
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
#define KONASHI_SUCCESS 0
#define KONASHI_FAILURE -1

// Konashi I/0 pin
#define PIO0 0
#define PIO1 1
#define PIO2 2
#define PIO3 3
#define PIO4 4
#define PIO5 5
#define PIO6 6
#define PIO7 7

#define S1 0
#define LED2 1
#define LED3 2
#define LED4 3
#define LED5 4

#define AIO0 0
#define AIO1 1
#define AIO2 2

#define I2C_SDA 6
#define I2C_SCL 7

// Konashi PWM
#define KONASHI_PWM_DISABLE 0
#define KONASHI_PWM_ENABLE 1
#define KONASHI_PWM_ENABLE_LED_MODE 2
#define KONASHI_PWM_LED_PERIOD 10000  // 10ms

// Konashi analog I/O
#define KONASHI_ANALOG_REFERENCE 1300 // 1300mV

// Konashi UART baudrate
#define KONASHI_UART_RATE_2K4 0x000a
#define KONASHI_UART_RATE_9K6 0x0028

// Konashi I2C
#define KONASHI_I2C_DATA_MAX_LENGTH 18
#define KONASHI_I2C_DISABLE 0
#define KONASHI_I2C_ENABLE 1
#define KONASHI_I2C_ENABLE_100K 1
#define KONASHI_I2C_ENABLE_400K 2
#define KONASHI_I2C_STOP_CONDITION 0
#define KONASHI_I2C_START_CONDITION 1
#define KONASHI_I2C_RESTART_CONDITION 2

// Konashi UART
#define KONASHI_UART_DATA_MAX_LENGTH 19
#define KONASHI_UART_DISABLE 0
#define KONASHI_UART_ENABLE 1

// Konashi Events
#define KONASHI_EVENT_CENTRAL_MANAGER_POWERED_ON @"KonashiEventCentralManagerPoweredOn"

#define KONASHI_EVENT_PERIPHERAL_NOT_FOUND @"KonashiEventPeripheralNotFound"
#define KONASHI_EVENT_KONASHI_NOT_FOUND @"KonashiEventKonashiNotFound" // add by KO Mar.29,2014
#define KONASHI_EVENT_CANCEL_KONASHI_FIND @"KonashiEventCancelKonashiFind" // add by KO Mar.29,2014


#define KONASHI_EVENT_CONNECTED @"KonashiEventConnected"
#define KONASHI_EVENT_DISCONNECTED @"KonashiEventDisconnected"
#define KONASHI_EVENT_READY @"KonashiEventReady"

#define KONASHI_EVENT_UPDATE_PIO_INPUT @"KonashiEventUpdatePioInput"

#define KONASHI_EVENT_UPDATE_ANALOG_VALUE @"KonashiEventUpdateAnalogValue"
#define KONASHI_EVENT_UPDATE_ANALOG_VALUE_AIO0 @"KonashiEventUpdateAnalogValueAio0"
#define KONASHI_EVENT_UPDATE_ANALOG_VALUE_AIO1 @"KonashiEventUpdateAnalogValueAio1"
#define KONASHI_EVENT_UPDATE_ANALOG_VALUE_AIO2 @"KonashiEventUpdateAnalogValueAio2"

#define KONASHI_EVENT_I2C_READ_COMPLETE @"KonashiEventI2CReadComplete"

#define KONASHI_EVENT_UART_RX_COMPLETE @"KonashiEventUartRxComplete"

#define KONASHI_EVENT_UPDATE_BATTERY_LEVEL @"KonashiEventUpdateBatteryLevel"
#define KONASHI_EVENT_UPDATE_SIGNAL_STRENGTH @"KonashiEventUpdateSignalStrength"

#define KONASHI_FIND_TIMEOUT 2
