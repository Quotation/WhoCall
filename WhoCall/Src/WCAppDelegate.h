//
//  WCAppDelegate.h
//  WhoCall
//
//  Created by Wang Xiaolei on 11/17/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef MMPDLog
#ifdef DEBUG
#define MMPDLog(format, ...) NSLog((@"%s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define MMPDLog(...) do { } while (0)
#endif
#endif

#ifndef MMPALog
#define MMPALog(format, ...) NSLog((@"%s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#endif

@interface WCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
