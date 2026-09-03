//
//  EADeviceProtocol.h
//  ATIDDemo
//
//  Created by ATID 
//  Copyright (c) 2015년 ATID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EADevice.h"
#import "EARfidValues.h"
#import "EAPacket.h"
#import "EAReaderDelegate.h"

#define WATCHER_INTERVAL        1

@interface EAProtocolX88 : NSObject<EADeviceReadDataDelegate> {
@private
    NSCondition *mRecvSync;
    NSThread *mRecvThread;
    NSThread *mWatchThread;
    NSMutableData *mRecvData;
    NSMutableArray *readdata;
    
    EAPacketManager *mPackets;
    CommandType mAction;
    
    EADevice *mDevice;
    //EAReader *mReader;/*ej_ryu*/
    
//    BOOL isBarcodeMode;
    BOOL mIsBarcodeContinueMode;
    BOOL isUserKeyStop;
}

@property (weak, nonatomic) id<EAReaderDelegate> delegate;
@property (nonatomic, assign) BOOL isBarcodeMode;
@property (nonatomic, assign) int dataType; // mDataType        Tag Data Type : ASCII or HEX
@property (nonatomic, assign) int versionCode; // mVersionCode
@property (nonatomic, assign) BOOL isReportRssi; // mIsReportRssi
@property (strong, nonatomic) EAReader *mReader;

- (id)initWithDevice:(EADevice *)device delegate:(id<EAReaderDelegate>)receiver;
- (void)disconnect;

- (CBPeripheral *)peripheral;
- (CommandType)getAction;

- (NSString *)getProperty:(PropertyType)type;
- (NSString *)getProperty:(PropertyType)type withParameter:(NSString *)param;
- (ResultType)setProperty:(PropertyType)type;
- (ResultType)setProperty:(PropertyType)type withParameter:(NSString *)param;
- (ResultType)command:(CommandType)command;
- (ResultType)command:(CommandType)command withParameter:(NSString *)param;
- (EAResultData *)commandSync:(CommandType)command withParameter:(NSString *)param;
- (ResultType)debug:(DebugType)debugType;
- (ResultType)debug:(DebugType)debugType withParameter:(NSString*)param;
- (EAResultData *)debugSync:(DebugType)command withParameter:(NSString *)param;

- (void)wakeUpBarcode;
- (ResultType)postSSI:(SSICommand)command;
- (ResultType)postSSI:(SSICommand)command withData:(NSData*)data;
- (EAResultData *)sendSSI:(SSICommand)command;
- (EAResultData *)sendSSI:(SSICommand)command withData:(NSData*)data;

// cc barcode
- (NSData *)getBarcodeProperty:(PropertyType)type withParameter:(NSData *)param;
- (EAResultData *)setBarcodeProperty:(PropertyType)type withParameter:(NSData *)param;
- (void)setBarcodeContinueMode:(BOOL)isContinueMode;

- (void) receiveData;
//- (void) setInventorymode:(BOOL)isInventory;/*ej_ryu*/
//- (void) changexon;/*ej_ryu*/
- (void) stopflagoff;
- (void) stopflagon;
- (void)barcodedeviceset: (int)model;
- (int)getbarcodedevice;
- (void)rfiddeviceset: (int)model;
- (int)getrfiddevice;
- (void)charsetset: (int)text;
- (int)getcharset;
- (void)setUSBConnect:(int)state;
- (int)setFirmwareVer: (int) version;
@end
