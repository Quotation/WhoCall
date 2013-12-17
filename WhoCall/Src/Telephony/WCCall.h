//
//  WCCall.h
//  WhoCall
//
//  Created by Wang Xiaolei on 11/18/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreTelephony;

// private API
typedef NS_ENUM(short, CTCallStatus) {
    kCTCallStatusCallIn = 4,
    kCTCallStatusHungUp = 5
};

@interface WCCall : NSObject

@property (nonatomic, assign) CTCallStatus callStatus;
@property (nonatomic, copy) NSString *phoneNumber;

@end
