//
//  UARTViewController.m
//  Bluefruit Connect
//
//  Created by Adafruit Industries on 2/5/14.
//  Copyright (c) 2014 Adafruit Industries. All rights reserved.
//

#import "UARTViewController.h"
#import "NSString+hex.h"
#import "NSData+hex.h"

#define kKeyboardAnimationDuration 0.3f

@interface UARTViewController(){
    CBCentralManager    *cm;
    UIAlertView         *currentAlertView;
    UARTPeripheral      *currentPeripheral;
    UARTViewController  *uartViewController;
    NSString    *unkownCharString;
    NSString *sheTurnedMeIntoANewt;
    NSArray *brainData;
    UIAlertView *missingData;

}
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *graphView;

@end

@implementation UARTViewController


#pragma mark - View Lifecycle


- (void)viewDidLoad{
    
    [super viewDidLoad];
    sheTurnedMeIntoANewt = [[NSString alloc] init];
    //initialization
    //define unknown char
    self.graphView.delegate = self;
    self.graphView.animationGraphEntranceSpeed = 10;
    self.graphView.enableBezierCurve = YES;
    self.graphView.colorXaxisLabel = [UIColor whiteColor];
    self.graphView.enablePopUpReport = YES;
    self.graphView.enableTouchReport = YES;

    cm = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    _connectionMode = ConnectionModeNone;
    _connectionStatus = ConnectionStatusDisconnected;
    currentAlertView = nil;
    unkownCharString = [NSString stringWithFormat:@"%C", (unichar)0xFFFD];   //diamond question mark
    //round corners on console

    [self tryToConnect];
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)updateConsoleWithIncomingData:(NSData*)newData {
    
    //Write new received data to the console text view
    
    
    NSString *newString = [[NSString alloc]initWithBytes:newData.bytes
                                                  length:newData.length
                                                encoding:NSUTF8StringEncoding];
    if (newData.length == 20) {
        sheTurnedMeIntoANewt = [NSString stringWithFormat:@"%@%@",sheTurnedMeIntoANewt,newString];
    }else {
        sheTurnedMeIntoANewt = [NSString stringWithFormat:@"%@%@",sheTurnedMeIntoANewt,newString];
        brainData = [sheTurnedMeIntoANewt componentsSeparatedByString:@","];
        NSLog(@"Data count %i Data: %@", brainData.count, brainData);
        if(brainData.count == 11){
            self.signalStrength.text = brainData[0];
            self.attentionLabel.text = brainData[1];
            self.meditationValue.text = brainData[2];
            self.deltaValue.text =  brainData[3];
            self.thetaValue.text =  brainData[4];
            self.lowAlpha.text =    brainData[5];
            self.highAlpha.text =    brainData[6];
            self.lowBeta.text =  brainData[7];
            self.highBeta.text =  brainData[8];
            self.lowGamma.text =    brainData[9];
            self.highGamma.text =    brainData[10];
            [self.graphView reloadGraph];
            NSLog(@"Signal: %@ Attention: %@ Meditation: %@ Delta: %@ Theta: %@ Low Alpha: %@ High Alpha: %@", brainData[0], brainData[1], brainData[2], brainData[3], brainData[4], brainData[5], brainData[6]);
        }else {
            if (!missingData) {
                missingData = [[UIAlertView alloc] initWithTitle:@"We're missing some data!" message:@"Make sure your EEG headband is fully attatched to the head, and it should be fine." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [missingData show];
            }
        }
        
        
        sheTurnedMeIntoANewt = [[NSString alloc] init];

    }
}
- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    NSArray *names = [NSArray arrayWithObjects:@"Signal", @"Attention",@"Meditation",@"Delta",@"Theta",@"Low Alpha",@"High Alpha",@"Low Beta", @"High Beta",@"Low Gamma", @"High Gamma", nil];
    return names[index];
}
- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    NSLog(@"%@",brainData);
    return brainData.count; // Number of points in the graph.
}
- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [brainData[index] floatValue]; // The value of the point on the Y-Axis for the index.
}
- (IBAction)reloadGraph:(id)sender {
}

- (void)receiveData:(NSData*)newData{
    
    //Receive data from device
    
    [self updateConsoleWithIncomingData:newData];
    
}

#pragma mark CBCentralManagerDelegate


- (void) centralManagerDidUpdateState:(CBCentralManager*)central{
    
    if (central.state == CBCentralManagerStatePoweredOn){
        
        //respond to powered on
    }
    
    else if (central.state == CBCentralManagerStatePoweredOff){
        
        //respond to powered off
    }
    
}


- (void) centralManager:(CBCentralManager*)central didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber*)RSSI{
    
    NSLog(@"Did discover peripheral %@", peripheral.name);
    
    [cm stopScan];
    
    [self connectPeripheral:peripheral];
}


- (void) centralManager:(CBCentralManager*)central didConnectPeripheral:(CBPeripheral*)peripheral{
    
    if ([currentPeripheral.peripheral isEqual:peripheral]){
        
        if(peripheral.services){
            NSLog(@"Did connect to existing peripheral %@", peripheral.name);
            [currentPeripheral peripheral:peripheral didDiscoverServices:nil]; //already discovered services, DO NOT re-discover. Just pass along the peripheral.
        }
        
        else{
            NSLog(@"Did connect peripheral %@", peripheral.name);
            [currentPeripheral didConnect];
        }
    }
    
}


- (void) centralManager:(CBCentralManager*)central didDisconnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error{
    
    NSLog(@"Did disconnect peripheral %@", peripheral.name);
    
    //respond to disconnected
    [self peripheralDidDisconnect];
    
    if ([currentPeripheral.peripheral isEqual:peripheral])
    {
        [currentPeripheral didDisconnect];
    }
}
- (void)scanForPeripherals{
    
    //Look for available Bluetooth LE devices
    
    //skip scanning if UART is already connected
    NSArray *connectedPeripherals = [cm retrieveConnectedPeripheralsWithServices:@[UARTPeripheral.uartServiceUUID]];
    if ([connectedPeripherals count] > 0) {
        //connect to first peripheral in array
        [self connectPeripheral:[connectedPeripherals objectAtIndex:0]];
    }
    
    else{
        
        [cm scanForPeripheralsWithServices:@[UARTPeripheral.uartServiceUUID]
                                   options:@{CBCentralManagerScanOptionAllowDuplicatesKey: [NSNumber numberWithBool:NO]}];
    }
    
}


- (void)connectPeripheral:(CBPeripheral*)peripheral{
    
    //Connect Bluetooth LE device
    
    //Clear off any pending connections
    [cm cancelPeripheralConnection:peripheral];
    
    //Connect
    currentPeripheral = [[UARTPeripheral alloc] initWithPeripheral:peripheral delegate:self];
    [cm connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];
    
}


- (void)disconnect{
    
    //Disconnect Bluetooth LE device
    
    _connectionStatus = ConnectionStatusDisconnected;
    _connectionMode = ConnectionModeNone;
    
    [cm cancelPeripheralConnection:currentPeripheral.peripheral];
    
}
#pragma mark UARTPeripheralDelegate


- (void)didReadHardwareRevisionString:(NSString*)string{
    
    //Once hardware revision string is read, connection to Bluefruit is complete
    
    NSLog(@"HW Revision: %@", string);
    
    //Bail if we aren't in the process of connecting
    if (currentAlertView == nil){
        return;
    }
    
    _connectionStatus = ConnectionStatusConnected;
    
    
    
    //Dismiss Alert view & update main view
    [currentAlertView dismissWithClickedButtonIndex:-1 animated:NO];
    
    currentAlertView = nil;
    
    
}


- (void)uartDidEncounterError:(NSString*)error{
    
    //Dismiss "scanning …" alert view if shown
    if (currentAlertView != nil) {
        [currentAlertView dismissWithClickedButtonIndex:0 animated:NO];
    }
    
    //Display error alert
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                   message:error
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
    
    [alert show];
    
}


- (void)didReceiveData:(NSData*)newData{
    
    //Data incoming from UART peripheral, forward to current view controller
    
    //Debug
    //    NSString *hexString = [newData hexRepresentationWithSpaces:YES];
    //    NSLog(@"Received: %@", newData);
    
    if (_connectionStatus == ConnectionStatusConnected || _connectionStatus == ConnectionStatusScanning) {
        //UART
        if (_connectionMode == ConnectionModeUART) {
            //send data to UART Controller
            [self receiveData:newData];
        }
    }
}


- (void)peripheralDidDisconnect{
    
    //respond to device disconnecting
    
    //if we were in the process of scanning/connecting, dismiss alert
    if (currentAlertView != nil) {
        [self uartDidEncounterError:@"Peripheral disconnected"];
    }
    
    //if status was connected, then disconnect was unexpected by the user, show alert
    
    
    //display disconnect alert
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Disconnected"
                                                   message:@"BLE peripheral has disconnected"
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles: nil];
    
    [alert show];
    
    
    _connectionStatus = ConnectionStatusDisconnected;
    _connectionMode = ConnectionModeNone;
    
    //dereference mode controllers
    
    //make reconnection available after short delay
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}


- (void)alertBluetoothPowerOff{
    
    //Respond to system's bluetooth disabled
    
    NSString *title     = @"Bluetooth Power";
    NSString *message   = @"You must turn on Bluetooth in Settings in order to connect to a device";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}


- (void)alertFailedConnection{
    
    //Respond to unsuccessful connection
    
    NSString *title     = @"Unable to connect";
    NSString *message   = @"Please check power & wiring,\nthen reset your Arduino";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
}


-(void)tryToConnect {
    //Called by Pin I/O or UART Monitor connect buttons
    
    if (currentAlertView != nil && currentAlertView.isVisible) {
        NSLog(@"ALERT VIEW ALREADY SHOWN");
        return;
    }
    
    NSLog(@"Starting UART Mode …");
    _connectionStatus = ConnectionStatusScanning;
    _connectionMode = ConnectionModeUART;
    
    
    [self scanForPeripherals];
    
    currentAlertView = [[UIAlertView alloc]initWithTitle:@"Scanning …"
                                                 message:nil
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:nil];
    
    [currentAlertView show];
}


@end
