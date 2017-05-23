//
//  HGCLockScreenUtil.m
//  AnyScreen
//
//  Created by Jymn_Chen on 2017/5/23.
//  Copyright © 2017年 xindawn. All rights reserved.
//

#import "HGCLockScreenUtil.h"
#import <UIKit/UIKit.h>

#define HGCSBBlankedScreenNotification  CFSTR("com.apple.springboard.hasBlankedScreen")
#define HGCSBLockCompleteNotification   CFSTR("com.apple.springboard.lockcomplete")
#define HGCSBLockStateNotification      CFSTR("com.apple.springboard.lockstate")

@implementation HGCLockScreenUtil

#pragma mark - Public Methods

+ (BOOL)isScreenLocked {
    return g_isScreenLocked;
}

+ (void)observe {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    CFBridgingRetain(self),
                                    hgc_handleSBBlanedScreenNotification,
                                    HGCSBBlankedScreenNotification,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    CFBridgingRetain(self),
                                    hgc_handleSBLockCompleteNotification,
                                    HGCSBLockCompleteNotification,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    CFBridgingRetain(self),
                                    hgc_handleSBLockStateNotification,
                                    HGCSBLockStateNotification,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(),
                                    CFBridgingRetain(self),
                                    hgc_handleAppDidBecomeActiveNotification,
                                    (__bridge CFStringRef)UIApplicationDidBecomeActiveNotification,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}

+ (void)unobserve {
    CFNotificationCenterRemoveEveryObserver(CFNotificationCenterGetDarwinNotifyCenter(), CFBridgingRetain(self));
    CFNotificationCenterRemoveEveryObserver(CFNotificationCenterGetLocalCenter(), CFBridgingRetain(self));
}

#pragma mark - Notifications Handlers

static BOOL g_recvScreenLockCompEvent;
static BOOL g_isScreenLocked;

/*
 
 1. Normal App in fg -> lock screen -> unlock screen, App in fg
 2. Normal App in bg -> lock screen -> unlock screen, App in bg -> App goto fg
 3. BG Keepalive App in fg -> lock screen -> unlock screen, App in fg
 4. BG Keepalive App in bg -> lock screen -> unlock screen, App in bg -> App goto fg
 
 消息可能是滞留的情况：Normal App in fg -> lock screen -> unlock screen, App in bg -> App goto fg
 因为 Normal App 在后台收不到消息，在进入前台时才会收到
 而 BG Keepalive App 在后台也能收到消息
 
 */

static void hgc_handleAppDidBecomeActiveNotification(CFNotificationCenterRef center,
                                                     void *observer,
                                                     CFStringRef name,
                                                     const void *object,
                                                     CFDictionaryRef userInfo)
{
    BOOL preIsScreenLocked = g_isScreenLocked;
    
    g_recvScreenLockCompEvent = NO;
    g_isScreenLocked = NO;
//    NSLog(@"HGC ** App 进入前台了, isLocked = %zd", g_isScreenLocked);
    
    if (preIsScreenLocked != g_isScreenLocked) {
        hgc_postLockStateChangeNoti();
    }
}

static void hgc_handleSBBlanedScreenNotification(CFNotificationCenterRef center,
                                                 void *observer,
                                                 CFStringRef name,
                                                 const void *object,
                                                 CFDictionaryRef userInfo)
{
//    NSLog(@"HGC ** 显示滑动解锁界面");
}

static void hgc_handleSBLockCompleteNotification(CFNotificationCenterRef center,
                                                 void *observer,
                                                 CFStringRef name,
                                                 const void *object,
                                                 CFDictionaryRef userInfo)
{
    g_recvScreenLockCompEvent = YES;
//    NSLog(@"HGC ** 锁屏了");
}

static void hgc_handleSBLockStateNotification(CFNotificationCenterRef center,
                                              void *observer,
                                              CFStringRef name,
                                              const void *object,
                                              CFDictionaryRef userInfo)
{
    BOOL preIsScreenLocked = g_isScreenLocked;
    
    if (g_recvScreenLockCompEvent) {
        g_isScreenLocked = YES;
    } else {
        g_isScreenLocked = NO;
    }
    
    g_recvScreenLockCompEvent = NO;
//    NSLog(@"HGC ** 锁屏状态变化了, isLocked = %zd", g_isScreenLocked);
    
    if (preIsScreenLocked != g_isScreenLocked) {
        hgc_postLockStateChangeNoti();
    }
}

static void hgc_postLockStateChangeNoti() {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:HGCLockScreenStateDidChangeNotification object:nil];
    });
}

@end
