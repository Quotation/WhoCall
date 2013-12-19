//
//  WCLiarPhoneList.h
//  WhoCall
//
//  Created by Wang Xiaolei on 10/1/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WCLiarPhoneType) {
    kWCLiarPhoneNone,
    kWCLiarPhoneAd,
    kWCLiarPhoneCheat,
    kWCLiarPhonePostman,
    kWCLiarPhoneOther,
};

@interface WCLiarPhoneList : NSObject

+ (instancetype)sharedList;

// 检查是否为骚扰电话以及具体类型，`liarInfo`可能为空字符串表示非骚扰电话
- (void)checkLiarNumber:(NSString *)phoneNumber
         withCompletion:(void(^)(WCLiarPhoneType liarType, NSString *liarDetail))completion;

@end
