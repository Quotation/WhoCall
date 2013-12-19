//
//  WCCallCenter.h
//  WhoCall
//
//  Created by Wang Xiaolei on 11/18/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WCCall.h"

@interface WCCallCenter : NSObject

// 监听来电事件
@property (nonatomic, copy) void (^callEventHandler)(WCCall *call);

// 挂断电话
- (void)disconnectCall:(WCCall *)call;

@end
