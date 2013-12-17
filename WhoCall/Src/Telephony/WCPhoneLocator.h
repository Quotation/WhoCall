//
//  WCPhoneLocator.h
//  WhoCall
//
//  Created by Wang Xiaolei on 11/20/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCPhoneLocator : NSObject

+ (instancetype)sharedLocator;

- (NSString *)locationForPhoneNumber:(NSString *)phoneNumber;

@end
