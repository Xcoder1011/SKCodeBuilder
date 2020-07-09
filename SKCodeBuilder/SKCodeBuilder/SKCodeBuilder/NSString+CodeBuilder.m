//
//  NSString+CodeBuilder.m
//  SKCodeBuilder
//
//  Created by shangkun on 2020/4/22.
//  Copyright © 2020 wushangkun. All rights reserved.
//

#import "NSString+CodeBuilder.h"
#import <CommonCrypto/CommonDigest.h>
#import <zlib.h>
#import <AppKit/AppKit.h>

@implementation NSString (CodeBuilder)

- (NSDictionary *)_toJsonDict {
    
    NSString *str = self;
    if (!str || str.length == 0)  return nil;
    
    str = [str stringByReplacingOccurrencesOfString:@"，" withString:@","];
    str = [str stringByReplacingOccurrencesOfString:@"“" withString:@""];
    
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) return nil;
    
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    return jsonDict;
}

- (NSString *)adler32
{
    if (self.length == 0) return nil;
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uLong crc = crc32(0L, Z_NULL, 0);
    crc = crc32(crc, data.bytes, (uInt)data.length);
    
    uLong adler = adler32(0L, Z_NULL, 0);
    adler = adler32(adler, data.bytes, (uInt)data.length);
    
    return [NSString stringWithFormat:@"%lu", adler ^ crc];
}

- (NSString *)stringByEncodingWithCipher:(NSString *)cipher
{
    NSMutableString *output = [NSMutableString string];
    
    int cipherIndex = 0;
    
    for ( int i = 0; i  < self.length; i++ )
    {
        cipherIndex = cipherIndex % cipher.length;
        
        char a = [self characterAtIndex:i];
        
        char result = a ^ (int)[cipher characterAtIndex:cipherIndex];
        
        [output appendFormat:@"%c",result];
        
        cipherIndex++;
    }
    
    return output;
}

- (NSString *)stringByDecodingFromCipher:(NSString *)cipher
{
    return [self stringByEncodingWithCipher:cipher];
}


// 加密
-(NSString *)obfuscate:(NSData *)string withKey:(NSString *)key

{
    NSData *data = string;
    
    char *dataPtr = (char *) [data bytes];
    
    　 char *keyData = (char *) [[key dataUsingEncoding:NSUTF8StringEncoding] bytes];
    
    char *keyPtr = keyData;
    
    int keyIndex = 0;
    
    for (int x = 0; x < [data length]; x++){
        
        　　   *dataPtr = *dataPtr++ ^ *keyPtr++;
        
        if (++keyIndex == [key length]) keyIndex = 0, keyPtr = keyData;
        
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}


// 解密

-(NSString*)encodeString:(NSString*)data withKey:(NSString*)key

{
    
    NSString *result=[NSString string];
    
    for(int i=0; i < [data length]; i++){
        
        int chData = [data characterAtIndex:i];
        
        for(int j=0;j<[key length];j++){
            
            int chKey = [key characterAtIndex:j];
            
            chData = chData^chKey;
            
        }
        
        result=[NSString stringWithFormat:@"%@%@",result,[NSString stringWithFormat:@"%c",chData]];
        
    }
    
    return result;
    
}



@end

@implementation NSDictionary (CodeBuilder)

- (NSString *)_toJsonString {
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    if (!jsonData) return @"";

    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
