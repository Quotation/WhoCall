//
//  WCUtil.m
//  WhoCall
//
//  Created by Wang Xiaolei on 11/19/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import "WCUtil.h"
#import <dlfcn.h>

@implementation NSString (WCPhoneNumber)

- (NSString *)normalizedPhoneNumber {
    NSCharacterSet *nonNumericSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789+"] invertedSet];
    return [[self componentsSeparatedByCharactersInSet:nonNumericSet] componentsJoinedByString:@""];
}

@end


@implementation NSString (Encrypt)

- (NSString *)wcRot13
{
    const char *source = [self cStringUsingEncoding:NSASCIIStringEncoding];
    char *dest = (char *)malloc((self.length + 1) * sizeof(char));
    if (!dest) {
        return nil;
    }
    
    NSUInteger i = 0;
    for ( ; i < self.length; i++) {
        char c = source[i];
        if (c >= 'A' && c <= 'Z') {
            c = (c - 'A' + 13) % 26 + 'A';
        }
        else if (c >= 'a' && c <= 'z') {
            c = (c - 'a' + 13) % 26 + 'a';
        }
        dest[i] = c;
    }
    dest[i] = '\0';
    
    NSString *result = [[NSString alloc] initWithCString:dest encoding:NSASCIIStringEncoding];
    free(dest);
    
    return result;
}

- (NSString *)wcEncryptString
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64 = [data base64EncodedStringWithOptions:0];
    return [base64 wcRot13];
}

- (NSString *)wcDecryptString
{
    NSString *rot13 = [self wcRot13];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:rot13 options:0];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end


@implementation NSString (URL)

+ (instancetype)stringWithContentsOfURL:(NSURL *)url
                            httpHeaders:(NSDictionary *)httpHeaders
                               encoding:(NSStringEncoding)enc
                                  error:(NSError **)error
{
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    for (NSString *headerKey in [httpHeaders keyEnumerator]) {
        [request addValue:httpHeaders[headerKey] forHTTPHeaderField:headerKey];
    }
    
    NSURLResponse* response = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:error];
    NSString *result = [[NSString alloc] initWithData:data encoding:enc];
    return result;
}

@end


@implementation WCDL

+ (void *)loadSymbol:(NSString *)symName
{
    return dlsym(RTLD_SELF, [symName cStringUsingEncoding:NSUTF8StringEncoding]);
}

@end
