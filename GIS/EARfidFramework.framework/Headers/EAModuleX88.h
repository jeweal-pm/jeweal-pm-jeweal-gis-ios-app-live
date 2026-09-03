//
//  EAModuleX88.h
//  ATIDDemo
//
//  Created by ATID 
//  Copyright (c) 2015년 ATID. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EAProtocolX88.h"
#import "EARfidValues.h"

#define NIBBLE_UNIT                 4
#define MIN_OFFSET                  16

@protocol EAReaderDelegate;

@interface EAModuleX88 : NSObject {
    EAProtocolX88* mProtocol;
    int mVersionCode;
}

- (id)initWithDevice:(EADevice *)device delegate:(id<EAReaderDelegate>)delegate;

- (id)initWithProtocol:(EAProtocolX88 *)protocol;

- (NSString *)firmwareVersion;
- (NSString *)bleVersion;
- (EAMinMaxValue)powerGainScope;
- (ResultType)readMemory:(BankType)bank offset:(int)offset length:(int)length;
- (ResultType)writeMemory:(BankType)bank offset:(int)offset value:(NSString *)value;
- (ResultType)lock:(int)action mask:(int)mask;
- (ResultType)permaLock:(int)action mask:(int)mask;
- (ResultType)kill:(NSString *)killPassword;
- (ResultType)blockWrite:(BankType)bank offset:(int)offset value:(NSString *)value;
- (ResultType)blockErase:(BankType)bank offset:(int)offset length:(int)length;
- (ResultType)saveStoredTag:(NSString *)tag;

- (MaskTargetType)getMaskTarget:(int)index;
- (void)setMaskTarget:(int)index maskTargetType:(MaskTargetType)target;
- (MaskActionType)getMaskAction:(int)index;
- (void)setMaskAction:(int)index maskActionType:(MaskActionType)action;
- (BankType)getMaskBank:(int)index;
- (void)setMaskBank:(int)index maskBank:(BankType)bank;
- (int)getMaskOffset:(int)index;
- (void)setMaskOffset:(int)index maskOffset:(int)offset;
- (NSArray *)getMask:(int)index;
- (void)setMask:(int)index mask:(NSString *)mask;
- (void)setMask:(int)index mask:(NSString *)mask length:(int)length;

- (BOOL)getMaskUsed:(int)index;
- (void)setMaskUsed:(int)index used:(BOOL)used;

- (void)clearEpcMask;
- (void)saveEpcMask;
- (unsigned long long)getEpcMaskCount;
- (void)addEpcMask:(EASelectMaskEPCParam *)param;
- (EASelectMaskEPCParam *)getEpcMask:(int)index;

- (BOOL)getEpcMaskMatchMethod;
- (void)setEpcMaskMatchMethod:(BOOL)enabled;

- (unsigned long long)getChannelMask;
- (unsigned long long)getChannel;
- (void)setChannel:(long)table;
- (unsigned long long)getChannelFrequency:(int)index;

- (void)setTagDataType:(int)tagData;
- (NSData *)getBarcodeParam:(NSData *)data;  // cc barcode
- (ResultType)setBarcodeParam:(NSData *)data;
- (int)barcodePowerState;
- (void)setBarcodePowerState:(int)state;

// cc barcode
- (int)getBarcodeState;
- (bool)getBarcodeMode;

- (void)setVersionCode:(int)versionCode;

- (void)setDebugMode:(BOOL)enabled;
- (NSData *)getDebugConfig:(NSString *) barcode;

- (NSString *)RFidVersion; /*ej_ryu*/
- (NSString *)BTVersion;

@end
