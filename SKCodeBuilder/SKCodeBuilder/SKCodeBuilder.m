//
//  SKCodeBuilder.m
//  SKCodeBuilder
//
//  Created by shangkun on 2020/4/22.
//  Copyright © 2020 wushangkun. All rights reserved.
//

#import "SKCodeBuilder.h"

@interface SKCodeBuilder ()
/// 接下来需要处理的 字典 key - value
@property (nonatomic, strong) NSMutableDictionary *handleDicts;

@end

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
    NSString *firstCharacter = [key substringToIndex:1];
    if (firstCharacter) {
        firstCharacter = [firstCharacter uppercaseString];
    }
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstCharacter];
    if (![key hasPrefix:self.config.modelNamePrefix]) {
        key = [NSString stringWithFormat:@"%@%@",self.config.modelNamePrefix,key];
    }
    return [NSString stringWithFormat:@"%@Model",key];
}

- (void)handleDictValue:(NSDictionary *)dictValue key:(NSString *)key hString:(NSMutableString *)hString {
   
    if (key && key.length) { // sub model
        NSString *modelName = [self modelNameWithKey:key];
        [hString insertString:[NSString stringWithFormat:@"@class %@;\n", modelName] atIndex:0];
        [hString appendFormat:@"\n\n@interface %@ : %@\n\n", modelName ,self.config.superClassName];
    } else { // Root model
        [hString appendFormat:@"\n\n@interface %@ : %@\n\n", self.config.rootModelName ,self.config.superClassName];
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
            NSString *modelName = [self modelNameWithKey:key];
            [hString appendFormat:@"/** %@ */\n@property (nonatomic, strong) %@ *%@;\n",key, modelName, key];
            [self.handleDicts setObject:value forKey:key];
            
        } else if ([value isKindOfClass:[NSArray class]]) {
            // NSArray 类型
            [self handleArrayValue:(NSArray *)value key:key hString:hString];
            
        } else {
            // 识别不出类型
            [hString appendFormat:@"/** <#识别不出类型#> */\n@property (nonatomic, strong) id %@;\n",key];
        }
    }];
    
    [hString appendFormat:@"\n@end\n\n"];
    
    if (key.length) {
        NSLog(@">>>>> self.handleDicts removeObjectForKey: >>>>> %@ ,total: %zd",key , self.handleDicts.count);
        [self.handleDicts removeObjectForKey:key];
    }
        
    if (self.handleDicts.count) {
        NSString *firstKey = self.handleDicts.allKeys.firstObject;
        NSDictionary *firstObject = self.handleDicts[firstKey];
        [self handleDictValue:firstObject key:firstKey hString:hString];
    }
}

- (void)handleArrayValue:(NSArray *)arrayValue key:(NSString *)key hString:(NSMutableString *)hString {
    
    if (arrayValue && arrayValue.count) {
        
        id firstObject = arrayValue.firstObject;
        
        if ([firstObject isKindOfClass:[NSString class]]) {
            // NSString 类型
            [hString appendFormat:@"/** %@ */\n@property (nonatomic, strong) NSArray <NSString *> *%@;\n",key, key];
            
        } else if ([firstObject isKindOfClass:[NSDictionary class]]) {
            // NSDictionary 类型
            NSString *modelName = [self modelNameWithKey:key];
            [self.handleDicts setObject:firstObject forKey:key];
            [hString appendFormat:@"/** %@ */\n@property (nonatomic, strong) NSArray <%@ *> *%@;\n",key, modelName, key];
            
        } else if ([firstObject isKindOfClass:[NSArray class]]) {
           
            [self handleArrayValue:(NSArray *)firstObject key:key hString:hString];
            
        } else {
            
            [hString appendFormat:@"/** %@ */\n@property (nonatomic, strong) NSArray *%@;\n",key, key];
        }
    }
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

- (NSMutableDictionary *)handleDicts {
    if (!_handleDicts) {
        _handleDicts = [NSMutableDictionary new];
    }
    return _handleDicts;
}

@end

@implementation SKCodeBuilderConfig

- (instancetype)init {
    if (self = [super init]) {
        _superClassName = @"NSObject";
        _rootModelName = @"NSRootModel";
        _modelNamePrefix = @"NS";
    }
    return self;
}
@end
