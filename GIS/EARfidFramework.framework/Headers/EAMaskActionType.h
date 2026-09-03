//
//  EAMaskActionType.h
//  EARfidFramework
//
//  Created by ATID
//  Copyright (c) 2015년 Alluser.net Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EARfidValues.h"

@interface EAMaskActionType : NSObject
+ (NSString *)toString:(MaskActionType)actionType targetType:(MaskTargetType)targetType;
@end
