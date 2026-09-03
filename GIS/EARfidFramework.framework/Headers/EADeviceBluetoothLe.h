//
//  ATBluetoothLeDevice.h
//  ATIDDemo
//
//  Created by ATID 
//  Copyright (c) 2015년 ATID. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "EADevice.h"

@interface EADeviceBluetoothLe : EADevice<CBPeripheralDelegate>
{
    NSMutableArray *readdata;
    int datavolum;
    
@private
    
    CBUUID const *UUID_SERVICE;
    CBUUID const *UUID_DEVICE_INFO;
    CBUUID const *UUID_SYSTEM_ID;
    CBUUID const *UUID_READ;
    CBUUID const *UUID_WRITE;

    CBPeripheral *mPeripheral;
    CBCharacteristic *mWriter;
    CBCharacteristic *mReader;
    
    CBCharacteristicWriteType mType;
    
    NSString *mAddress;
    
    BOOL mIsSending;
    BOOL mIsEscapeRecv;
    int mEscapePtr;
    BYTE mEscapeData;
    
    BOOL mIsSendCR;
    BOOL mIsSend;
    BOOL mIsEscapeSend;
    NSMutableArray* mRxData;
    
    id<EADeviceInitializeDelegate> mInitCallback;

}

- (NSString *)name;
- (NSString *)address;
- (CBPeripheral *)peripheral;

- (id)initWithPeripheral:(CBPeripheral *)peripheral delegate:(id<EADeviceInitializeDelegate>)callback;
//- (id)initWithPeripheral:(CBPeripheral *)peripheral Service:(CBService *)service WriteCharacteristic:(CBCharacteristic *)write ReadCharacteristic:(CBCharacteristic *)read;
- (void)disconnect;
- (void)writeData:(NSData *)data;
- (void)setxoff;
- (void)setxon;
- (BOOL)isxonoff;

@end
