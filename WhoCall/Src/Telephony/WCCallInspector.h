//
//  WCCallInspector.h
//  WhoCall
//
//  Created by Wang Xiaolei on 11/18/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCCallInspector : NSObject

+ (instancetype)sharedInspector;

// 来电信息播报选项
@property (nonatomic, assign) BOOL handleLiarPhone;
@property (nonatomic, assign) BOOL handlePhoneLocation;
@property (nonatomic, assign) BOOL handleContactName;

// 挂断选项
@property (nonatomic, assign) BOOL hangupAdsCall;
@property (nonatomic, assign) BOOL hangupCheatCall;

// 保存设置项
- (void)saveSettings;

// 开始、停止检测来电
- (void)startInspect;
- (void)stopInspect;

@end
