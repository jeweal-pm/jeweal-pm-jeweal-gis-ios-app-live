//
//  EABarcodeType.h
//  EARfidFramework
//
//  Created by ATID 
//  Copyright (c) 2015년 Alluser.net Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    BarcodeTypeNoRead,
    BarcodeTypeAustralianPost,
    BarcodeTypeAztecCode,
    BarcodeTypeBooklandEAN,
    BarcodeTypeBritishPost,
    BarcodeTypeCanadianPost,
    BarcodeTypeChinaPost,
    BarcodeTypeCodabar,
    BarcodeTypeCodablockF,
    BarcodeTypeCode11,
    BarcodeTypeCode128,
    BarcodeTypeCode16K,
    BarcodeTypeCode32,
    BarcodeTypeCode39,
    BarcodeTypeCode49,
    BarcodeTypeCode93,
    BarcodeTypeComposite,
    BarcodeTypeD2of5,
    BarcodeTypeDataMatrix,
    BarcodeTypeEAN128,
    BarcodeTypeEAN13,
    BarcodeTypeEAN13CouponCode,
    BarcodeTypeEAN8,
    BarcodeTypeI2of5,
    BarcodeTypeIATA,
    BarcodeTypeISBT128,
    BarcodeTypeISBT128Concat,
    BarcodeTypeJapanesePost,
    BarcodeTypeKixPost,
    BarcodeTypeKoreaPost,
    BarcodeTypeMacroMicroPDF,
    BarcodeTypeMaxiCode,
    BarcodeTypeMicroPDF,
    BarcodeTypeMSI,
    BarcodeTypeMultipacketFormat,
    BarcodeTypeOCR,
    BarcodeTypeParameterFNC3,
    BarcodeTypePDF417,
    BarcodeTypePlanetCode,
    BarcodeTypePlesseyCode,
    BarcodeTypePosiCode,
    BarcodeTypePostnet,
    BarcodeTypeQRCode,
    BarcodeTypeR2of5,
    BarcodeTypeRSS,
    BarcodeTypeScanletWebcode,
    BarcodeTypeTelepen,
    BarcodeTypeTLC39,
    BarcodeTypeTriopticCode,
    BarcodeTypeUPCA,
    BarcodeTypeUPCE,
    BarcodeTypeVeriCode,
    BarcodeTypeX2of5,
    BarcodeTypeRSSLimited,
    BarcodeTypeChineseSensible,
    BarcodeTypeRSSExpanded,
    BarcodeTypeInfoMail,
    BarcodeTypeIntelligentMail,
    BarcodeTypePostal4i,
    BarcodeTypeMatrix2of5,
    BarcodeTypeISSN
} BarcodeType;

@interface EABarcodeType : NSObject
+ (BarcodeType)getBarcodeType:(unsigned char)byte;
+ (NSString *)getBarcodeString:(BarcodeType)barcodeType;
+ (BarcodeType)getHBarcodeType:(unsigned char)byte;
@end
