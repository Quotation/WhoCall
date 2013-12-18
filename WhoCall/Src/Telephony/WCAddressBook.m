//
//  WCAddressBook.m
//  WhoCall
//
//  Created by Wang Xiaolei on 10/1/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import "WCAddressBook.h"
@import AddressBook;

@interface WCAddressBook ()

@property (strong, nonatomic) NSMutableDictionary *allPhoneNumbers;

- (void)reload:(ABAddressBookRef)addressBook;

@end

@implementation WCAddressBook

+ (instancetype)defaultAddressBook
{
    static WCAddressBook *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WCAddressBook alloc] init];
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, NULL);
        [instance reload:addressBook];
        
        ABAddressBookRegisterExternalChangeCallback(addressBook,
                                                    addressBookChangeHandler,
                                                    (__bridge void *)(instance));
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted) {
                [instance reload:addressBook];
            }
        });
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.allPhoneNumbers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)reload:(ABAddressBookRef)addressBook
{
    @synchronized (self) {
        [self.allPhoneNumbers removeAllObjects];
        
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex numberOfPeople = CFArrayGetCount(allPeople);
        for (CFIndex idxPeople = 0; idxPeople < numberOfPeople; idxPeople++) {
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, idxPeople);
            
            NSString *personName = (__bridge_transfer NSString *)(ABRecordCopyCompositeName(person));
            if (!personName) {
                continue;
            }
            
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
            for (CFIndex idxNumber = 0; idxNumber < ABMultiValueGetCount(phoneNumbers); idxNumber++) {
                NSString *phoneNumber = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, idxNumber);
                phoneNumber = [phoneNumber normalizedPhoneNumber];
                if (!phoneNumber) {
                    continue;
                }
                
                self.allPhoneNumbers[phoneNumber] = personName;
            }
            
            CFRelease(phoneNumbers);
        }
        
        CFRelease(allPeople);
    }
}

- (BOOL)isContactPhoneNumber:(NSString *)number
{
    return ([self contactNameForPhoneNumber:number] != nil);
}

- (NSString *)contactNameForPhoneNumber:(NSString *)number {
    number = [number normalizedPhoneNumber];
    @synchronized (self) {
        return self.allPhoneNumbers[number];
    }
}

static void addressBookChangeHandler(ABAddressBookRef addressBook,
                                     CFDictionaryRef info,
                                     void *context)
{
    if (context) {
        [(__bridge WCAddressBook *)context reload:addressBook];
    }
}

@end
