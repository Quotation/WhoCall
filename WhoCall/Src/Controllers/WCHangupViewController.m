//
//  WCHangupViewController.m
//  WhoCall
//
//  Created by Wang Xiaolei on 12/19/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import "WCHangupViewController.h"
#import "WCCallInspector.h"

@interface WCHangupViewController ()

@end

@implementation WCHangupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadHangupSettings];
    [self checkEnableConditions];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Settings

- (void)loadHangupSettings
{
    WCCallInspector *inspector = [WCCallInspector sharedInspector];
    if (IS_IOS7_OR_LATER) {
        // http://stackoverflow.com/questions/19101563/ios-7-private-api-to-disconnect-calls-ctcalldisconnect-does-not-work
        inspector.hangupAdsCall = inspector.hangupCheatCall = NO;
    }
    
    self.switchAds.on = inspector.hangupAdsCall;
    self.switchCheat.on = inspector.hangupCheatCall;
}

- (void)saveHangupSettings
{
    WCCallInspector *inspector = [WCCallInspector sharedInspector];
    inspector.hangupAdsCall = self.switchAds.on;
    inspector.hangupCheatCall = self.switchCheat.on;
    [inspector saveSettings];
}

- (void)checkEnableConditions
{
    BOOL enabled = YES;
    NSString *tipText = @"";
    
    if (IS_IOS7_OR_LATER) {
        enabled = NO;
        tipText = @"自动挂断功能不能在 iOS 7 上使用。";
    } else if (![WCCallInspector sharedInspector].handleLiarPhone) {
        enabled = NO;
        tipText = @"开启“骚扰电话预警”才能使用自动挂断功能。";
    }
    
    self.switchAds.enabled = self.switchCheat.enabled = enabled;
    self.labelDisableTip.text = tipText;
}

#pragma mark - Event Handlers

- (IBAction)onSettingValueChanged:(UISwitch *)sender
{
    [self saveHangupSettings];
}

@end
