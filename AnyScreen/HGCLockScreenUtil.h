//
//  HGCLockScreenUtil.h
//  AnyScreen
//
//  Created by Jymn_Chen on 2017/5/23.
//  Copyright © 2017年 xindawn. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HGCLockScreenStateDidChangeNotification   @"HGCLockScreenStateDidChangeNotification"

@interface HGCLockScreenUtil : NSObject

+ (BOOL)isScreenLocked;
+ (void)observe;
+ (void)unobserve;

@end
