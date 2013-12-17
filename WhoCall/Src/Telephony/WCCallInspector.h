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

@property (nonatomic, assign) BOOL handleLiarPhone;
@property (nonatomic, assign) BOOL handlePhoneLocation;
@property (nonatomic, assign) BOOL handleContactName;

- (void)startInspect;
- (void)stopInspect;

- (void)saveSettings;

@end
