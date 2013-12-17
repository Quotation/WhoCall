//
//  WCCallCenter.m
//  WhoCall
//
//  Created by Wang Xiaolei on 11/18/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import "WCCallCenter.h"

// encrypted string's
#define ENCSTR_kCTCallStatusChangeNotification  [@"n0AHD2SfoSA0LKE1p0AbLJ5aMH5iqTyznJAuqTyiot==" wcDecryptString]
#define ENCSTR_kCTCall                          [@"n0AHD2SfoN==" wcDecryptString]
#define ENCSTR_kCTCallStatus                    [@"n0AHD2SfoSA0LKE1pj==" wcDecryptString]
#define ENCSTR_CTTelephonyCenterGetDefault      [@"D1EHMJkypTuioayQMJ50MKWUMKERMJMuqJk0" wcDecryptString]
#define ENCSTR_CTTelephonyCenterAddObserver     [@"D1EHMJkypTuioayQMJ50MKWOMTECLaAypaMypt==" wcDecryptString]
#define ENCSTR_CTTelephonyCenterRemoveObserver  [@"D1EHMJkypTuioayQMJ50MKWFMJ1iqzICLaAypaMypt==" wcDecryptString]
#define ENCSTR_CTCallCopyAddress                [@"D1EQLJkfD29jrHSxMUWyp3Z=" wcDecryptString]

// private API
//extern NSString *CTCallCopyAddress(void*, CTCall *);
typedef NSString *(*PF_CTCallCopyAddress)(void*, CTCall *);

//extern CFNotificationCenterRef CTTelephonyCenterGetDefault();
typedef CFNotificationCenterRef (*PF_CTTelephonyCenterGetDefault)();

//extern void CTTelephonyCenterAddObserver(CFNotificationCenterRef center,
//                                         const void *observer,
//                                         CFNotificationCallback callBack,
//                                         CFStringRef name,
//                                         const void *object,
//                                         CFNotificationSuspensionBehavior suspensionBehavior);
typedef void (*PF_CTTelephonyCenterAddObserver)(CFNotificationCenterRef center,
                                                const void *observer,
                                                CFNotificationCallback callBack,
                                                CFStringRef name,
                                                const void *object,
                                                CFNotificationSuspensionBehavior suspensionBehavior);

//extern void CTTelephonyCenterRemoveObserver(CFNotificationCenterRef center,
//                                            const void *observer,
//                                            CFStringRef name,
//                                            const void *object);
typedef void (*PF_CTTelephonyCenterRemoveObserver)(CFNotificationCenterRef center,
                                                   const void *observer,
                                                   CFStringRef name,
                                                   const void *object);


@interface WCCallCenter ()

- (void)handleCall:(CTCall *)call withStatus:(CTCallStatus)status;

@end

@implementation WCCallCenter

- (id)init
{
    self = [super init];
    if (self) {
        [self registerCallHandler];
    }
    return self;
}

- (void)dealloc
{
    [self deregisterCallHandler];
}

- (void)registerCallHandler
{
    static PF_CTTelephonyCenterAddObserver AddObserver;
    static PF_CTTelephonyCenterGetDefault GetCenter;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AddObserver = [WCDL loadSymbol:ENCSTR_CTTelephonyCenterAddObserver];
        GetCenter = [WCDL loadSymbol:ENCSTR_CTTelephonyCenterGetDefault];
    });
    
    AddObserver(GetCenter(),
                (__bridge void *)self,
                &callHandler,
                (__bridge CFStringRef)(ENCSTR_kCTCallStatusChangeNotification),
                NULL,
                CFNotificationSuspensionBehaviorHold);
}

- (void)deregisterCallHandler
{
    static PF_CTTelephonyCenterRemoveObserver RemoveObserver;
    static PF_CTTelephonyCenterGetDefault GetCenter;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RemoveObserver = [WCDL loadSymbol:ENCSTR_CTTelephonyCenterRemoveObserver];
        GetCenter = [WCDL loadSymbol:ENCSTR_CTTelephonyCenterGetDefault];
    });
    
    RemoveObserver(GetCenter(),
                   (__bridge void *)self,
                   (__bridge CFStringRef)(ENCSTR_kCTCallStatusChangeNotification),
                   NULL);
}

- (void)handleCall:(CTCall *)call withStatus:(CTCallStatus)status
{
    static PF_CTCallCopyAddress CopyAddress;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CopyAddress = [WCDL loadSymbol:ENCSTR_CTCallCopyAddress];
    });

    if (!self.callEventHandler || !call) {
        return;
    }
    
    WCCall *wcCall = [[WCCall alloc] init];
    wcCall.phoneNumber = CopyAddress(NULL, call);
    wcCall.callStatus = status;
    
    self.callEventHandler(wcCall);
}

static void callHandler(CFNotificationCenterRef center,
                        void *observer,
                        CFStringRef name,
                        const void *object,
                        CFDictionaryRef userInfo)
{
    if (!observer) {
        return;
    }
    
    NSDictionary *info = (__bridge NSDictionary *)(userInfo);
    CTCall *call = (CTCall *)info[ENCSTR_kCTCall];
    CTCallStatus status = (CTCallStatus)[info[ENCSTR_kCTCallStatus] shortValue];
    
    WCCallCenter *wcCenter = (__bridge WCCallCenter*)observer;
    [wcCenter handleCall:call withStatus:status];
}

@end
