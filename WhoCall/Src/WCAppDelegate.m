//
//  WCAppDelegate.m
//  WhoCall
//
//  Created by Wang Xiaolei on 11/17/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import "WCAppDelegate.h"
#import "WCSettingViewController.h"
#import "MMPDeepSleepPreventer.h"
#import "WCCallInspector.h"

@interface WCAppDelegate ()

@property (nonatomic, strong) MMPDeepSleepPreventer *sleepPreventer;
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTaskID;

@end

@implementation WCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // prevent sleep
    self.sleepPreventer = [[MMPDeepSleepPreventer alloc] init];
    
    // 必须正确处理background task，才能在后台发声
    self.bgTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskID];
        self.bgTaskID = UIBackgroundTaskInvalid;
    }];
    
    // call inspector
    [[WCCallInspector sharedInspector] startInspect];
    
    // UI
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIStoryboard *settingStoryboard = [UIStoryboard storyboardWithName:@"WCSetting" bundle:nil];
    // use storyboard for static content tableview
    WCSettingViewController *mainController = [settingStoryboard instantiateViewControllerWithIdentifier:@"Setting"];
    UINavigationController *rootNav = [[UINavigationController alloc] initWithRootViewController:mainController];
    
    self.window.rootViewController = rootNav;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self.sleepPreventer startPreventSleep];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self.sleepPreventer stopPreventSleep];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
