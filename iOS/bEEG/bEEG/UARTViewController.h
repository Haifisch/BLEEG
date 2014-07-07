//
//  UARTViewController.h
//  Bluefruit Connect
//
//  Created by Adafruit Industries on 2/5/14.
//  Copyright (c) 2014 Adafruit Industries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "UARTPeripheral.h"
#import "BEMSimpleLineGraphView.h"


@interface UARTViewController : UIViewController <UITextFieldDelegate, UARTPeripheralDelegate, CBCentralManagerDelegate,BEMSimpleLineGraphDelegate>
typedef enum {
    ConnectionModeNone  = 0,
    ConnectionModePinIO,
    ConnectionModeUART,
} ConnectionMode;

typedef enum {
    ConnectionStatusDisconnected = 0,
    ConnectionStatusScanning,
    ConnectionStatusConnected,
} ConnectionStatus;

@property (nonatomic, assign) ConnectionMode                    connectionMode;
@property (nonatomic, assign) ConnectionStatus                  connectionStatus;

typedef enum {
    LOGGING,
    RX,
    TX,
} ConsoleDataType;

typedef enum {
    ASCII = 0,
    HEX,
} ConsoleMode;

@property (nonatomic, assign) BOOL                              keyboardIsShown;
@property (strong, nonatomic) NSAttributedString                *consoleAsciiText;
@property (strong, nonatomic) NSAttributedString                *consoleHexText;
@property (strong, nonatomic) IBOutlet UILabel *signalStrength;
@property (strong, nonatomic) IBOutlet UILabel *attentionLabel;
@property (strong, nonatomic) IBOutlet UILabel *meditationValue;
@property (strong, nonatomic) IBOutlet UILabel *deltaValue;
@property (strong, nonatomic) IBOutlet UILabel *thetaValue;
@property (strong, nonatomic) IBOutlet UILabel *lowAlpha;
@property (strong, nonatomic) IBOutlet UILabel *highAlpha;
@property (strong, nonatomic) IBOutlet UILabel *lowBeta;
@property (strong, nonatomic) IBOutlet UILabel *highBeta;
@property (strong, nonatomic) IBOutlet UILabel *lowGamma;
@property (strong, nonatomic) IBOutlet UILabel *highGamma;
- (IBAction)reloadGraph:(id)sender;

- (void)receiveData:(NSData*)newData;


@end
