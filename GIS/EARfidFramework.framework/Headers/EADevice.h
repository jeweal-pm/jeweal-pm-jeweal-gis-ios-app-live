//
//  EADevice.h
//  EARfidFramework
//
//  Created by ATID 
//  Copyright © 2016년 Alluser.net Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EADataUtil.h"

#define BYTE                            unsigned char
#define LPBYTE                          BYTE *

typedef enum {
    Model_Default,
    Model_BT53H,
    Model_BT53H_MFI
} DeviceModel;

// ATBLEDevice Read Data Delegate
@protocol EADeviceReadDataDelegate <NSObject>

- (void)readData:(NSData *)data;
//- (void)setXon;
//- (void)setXoff;
- (BOOL) isInventory;

@end

// ATBLEDevice Init Compelte Delegate
@protocol EADeviceInitializeDelegate <NSObject>

- (void) didCompleteInitialize:(NSError *)error;

@end

@interface EADevice : NSObject
{
}

@property (nonatomic, readwrite) DeviceModel deviceModel;
@property (weak, nonatomic) id<EADeviceReadDataDelegate> delegate;

- (NSString *)name;
- (NSString *)address;

- (void)disconnect;
- (void)writeData:(NSData *)data;
- (void)setxon;
- (void)setxoff;
- (BOOL)isxonoff;

@end
