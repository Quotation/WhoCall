//
//  WCPhoneLocator.m
//  WhoCall
//
//  Created by Wang Xiaolei on 11/20/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import "WCPhoneLocator.h"
#import "FMDatabase.h"

@interface WCPhoneLocator ()

@property (nonatomic, strong) FMDatabase *db;

@end

@implementation WCPhoneLocator

+ (instancetype)sharedLocator
{
    static WCPhoneLocator *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WCPhoneLocator alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        NSString *dbFile = [[NSBundle mainBundle] pathForResource:@"telocation" ofType:@"db"];
        self.db = [FMDatabase databaseWithPath:dbFile];
        
        if (![self.db open]) {
            self.db = nil;
        } else {
            [self.db close];
        }
    }
    
    return self;
}

- (NSString *)locationForPhoneNumber:(NSString *)phoneNumber
{
    phoneNumber = [phoneNumber normalizedPhoneNumber];
    if (phoneNumber.length == 0) {
        return nil;
    }
    
    BOOL isMobilePhone = ([phoneNumber characterAtIndex:0] == '1' && phoneNumber.length == 11);
    BOOL hasAreaCode = ([phoneNumber characterAtIndex:0] == '0');
    BOOL isForeign = (hasAreaCode && phoneNumber.length > 2 && [phoneNumber characterAtIndex:1] == '0');

    NSString *location = nil;
    
    @synchronized (self.db) {
        [self.db open];
        
        if (isMobilePhone) {
            // 手机号取前7位，查到固话区号，再查地址
            NSString *prefix = [phoneNumber substringToIndex:7];
            FMResultSet *s = [self.db executeQuery:@"SELECT areacode FROM mob_location where _id=?", prefix];
            if ([s next]) {
                NSInteger areacode = [s intForColumnIndex:0];
                [s close];
                
                s = [self.db executeQuery:@"SELECT location FROM tel_location where _id=?", @(areacode)];
                if ([s next]) {
                    location = [s stringForColumnIndex:0];
                    [s close];
                }
            }
        } else {
            if (isForeign) {
                location = @"国际长途";
            } else if (hasAreaCode) {
                // 国内长途，首位是1、2则区号为两位，否则区号为3位
                NSString *areacode;
                if (   phoneNumber.length > 3
                    && (   [phoneNumber characterAtIndex:1] == '1'
                        || [phoneNumber characterAtIndex:1] == '2')) {
                    areacode = [phoneNumber substringWithRange:NSMakeRange(1, 2)];
                } else if (phoneNumber.length > 4) {
                    areacode = [phoneNumber substringWithRange:NSMakeRange(1, 3)];
                }
                
                FMResultSet *s = [self.db executeQuery:@"SELECT location FROM tel_location where _id=?", @([areacode integerValue])];
                if ([s next]) {
                    location = [s stringForColumnIndex:0];
                    [s close];
                }
            } else {
                location = @"本地";
            }
        }
        
        [self.db close];
    }
    
    return location;
}

@end
