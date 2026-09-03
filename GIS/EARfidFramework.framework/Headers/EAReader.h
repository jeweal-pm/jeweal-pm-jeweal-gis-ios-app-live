//
//  EAReader.h
//  ATIDDemo
//
//  Created by ATID 
//  Copyright (c) 2015년 ATID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EAProtocolX88.h"
#import "EAModuleX88.h"
#import "EAParamValue.h"

#define TAG_PC_LENGTH               4

#define TAG_DATA_TYPE_ASCII         0
#define TAG_DATA_TYPE_HEX           1

#define BARCODE_NONE                0
#define BARCODE_POWER               1
#define BARCODE_AIM                 2
#define BARCODE_TRIGGER             4

#define MIN_SELECTION_MASK          0
#define MAX_SELECTION_MASK          8

#define MAX_CHANNEL                     50
#define BARCODE_MODULE_ENABLED      0x08

#define VER_7_2_5_2                 0x07020502 
#define VER_5_2_2_28                0x0502021C
#define VER_6_0_0_00                0x06000000
#define VERSION_MASK                0x00FFFFFF
#define VER_X_2_2_1                 0x00020201
#define VER_X_2_2_6                 0x00020206
#define VER_X_2_2_20                0x00020214
#define VER_X_2_2_18                0x00020212
#define VER_X_2_2_28                0x0002021C
#define VER_2_2_1_0                 0x02020100
#define VER_5_2_2_0                 0x05020200
#define VER_4_1_1_9                 0x04010109

#define VERSION_PREFIX              @"bl-"
#define VERSION_AT388_PREFIX              @"bd-"
#define VERSION_AT188_PREFIX              @"df-"
#define VERSION_AT188NP_PREFIX            @"pa-"
#define MAX_VERSION                 4

#define EXTEND_BTNMODE              @"notmode"
#define EXTEND_NOTYMODE             @"buttonnot"
#define EXTEND_ALERTNOTY            @"alertnot"

// Declare AlgorithmType Type Codes
typedef enum {
    FixedQ = 0,                 // 'Fixed Q Value'
    DynamicQ = 1                // 'Dynamic Q Value'
} AlgorithmType;

@protocol EAReaderDelegate;

@interface EAReader : NSObject {
@private
    EAProtocolX88 *mProtocol;
    EAModuleX88 *mModule;
    
    CommandType mAction;
    BOOL mIsResult;
    BOOL mIsBarcodeMode;
    
    int mVersionCode;
    
    NSMutableArray *mChannelMask;
}

- (id)initWithDevice:(EADevice *)device delegate:(id<EAReaderDelegate>)delegate;
// cc 20160412
- (id)initWithBTDevice:(EADevice *)device delegate:(id<EAReaderDelegate>)delegate;
- (void)disconnect;

- (CommandType)getAction;
- (void)setDelegate:(id<EAReaderDelegate>)delegate;

// Action Command Methods
- (ResultType)inventory;
- (ResultType)readMemory:(BankType)bank offset:(int)offset length:(int)length;
- (ResultType)writeMemory:(BankType)bank offset:(int)offset value:(NSString *)value;
- (ResultType)lock:(LockParam *)param;
- (ResultType)unlock:(LockParam *)param;
- (ResultType)permaLock:(LockParam *)param;
- (ResultType)kill:(NSString *)killPassword;
- (ResultType)blockWrite:(BankType)bank offset:(int)offset value:(NSString *)value;
- (ResultType)blockErase:(BankType)bank offset:(int)offset length:(int)length;

- (ResultType)stop;
- (ResultType)stopSync; // cc barcode

// Configuration Command Methods
- (ResultType)loadStoredData;
- (ResultType)saveStoredTag:(NSString *)tag;
- (ResultType)deleteAllStoredData;
- (ResultType)softReset;
- (ResultType)hardReset;
- (ResultType)defaultParameter;
- (ResultType)saveParameter;
- (ResultType)setDebugMode:(BOOL)enabled;
- (ResultType)loadDebugMessage;
- (ResultType)enterBypassMode;
- (ResultType)enterBarcodeBypassMode;
- (ResultType)leaveBypassMode;

// Peroperties Methods
- (NSString *)firmwareVersion;
- (NSString *)bleVersion;
- (NSString *)RFidVersion; /*ej_ryu*/
- (NSString *)BTVersion; /*ej_ryu*/
- (NSString *)frameworkVersion; /*ej_ryu*/
- (EAMinMaxValue)powerGainScope;

- (int)storedCount;

- (int)batteryStatus;
- (int)battery10Status;
- (int)batteryPercentage;

- (ResultType)clearEpcMask;
- (ResultType)saveEpcMask;
- (int)epcMaskCount;
- (ResultType)addEpcMask:(int) offset length:(int)length mask:(NSString *)mask;
- (ResultType)addEpcMask:(EASelectMaskEPCParam *)mask;
- (EASelectMaskEPCParam *)getEpcMask:(int)index;

- (NSArray *)getChannelMask;
- (NSArray *)getChannel;
- (void)setChannel:(NSArray *)table;
- (NSString *)getChannelFrequency:(int)slot;

- (void)wakeUpBarcode;
- (ResultType)startScan;
- (ResultType)stopScan;
- (ResultType)setBarcodeParam:(NSArray *)paramData;
- (NSArray *)getBarcodeParam:(NSArray *)paramData;
- (ResultType)setBarcodeDataParam:(NSData *)paramData;
- (ResultType)aimOff;
- (ResultType)aimOn;
- (NSString *)getRevision;
- (ResultType)ledOff;
- (ResultType)ledOn;

- (BOOL)usedSelectionMask:(int)index;
- (EASelectMaskParam *)getSelectionMask:(int)index;
- (void)setSelectionMask:(int)index withParam:(EASelectMaskParam *)param;

- (void)removeSelectionMask:(int)index;
- (void)clearSelectionMask;

@property (nonatomic, strong) EADevice *mDevice;

@property (nonatomic, assign) BuzzerState buzzer;
@property (nonatomic, assign) RegionType region;
@property (nonatomic, assign) int operationTime;
@property (nonatomic, assign) int inventoryTime;
@property (nonatomic, assign) int idleTime;
@property (nonatomic, assign) int sameReportTime;
@property (nonatomic, assign) int autoOffTime;
@property (nonatomic, strong) NSString *accessPassword;
@property (nonatomic, assign) SessionType inventorySession;
@property (nonatomic, assign) SessionFlag sessionFlag;
@property (nonatomic, strong) EASelectMaskParam *selectionMask;

@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSString *serialNumber;
@property (nonatomic, strong) NSString *deviceTime; /* ej_ryu*/
@property (nonatomic, assign) int displayOffTime; /* ej_ryu*/
@property (nonatomic, assign) int extendBtnmode; /* ej_ryu*/
@property (nonatomic, assign) int extendNotMode; /* ej_ryu*/
@property (nonatomic, assign) int extendAlertNoty; /* ej_ryu*/
@property (nonatomic, assign) BOOL autosaveMode; /* ej_ryu*/
@property (nonatomic, assign) int tidlength;    /* ej_ryu*/
@property (nonatomic, assign) int linkProfile;    /* ej_ryu*/
@property (nonatomic, assign) int defaultProfile;    /* ej_ryu*/
@property (nonatomic, assign) int inventoryTagtype;
@property (nonatomic, assign) int tagdatatype;
@property (nonatomic, strong) NSString *devicemodel;

@property (nonatomic, assign) BOOL remoteMode;

@property (nonatomic, assign) BOOL continuousMode;
@property (nonatomic, assign) int limitTagNumber;

@property (nonatomic, assign) int powerGain;
@property (nonatomic, assign) BOOL isUseKeyAction;

@property (nonatomic, assign) SelectFlag useSelectionMask;
@property (nonatomic, assign) BOOL reportMode;
@property (nonatomic, assign) BOOL storedMode;
@property (nonatomic, assign) BOOL rssiMode;

//@property (nonatomic, assign) BOOL epcMaskMode; // 프로토콜에 대한 검토가 필요. 변경해야함.

@property (nonatomic, assign) BOOL epcMaskMatchMethod;

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

@property (nonatomic, assign) AlgorithmType algorithm;
- (AlgorithmType)getAlgorithm;

@property (nonatomic, assign) int minQ;
@property (nonatomic, assign) int maxQ;
@property (nonatomic, assign) int startQ;

- (NSString *)getRegister;
- (void)setRegister:(NSString *)value;

// cc Barcode
- (ResultType)setBarcodeMode:(int)enabled isKeyAction:(BOOL)isKeyOn;
- (BOOL)isBarcodeModule;
- (void)setBarcodeContinueMode:(BOOL)isContinueMode;
- (void)setPropBarcodeMode:(int)mode;
- (int)PropBarcodeMode;
- (void)setTagDataType:(int)value;

/*+ ej_ryu +*/
- (NSArray *)devicesymbolInit;
- (void)stopflagon;
- (void)stopflagoff;
- (void)barcodedeviceset: (int)model;
- (int)barcodedeviceget;
- (void)rfiddedeviceset: (int)model;
- (int)rfiddeviceget;
- (void)charsetset: (int)text;
- (int)charsetget;
- (void)setSerialNumber:(NSString *)serialNo password:(NSString *)password;
- (void)setRegion:(RegionType)region password:(NSString *)password;
- (void)setUSBConnect:(int)state;
- (ResultType)setCarrierWave:(int)data;
/*- ej_ryu-*/
@end
