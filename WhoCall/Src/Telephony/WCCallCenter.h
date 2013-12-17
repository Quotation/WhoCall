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

@property (nonatomic, copy) void (^callEventHandler)(WCCall *call);

@end
