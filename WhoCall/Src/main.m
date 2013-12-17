//
//  main.m
//  WhoCall
//
//  Created by Wang Xiaolei on 11/17/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WCAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        @try {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([WCAppDelegate class]));
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
    }
}
