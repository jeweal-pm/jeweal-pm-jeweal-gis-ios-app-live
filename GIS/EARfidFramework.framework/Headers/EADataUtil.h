//
//  EADataUtil.h
//  ATIDDemo
//
//  Created by ATID 
//  Copyright (c) 2015년 ATID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EADataUtil : NSObject

+ (NSString *)dump:(NSData *)data;
+ (NSString *)getHexString:(NSData *)data;
+ (NSString *)getHexString:(NSData *)data offset:(int)offset length:(int)length;
+ (NSInteger)indexOf:(NSData *)data find:(uint8_t)value;
+ (NSInteger)indexOfWithArray:(NSData *)data find:(NSData *)values;
+ (NSRange)findDataWidthRange:(NSData *)data withPrefix:(uint8_t)prefix withSuffix1:(uint8_t)suffix1 withSuffix2:(uint8_t)suffix2;
+ (NSRange)findhexDataWidthRange:(NSData *)data withPrefix:(uint8_t)prefix withSuffix1:(uint8_t)suffix1 withSuffix2:(uint8_t)suffix2;
@end
