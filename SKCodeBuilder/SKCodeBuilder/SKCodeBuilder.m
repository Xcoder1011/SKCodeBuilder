//
//  SKCodeBuilder.m
//  SKCodeBuilder
//
//  Created by shangkun on 2020/4/22.
//  Copyright © 2020 wushangkun. All rights reserved.
//

#import "SKCodeBuilder.h"

@implementation SKCodeBuilder

- (instancetype)init {
    if (self = [super init]) {
        _config = [SKCodeBuilderConfig new];
    }
    return self;
}

- (NSMutableString *)build_OC_withDict:(NSDictionary *)jsonDict {
    return nil;
}

- (NSMutableString *)build_OC_h_withDict:(NSDictionary *)jsonDict {
    NSMutableString *hString = [NSMutableString string];
    // [hString appendFormat:@"\n#import <Foundation/Foundation.h>\n\n"];
    [self handleDictValue:jsonDict key:@"" hString:hString];
    return hString;
}

- (NSMutableString *)build_OC_m_withDict:(NSDictionary *)jsonDict {
    return nil;
}

- (NSString *)modelNameWithKey:(NSString *)key
{
    return [NSString stringWithFormat:@"%@Model",key];
}

- (void)handleDictValue:(NSDictionary *)dictValue key:(NSString *)key hString:(NSMutableString *)hString {
    if (key && key.length) { // 子model
        NSString *modelName = [self modelNameWithKey:key];
        [hString insertString:[NSString stringWithFormat:@"@class %@;\n", modelName] atIndex:0];
        [hString appendFormat:@"\n\n@interface %@ : %@\n\n", modelName ,self.config.superClassName];
        [hString appendFormat:@"@end\n\n"];
    } else { // 第一个 model
        [hString appendFormat:@"\n\n@interface %@ : %@\n\n", self.config.rootModelName ,self.config.superClassName];
        [hString appendFormat:@"@end\n\n"];
    }
    
    [dictValue enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        
        if ([value isKindOfClass:[NSNumber class]]) {
            // NSNumber 类型
            [self handleNumberValue:value key:key hString:hString];
            
        } else if ([value isKindOfClass:[NSString class]]) {
            // NSString 类型
            if ([(NSString *)value length] > 12) {
                [hString appendFormat:@"/** %@ */\n@property (nonatomic, copy) NSString *%@;\n",key, key];
            } else {
                [hString appendFormat:@"/** eg. %@ */\n@property (nonatomic, copy) NSString *%@;\n",value,key];
            }
            
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            // NSDictionary 类型
            [self handleDictValue:value key:key hString:hString];
            
        } else if ([value isKindOfClass:[NSArray class]]) {
            // NSArray 类型
            [hString appendFormat:@"/** %@ */\n@property (nonatomic, strong) NSArray *%@;\n",key, key];
            
        } else {
            // 识别不出类型
            [hString appendFormat:@"/** <#识别不出类型#> */\n@property (nonatomic, strong) id %@;\n",key];
        }
    }];
}

- (void)handleNumberValue:(NSNumber *)numValue key:(NSString *)key hString:(NSMutableString *)hString {
    
    const char *type = @encode(__typeof__(numValue));
    
    if (strcmp(type, @encode(char)) == 0 || strcmp(type, @encode(unsigned char)) == 0) {
        // char 字符串
        [hString appendFormat:@"/** eg. %@ */\n@property (nonatomic, copy) NSString *%@;\n",numValue,key];
        
    } else if (strcmp(type, @encode(double)) == 0 || strcmp(type, @encode(float)) == 0) {
         // 浮点型
        [hString appendFormat:@"/** eg. %@ */\n@property (nonatomic, assign) CGFloat %@;\n",numValue,key];
    
    } else if (strcmp(type, @encode(BOOL)) == 0) {
         // 布尔值类型
        [hString appendFormat:@"/** eg. %@ */\n@property (nonatomic, assign) BOOL %@;\n",numValue,key];
        
    } else  {
        // int, long, longlong, unsigned int,unsigned longlong 类型
        [hString appendFormat:@"/** eg. %@ */\n@property (nonatomic, assign) NSInteger %@;\n",numValue,key];
    }
}

@end

@implementation SKCodeBuilderConfig

- (instancetype)init {
    if (self = [super init]) {
        _superClassName = @"NSObject";
        _rootModelName = @"NSRootModel";
    }
    return self;
}
@end
