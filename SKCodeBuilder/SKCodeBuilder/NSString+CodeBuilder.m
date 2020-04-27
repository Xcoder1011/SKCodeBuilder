//
//  NSString+CodeBuilder.m
//  SKCodeBuilder
//
//  Created by shangkun on 2020/4/22.
//  Copyright © 2020 wushangkun. All rights reserved.
//

#import "NSString+CodeBuilder.h"

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

@end

@implementation NSDictionary (CodeBuilder)

- (NSString *)_toJsonString {
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    if (!jsonData) return @"";

    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
