//
//  WCAddressBook.h
//  WhoCall
//
//  Created by Wang Xiaolei on 10/1/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCAddressBook : NSObject

+ (instancetype)defaultAddressBook;

- (BOOL)isContactPhoneNumber:(NSString *)number;
- (NSString *)contactNameForPhoneNumber:(NSString *)number;

@end
