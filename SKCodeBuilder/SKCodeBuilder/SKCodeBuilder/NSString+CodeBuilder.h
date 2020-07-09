//
//  NSString+CodeBuilder.h
//  SKCodeBuilder
//
//  Created by shangkun on 2020/4/22.
//  Copyright © 2020 wushangkun. All rights reserved.
//

#import <AppKit/AppKit.h>


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CodeBuilder)

- (NSDictionary *)_toJsonDict;
- (NSString *)adler32;

- (NSString *)stringByEncodingWithCipher:(NSString *)cipher;
- (NSString *)stringByDecodingFromCipher:(NSString *)cipher;

//////////

// 加密
-(NSString *)obfuscate:(NSData *)string withKey:(NSString *)key;
-(NSString *)encodeString:(NSString*)data withKey:(NSString *)key;

@end

@interface NSDictionary (CodeBuilder)

- (NSString *)_toJsonString;

@end

NS_ASSUME_NONNULL_END
