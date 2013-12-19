//
//  WCLiarPhoneList.m
//  WhoCall
//
//  Created by Wang Xiaolei on 10/1/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import "WCLiarPhoneList.h"

@interface WCLiarPhoneList ()

@property (strong, nonatomic) NSCache *cache;

@end

@implementation WCLiarPhoneList

+ (instancetype)sharedList
{
    static WCLiarPhoneList *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WCLiarPhoneList alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)checkLiarNumber:(NSString *)phoneNumber
         withCompletion:(void(^)(WCLiarPhoneType liarType, NSString *liarDetail))completion
{
    // 测试：
//    phoneNumber = @"01053202011";   // 广告
//    phoneNumber = @"15306537056";   // 快递
    
    NSDictionary *cachedInfo = [self.cache objectForKey:phoneNumber];
    if (cachedInfo && completion) {
        WCLiarPhoneType type = (WCLiarPhoneType)[cachedInfo[@"type"] integerValue];
        NSString *info = cachedInfo[@"info"];
        completion(type, info);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 用百度搜索号码，从搜索结果开头获取信息。
        // 模拟桌面Chrome浏览器，避免被百度屏蔽掉。
        NSString *escaped = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                  NULL,
                                                                                                  (__bridge CFStringRef)phoneNumber,
                                                                                                  NULL,
                                                                                                  CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                                  kCFStringEncodingUTF8));
        NSURL *searchURL = [NSURL URLWithString:[@"http://www.baidu.com/s?wd=" stringByAppendingString:escaped]];
        NSString *searchResult = [NSString stringWithContentsOfURL:searchURL
                                                       httpHeaders:@{@"User-Agent": @"Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36"}
                                                          encoding:NSUTF8StringEncoding
                                                             error:NULL];
        
        NSRegularExpression *liarNodeRegex = [NSRegularExpression
                                              regularExpressionWithPattern:@"<div[^<]*class=\"[^\"]*op_liarphone2_word(.+?)</div>"
                                              options:(NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators)
                                              error:NULL];
        
        NSRange rngLiar = [liarNodeRegex rangeOfFirstMatchInString:searchResult
                                                           options:0
                                                             range:NSMakeRange(0, searchResult.length)];
        NSString *liarDetail = @"";
        WCLiarPhoneType liarType = kWCLiarPhoneNone;

        if (rngLiar.location != NSNotFound) {
            NSString *liarInfo = [searchResult substringWithRange:rngLiar];
            
            // 如果有具体的信息就用
            NSRange rngStrong = [liarInfo rangeOfString:@"<strong>"];
            if (rngStrong.location != NSNotFound) {
                NSUInteger begin = rngStrong.location + rngStrong.length;
                NSRange rngEndStrong = [liarInfo rangeOfString:@"</"
                                                       options:NSLiteralSearch
                                                         range:NSMakeRange(begin, liarInfo.length - begin)];
                if (rngEndStrong.location != NSNotFound) {
                    liarDetail = [liarInfo substringWithRange:NSMakeRange(begin, rngEndStrong.location - begin)];
                    liarDetail = [liarDetail stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
                }
            }
            
            // 判断类型
            NSDictionary *keywords = @{@"广告"    : @(kWCLiarPhoneAd),
                                       @"推销"    : @(kWCLiarPhoneAd),
                                       @"响一声"   : @(kWCLiarPhoneCheat),
                                       @"欺诈"    : @(kWCLiarPhoneCheat),
                                       @"快递"    : @(kWCLiarPhonePostman)};
            
            liarType = kWCLiarPhoneOther;
            for (NSString *key in keywords.keyEnumerator) {
                if ([liarInfo rangeOfString:key].location != NSNotFound) {
                    liarType = [keywords[key] integerValue];
                    break;
                }
            }
        }
        
        
        if (liarDetail.length == 0) {
            liarType = kWCLiarPhoneNone;
            liarDetail = @"";
        }
        
        [self.cache setObject:@{@"type": @(liarType), @"info": liarDetail}
                       forKey:phoneNumber];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(liarType, liarDetail);
            });
        }
    });
}

@end
