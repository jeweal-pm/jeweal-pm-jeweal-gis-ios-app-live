//
//  EAParamValue.h
//  EARfidFramework
//
//  Created by ATID 
//  Copyright (c) 2015년 Alluser.net Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EAParamName.h"

@interface EAParamValue : NSObject
@property (assign, readwrite) ParamName paramName;
@property (assign, readwrite) unsigned int value;

- (void)setEnabled:(BOOL)value;
@end

@interface EADataValue : NSObject
@property (assign, readwrite) NSString* dataName;
@property (assign, readwrite) unsigned int dataValue;

- (void)setDataEnabled:(BOOL)value;
@end
