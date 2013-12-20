//
//  WCCallInspector.m
//  WhoCall
//
//  Created by Wang Xiaolei on 11/18/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

@import AVFoundation;
@import AudioToolbox;
#import "WCCallInspector.h"
#import "WCCallCenter.h"
#import "WCAddressBook.h"
#import "WCLiarPhoneList.h"
#import "WCPhoneLocator.h"


// 保存设置key
#define kSettingKeyLiarPhone        @"com.wangxl.WhoCall.HandleLiarPhone"
#define kSettingKeyPhoneLocation    @"com.wangxl.WhoCall.HandlePhoneLocation"
#define kSettingKeyContactName      @"com.wangxl.WhoCall.HandleContactName"
#define kSettingKeyHangupAdsCall    @"com.wangxl.WhoCall.HangupAdsCall"
#define kSettingKeyHangupCheatCall  @"com.wangxl.WhoCall.HangupCheatCall"


@interface WCCallInspector ()

@property (nonatomic, strong) WCCallCenter *callCenter;
@property (nonatomic, copy) NSString *incomingPhoneNumber;
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

@end


@implementation WCCallInspector

+ (instancetype)sharedInspector
{
    static WCCallInspector *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WCCallInspector alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self loadSettings];
    }
    return self;
}

#pragma mark - Call Inspection

- (void)startInspect
{
    if (self.callCenter) {
        return;
    }
    
    self.callCenter = [[WCCallCenter alloc] init];
    
    __weak WCCallInspector *weakSelf = self;
    self.callCenter.callEventHandler = ^(WCCall *call) { [weakSelf handleCallEvent:call]; };
}

- (void)stopInspect
{
    self.callCenter = nil;
}

- (void)handleCallEvent:(WCCall *)call
{
    // 接通后震动一下（防辐射，你懂的）
    if (call.callStatus == kCTCallStatusConnected) {
        [self vibrateDevice];
    }

    // 来电挂断或接通就停止播报
    if (call.callStatus != kCTCallStatusCallIn) {
        self.incomingPhoneNumber = nil;
        [self stopSpeakText];
        return;
    }
    
    // 以下皆为来电状态处理
    NSString *number = call.phoneNumber;
    self.incomingPhoneNumber = number;
    
    BOOL isContact = [[WCAddressBook defaultAddressBook] isContactPhoneNumber:number];
    
    // 优先播报联系人
    if (self.handleContactName && isContact) {
        NSString *callerName = [[WCAddressBook defaultAddressBook] contactNameForPhoneNumber:number];
        NSString *msg = [NSString stringWithFormat:@"%@ 打来电话", callerName];
        [self notifyMessage:msg forPhoneNumber:number];
        return;
    }
    
    // 检查归属地
    void (^checkPhoneLocation)(void) = ^{
        if (self.handlePhoneLocation && !isContact) {
            NSString *location = [[WCPhoneLocator sharedLocator] locationForPhoneNumber:number];
            if (location) {
                // 注意格式，除了地址，还可以有“本地”等
                NSString *msg = [NSString stringWithFormat:@"%@电话", location];
                [self notifyMessage:msg forPhoneNumber:number];
            }
        }
    };
    
    // 欺诈电话联网查，等待查询结束才能知道要不要提示地点
    if (self.handleLiarPhone && !isContact) {
        [[WCLiarPhoneList sharedList]
         checkLiarNumber:number
         withCompletion:^(WCLiarPhoneType liarType, NSString *liarDetail) {
             if (liarType != kWCLiarPhoneNone) {
                 if ([self shouldHangupLiarType:liarType]) {
                     [self.callCenter disconnectCall:call];
                     
                     NSString *msg = [NSString stringWithFormat:@"已挂断 %@ - %@", liarDetail, number];
                     [self sendLocalNotification:msg];
                 } else {
                     [self notifyMessage:liarDetail forPhoneNumber:number];
                 }
             } else {
                 checkPhoneLocation();
             }
         }];
    } else {
        checkPhoneLocation();
    }
}

- (BOOL)shouldHangupLiarType:(WCLiarPhoneType)liarType
{
    if (   (self.hangupAdsCall && liarType == kWCLiarPhoneAd)
        || (self.hangupCheatCall && liarType == kWCLiarPhoneCheat)) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Settings

- (void)loadSettings
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def registerDefaults:@{
                            kSettingKeyLiarPhone        : @(YES),
                            kSettingKeyPhoneLocation    : @(YES),
                            kSettingKeyContactName      : @(NO),
                            kSettingKeyHangupAdsCall    : @(NO),
                            kSettingKeyHangupCheatCall  : @(NO),
                            }];
    
    self.handleLiarPhone = [def boolForKey:kSettingKeyLiarPhone];
    self.handlePhoneLocation = [def boolForKey:kSettingKeyPhoneLocation];
    self.handleContactName = [def boolForKey:kSettingKeyContactName];
    self.hangupAdsCall = [def boolForKey:kSettingKeyHangupAdsCall];
    self.hangupCheatCall = [def boolForKey:kSettingKeyHangupCheatCall];
}

- (void)saveSettings
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:self.handleLiarPhone forKey:kSettingKeyLiarPhone];
    [def setBool:self.handlePhoneLocation forKey:kSettingKeyPhoneLocation];
    [def setBool:self.handleContactName forKey:kSettingKeyContactName];
    [def setBool:self.hangupAdsCall forKey:kSettingKeyHangupAdsCall];
    [def setBool:self.hangupCheatCall forKey:kSettingKeyHangupCheatCall];
    
    [def synchronize];
}

#pragma mark - Notify Users

- (void)notifyMessage:(NSString *)text forPhoneNumber:(NSString *)phoneNumber
{
    // delay一下保证铃声已经响起，这样声音才不会被打断
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([self.incomingPhoneNumber isEqualToString:phoneNumber]) {
            [self speakText:text];
            // 下一轮提醒
            [self notifyMessage:text afterDealy:5.0 forPhoneNumber:phoneNumber];
        }
    });
}

- (void)notifyMessage:(NSString *)text afterDealy:(NSTimeInterval)delay forPhoneNumber:(NSString *)phoneNumber
{
    // 循环提醒，直到电话号码不匹配（来电挂断）
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([self.incomingPhoneNumber isEqualToString:phoneNumber]) {
            [self speakText:text];
            [self notifyMessage:text afterDealy:delay forPhoneNumber:phoneNumber];
        }
    });
}

- (void)speakText:(NSString *)text
{
    if (text.length == 0) {
        return;
    }
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    utterance.rate = AVSpeechUtteranceMinimumSpeechRate;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.synthesizer = [[AVSpeechSynthesizer alloc] init];
    });
    
    [self.synthesizer speakUtterance:utterance];
}

- (void)stopSpeakText
{
    if (self.synthesizer && self.synthesizer.isSpeaking) {
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
}

- (void)sendLocalNotification:(NSString *)message
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = message;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)vibrateDevice
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
