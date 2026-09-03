//
//  EAParamHelper.h
//  EARfidFramework
//
//  Created by ATID 
//  Copyright (c) 2015년 Alluser.net Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EAParamValue.h"

#define MAX_BUFFER_SIZE     4096

@interface EAParamHelper : NSObject
+(NSData *)setBytesWithParamValue:(EAParamValue *)paramName;
+(NSData *)getBytesWithParamName:(NSNumber *)paramName;
+(NSData *)getBytesWithParamNames:(NSArray *)paramNames;
+(NSData *)getBytesWithParamList:(NSArray *)paramList;
+(EAParamValue *)getParam:(NSData *)data;
+(NSArray *)getParamList:(NSData *)data;
@end
