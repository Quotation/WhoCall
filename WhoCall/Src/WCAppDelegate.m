//
//  WCAppDelegate.m
//  WhoCall
//
//  Created by Wang Xiaolei on 11/17/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import "WCAppDelegate.h"
#import "WCSettingViewController.h"
#import "WCCallInspector.h"
@import AVFoundation;

@interface WCAppDelegate ()

@property (assign, nonatomic) UIBackgroundTaskIdentifier bgTask;
@property (assign, nonatomic) BOOL background;
@property (strong, nonatomic) dispatch_block_t expirationHandler;
@property (assign, nonatomic) BOOL jobExpired;

@end

@implementation WCAppDelegate

- (void)mmp_setUpAudioSession
{
    // AudioSession functions are deprecated from iOS 7.0, so prefer using AVAudioSession
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    if ([audioSession respondsToSelector:@selector(setCategory:withOptions:error:)]) {
        NSError *activeSetError = nil;
        [audioSession setActive:YES
                          error:&activeSetError];
        
        if (activeSetError) {
            MMPALog(@"Error activating AVAudioSession: %@", activeSetError);
        }
        
        NSError *categorySetError = nil;
        [audioSession setCategory:AVAudioSessionCategoryPlayback
                      withOptions:AVAudioSessionCategoryOptionMixWithOthers
                            error:&categorySetError];
        
        if (categorySetError) {
            MMPALog(@"Error setting AVAudioSession category: %@", categorySetError);
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"    // supress deprecated warning
        
        // Initialize audio session
        AudioSessionInitialize
        (
         NULL, // Use NULL to use the default (main) run loop.
         NULL, // Use NULL to use the default run loop mode.
         NULL, // A reference to your interruption listener callback function.
         // See “Responding to Audio Session Interruptions” in Apple's "Audio Session Programming Guide" for a description of how to write
         // and use an interruption callback function.
         NULL  // Data you intend to be passed to your interruption listener callback function when the audio session object invokes it.
         );
        
        // Activate audio session
        OSStatus activationResult = 0;
        activationResult          = AudioSessionSetActive(true);
        
        if (activationResult)
        {
            MMPDLog(@"AudioSession is active");
        }
        
        // Set up audio session category to kAudioSessionCategory_MediaPlayback.
        // While playing sounds using this session category at least every 10 seconds, the iPhone doesn't go to sleep.
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback; // Defines a new variable of type UInt32 and initializes it with the identifier
        // for the category you want to apply to the audio session.
        AudioSessionSetProperty
        (
         kAudioSessionProperty_AudioCategory, // The identifier, or key, for the audio session property you want to set.
         sizeof(sessionCategory),             // The size, in bytes, of the property value that you are applying.
         &sessionCategory                     // The category you want to apply to the audio session.
         );
        
        // Set up audio session playback mixing behavior.
        // kAudioSessionCategory_MediaPlayback usually prevents playback mixing, so we allow it here. This way, we don't get in the way of other sound playback in an application.
        // This property has a value of false (0) by default. When the audio session category changes, such as during an interruption, the value of this property reverts to false.
        // To regain mixing behavior you must then set this property again.
        
        // Always check to see if setting this property succeeds or fails, and react appropriately; behavior may change in future releases of iPhone OS.
        OSStatus propertySetError = 0;
        UInt32 allowMixing        = true;
        
        propertySetError = AudioSessionSetProperty
        (
         kAudioSessionProperty_OverrideCategoryMixWithOthers, // The identifier, or key, for the audio session property you want to set.
         sizeof(allowMixing),                                 // The size, in bytes, of the property value that you are applying.
         &allowMixing                                         // The value to apply to the property.
         );
        
        if (propertySetError)
        {
            MMPALog(@"Error setting kAudioSessionProperty_OverrideCategoryMixWithOthers: %ld", (long)propertySetError);
        }
        
#pragma clang diagnostic pop
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self mmp_setUpAudioSession];
    
    UIApplication* app = [UIApplication sharedApplication];
    
    __weak WCAppDelegate* selfRef = self;
    
    self.expirationHandler = ^{
        [app endBackgroundTask:selfRef.bgTask];
        selfRef.bgTask = UIBackgroundTaskInvalid;
        selfRef.bgTask = [app beginBackgroundTaskWithExpirationHandler:selfRef.expirationHandler];
        NSLog(@"Expired");
        selfRef.jobExpired = YES;
        while(selfRef.jobExpired) {
            // spin while we wait for the task to actually end.
            [NSThread sleepForTimeInterval:1];
        }
        // Restart the background task so we can run forever.
        [selfRef startBackgroundTask];
    };
    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:self.expirationHandler];
    
    // Assume that we're in background at first since we get no notification from device that we're in background when
    // app launches immediately into background (i.e. when powering on the device or when the app is killed and restarted)
    [self monitorBatteryStateInBackground];
    
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

- (void)monitorBatteryStateInBackground
{
    self.background = YES;
    [self startBackgroundTask];
}

- (void)startBackgroundTask
{
    NSLog(@"Restarting task");
    // Start the long-running task.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // When the job expires it still keeps running since we never exited it. Thus have the expiration handler
        // set a flag that the job expired and use that to exit the while loop and end the task.
        while(self.background && !self.jobExpired)
        {
            [NSThread sleepForTimeInterval:1];
            //            NSTimeInterval backgroundTimeRemaining = [[UIApplication sharedApplication] backgroundTimeRemaining];
            //            NSLog(@"Background Time Remaining = %.02f Seconds",backgroundTimeRemaining);
        }
        self.jobExpired = NO;
    });
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
    NSLog(@"Entered background");
    [self monitorBatteryStateInBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"App is active");
    self.background = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
