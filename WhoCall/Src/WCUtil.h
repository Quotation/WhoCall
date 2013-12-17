//
//  WCUtil.h
//  WhoCall
//
//  Created by Wang Xiaolei on 11/19/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (WCPhoneNumber)

- (NSString *)normalizedPhoneNumber;

@end


@interface NSString (Encrypt)

- (NSString *)wcEncryptString;
- (NSString *)wcDecryptString;

@end


@interface NSString (URL)

+ (instancetype)stringWithContentsOfURL:(NSURL *)url
                            httpHeaders:(NSDictionary *)httpHeaders
                               encoding:(NSStringEncoding)enc
                                  error:(NSError **)error;

@end


@interface WCDL : NSObject

+ (void *)loadSymbol:(NSString *)symName;

@end
