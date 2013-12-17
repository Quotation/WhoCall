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
         withCompletion:(void(^)(NSString *liarInfo))completion
{
    // 测试：
//    phoneNumber = @"01053202011";   // 广告
//    phoneNumber = @"15306537056";   // 快递
    
    NSString *cachedInfo = [self.cache objectForKey:phoneNumber];
    if (cachedInfo && completion) {
        completion(cachedInfo);
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
        NSString *detail = @"";
        
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
                    detail = [liarInfo substringWithRange:NSMakeRange(begin, rngEndStrong.location - begin)];
                    detail = [detail stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
                }
            }
            
            // 没有具体信息再判断个大概的类型（旧代码，其实没啥用了）
            if (detail.length == 0) {
                NSDictionary *keywords = @{@"广告"    : @(kWCLiarPhoneAd),
                                           @"推销"    : @(kWCLiarPhoneAd),
                                           @"响一声"   : @(kWCLiarPhoneCheat),
                                           @"欺诈"    : @(kWCLiarPhoneCheat),
                                           @"快递"    : @(kWCLiarPhonePostman)};
                
                WCLiarPhoneType type = kWCLiarPhoneOther;
                for (NSString *key in keywords.keyEnumerator) {
                    if ([liarInfo rangeOfString:key].location != NSNotFound) {
                        type = [keywords[key] integerValue];
                        break;
                    }
                }
                
                switch (type) {
                    case kWCLiarPhoneNone:
                        break;
                    case kWCLiarPhoneAd:
                        detail = @"广告推销";
                        break;
                    case kWCLiarPhoneCheat:
                        detail = @"欺诈电话";
                        break;
                    case kWCLiarPhonePostman:
                        detail = @"快递员";
                        break;
                    default:
                        detail = @"疑似骚扰电话";
                        break;
                }
            }
        }
        
        if (!detail) {
            detail = @"";
        }
        
        [self.cache setObject:detail forKey:phoneNumber];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(detail);
            });
        }
    });
}

@end
