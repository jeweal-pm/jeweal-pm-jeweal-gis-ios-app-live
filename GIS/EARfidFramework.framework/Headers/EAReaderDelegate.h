//
//  Header.h
//  ATIDDemo
//
//  Created by ATID 
//  Copyright (c) 2015년 ATID. All rights reserved.
//

#ifndef ATIDDemo_Header_h
#define ATIDDemo_Header_h

#import "EARfidValues.h"
#import "EAPacket.h"
#import "EABarcodeType.h"

#define REMOTE_KEY_UP           0
#define REMOTE_KEY_DOWN         1

@class EAReader;
@protocol EAReaderDelegate <NSObject>

@optional
- (void)readerInitialized:(EAReader *)reader;
- (void)deviceStateChange:(ResultType)error;
- (void)readTagResult:(NSString *)tag rssi:(float)rssi phase:(float)phase;
- (void)changedActionState:(CommandType)action;
- (void)changedRemoteKey:(int)state;
- (void)barcodeScan:(BarcodeType)barcodeType codeId:(NSString *)codeId barcode:(NSString *)barcode;
- (void)tagAccessResult:(ResultType)error actionState:(CommandType)action epc:(NSString *)epc data:(NSString *)data rssi:(float)rssi phase:(float)phase;
- (void)tagAccessResultWithFreq:(ResultType)error actionState:(CommandType)action epc:(NSString *)epc data:(NSString *)data rssi:(float)rssi phase:(float)phase freq:(float)freq;
- (void)commandComplete:(CommandType)command;
- (void)opmodesetting:(int)mode;
- (void)powergainchange:(int)gain;
- (void)triggerKeyEvent:(int)triggerKey event:(int)event;
- (void)usbConnectEvent:(int)usbconnect event:(int)event;
@end

#endif
