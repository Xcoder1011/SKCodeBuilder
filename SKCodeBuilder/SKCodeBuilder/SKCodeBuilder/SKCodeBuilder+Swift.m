//
//  SKCodeBuilder+Swift.m
//  SKCodeBuilder
//
//  Created by shangkun on 2020/5/7.
//  Copyright © 2020 wushangkun. All rights reserved.
//

#import "SKCodeBuilder+Swift.h"
#import <objc/runtime.h>
#import <AppKit/AppKit.h>

@implementation SKCodeBuilder (Swift)

static const char *sk_handleDictsKey = "sk_handleDictsKey";
static const char *sk_handlePropertyMapperKey = "sk_handlePropertyMapperKey";

- (void)build_Swift_withJsonObj:(id)jsonObj complete:(BuildComplete)complete {
    
    NSMutableString *swiftString = [NSMutableString string];
    
    [self handleDictValue:jsonObj key:@"" swiftString:swiftString];
    
    if (self.config.jsonType == SKCodeBuilderJSONModelTypeHandyJSON) {
        [swiftString insertString:@"import HandyJSON" atIndex:0];
    }
    
    [swiftString insertString:@"\nimport Foundation\n" atIndex:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    NSString *year = [[time componentsSeparatedByString:@"/"] firstObject];
    
    NSString *commentString = [NSString stringWithFormat:
                               @"//\n"
                               "//  %@.swift\n"
                               "//  SKCodeBuilder\n"
                               "//\n"
                               "//  Created by %@ on %@.\n"
                               "//  Copyright © %@ SKCodeBuilder. All rights reserved.\n"
                               "//\n", self.config.rootModelName, self.config.authorName, time, year];
    
    
    [swiftString insertString:commentString atIndex:0];
    
    if (complete) {
        complete(swiftString, nil);
    }
}

- (void)handleDictValue:(NSDictionary *)dictValue key:(NSString *)key swiftString:(NSMutableString *)swiftString {
   
    if (key && key.length) { // sub model
        NSString *modelName = [self modelNameWithKey:key];
        [swiftString appendFormat:@"\n\nclass %@ : %@ {\n\n", modelName ,self.config.superClassName];

    } else { // Root model
        [swiftString appendFormat:@"\n\nclass %@ : %@ {\n\n", self.config.rootModelName ,self.config.superClassName];
    }
    
    if ([dictValue isKindOfClass:[NSArray class]]) {
        
        [self handleArrayValue:(NSArray *)dictValue key:@"dataList" swiftString:swiftString];
        
    } else if ([dictValue isKindOfClass:[NSDictionary class]])  {
        
        [dictValue enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
            
            if ([value isKindOfClass:[NSNumber class]]) {
                // NSNumber 类型
                [self handleIdNumberValue:value key:key swiftString:swiftString ignoreIdValue:self.config.jsonType == SKCodeBuilderJSONModelTypeNone];
                
            } else if ([value isKindOfClass:[NSString class]]) {
                // NSString 类型
                [self handleIdValue:value key:key swiftString:swiftString ignoreIdValue:self.config.jsonType == SKCodeBuilderJSONModelTypeNone];
                
            } else if ([value isKindOfClass:[NSDictionary class]]) {
                // NSDictionary 类型
                NSString *modelName = [self modelNameWithKey:key];
                [swiftString appendFormat:@"    /// %@\n    var %@: %@?\n",key, key, modelName];
                [self.handleDicts setObject:value forKey:key];
                
            } else if ([value isKindOfClass:[NSArray class]]) {
                // NSArray 类型
                [self handleArrayValue:(NSArray *)value key:key swiftString:swiftString];
                
            } else {
                // 识别不出类型
                // 用泛型定义
                [swiftString appendFormat:@"    /// %@\n    var %@: T?\n",key, key];
            }
        }];
        
    } else {
        [swiftString appendFormat:@"}\n"];
        NSLog(@" handleDictValue (%@) error !!!!!!",dictValue);
        return;
    }
    
    if (self.config.jsonType == SKCodeBuilderJSONModelTypeHandyJSON) {
        
        /// 1. implement an empty initializer.
        
        [swiftString appendFormat:@"\n    required init() {}\n"];
        
        /// 2. Custom property mapper.
        
        if (self.handlePropertyMapper.count) {
          
            [swiftString appendFormat:@"\n    public func mapping(mapper: HelpingMapper) {\n"];
            
            [self.handlePropertyMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [swiftString appendFormat:@"\n        mapper <<< self.%@ <-- \"%@\"",key,obj];
            }];
            [swiftString appendFormat:@"\n\n     }\n"];
        }
    }
    
    [swiftString appendFormat:@"}\n"];

    if (key.length) {
        [self.handleDicts removeObjectForKey:key];
    }
    [self.handlePropertyMapper removeAllObjects];

    if (self.handleDicts.count) {
        NSString *firstKey = self.handleDicts.allKeys.firstObject;
        NSDictionary *firstObject = self.handleDicts[firstKey];
        [self handleDictValue:firstObject key:firstKey swiftString:swiftString];
    }
}

- (void)handleIdValue:(NSString *)idValue key:(NSString *)key swiftString:(NSMutableString *)swiftString {
    // 字符串id 替换成 itemId
    if ([key isEqualToString:@"id"]) {
        [self.handlePropertyMapper setObject:@"id" forKey:@"itemId"];
        [swiftString appendFormat:@"    /// %@\n    var %@: String?\n",idValue, @"itemId"];
    } else {
        [swiftString appendFormat:@"    /// %@\n    var %@: String?\n",idValue, key];
    }
}

- (void)handleIdValue:(NSString *)idValue key:(NSString *)key swiftString:(NSMutableString *)swiftString ignoreIdValue:(BOOL)ignoreIdValue {
   
    if ([key isEqualToString:@"id"] && !ignoreIdValue) { // 字符串id 替换成 itemId
        [self.handlePropertyMapper setObject:@"id" forKey:@"itemId"];
        [swiftString appendFormat:@"    /// %@\n    var %@: String?\n",idValue, @"itemId"];
    } else { // 忽略id，不处理
        if ([(NSString *)idValue length] > 12) {
            [swiftString appendFormat:@"    /// %@\n    var %@: String?\n",key, key];
        } else {
            [swiftString appendFormat:@"    /// %@\n    var %@: String?\n",idValue, key];
        }
    }
}

- (void)handleArrayValue:(NSArray *)arrayValue key:(NSString *)key swiftString:(NSMutableString *)swiftString {
    
    if (arrayValue && arrayValue.count) {
        
        id firstObject = arrayValue.firstObject;
        
        if ([firstObject isKindOfClass:[NSString class]]) {
            // NSString 类型
            [swiftString appendFormat:@"    /// %@\n    var %@: [String]?\n",key, key];
            
        } else if ([firstObject isKindOfClass:[NSDictionary class]]) {
            // NSDictionary 类型
            NSString *modelName = [self modelNameWithKey:key];
            [self.handleDicts setObject:firstObject forKey:key];
            [swiftString appendFormat:@"    /// %@\n    var %@: [%@]?\n",key, key, modelName];

        } else if ([firstObject isKindOfClass:[NSArray class]]) {
           
            [self handleArrayValue:(NSArray *)firstObject key:key swiftString:swiftString];
            
        } else {
            
            [swiftString appendFormat:@"    /// %@\n    var %@: [Any]?\n",key, key];
        }
    }
}

- (void)handleIdNumberValue:(NSNumber *)numValue key:(NSString *)key swiftString:(NSMutableString *)swiftString ignoreIdValue:(BOOL)ignoreIdValue{
    
    const char *type = [numValue objCType];
    
    if (strcmp(type, @encode(double)) == 0 || strcmp(type, @encode(float)) == 0) {
        // 浮点型
        [swiftString appendFormat:@"    /// %@\n    var %@: Double?\n",numValue, key];
        
    } else if (strcmp(type, @encode(BOOL)) == 0) {
        // 布尔值类型
        [swiftString appendFormat:@"    /// %@\n    var %@: Bool = false\n",([numValue boolValue]==true?@"true":@"false"), key];
        
    } else if (strcmp(type, @encode(char)) == 0 || strcmp(type, @encode(unsigned char)) == 0) {
        // char 字符串
        [self handleIdValue:(NSString *)numValue key:key swiftString:swiftString ignoreIdValue:ignoreIdValue];
        
    } else   {
        // int, long, longlong, unsigned int,unsigned longlong 类型
        if ([key isEqualToString:@"id"] && !ignoreIdValue) { // 字符串id 替换成 itemId
            [self.handlePropertyMapper setObject:@"id" forKey:@"itemId"];
            [swiftString appendFormat:@"    /// %@\n    var %@: Int = 0\n",numValue, @"itemId"];
            
        } else { // 忽略id，不处理
            [swiftString appendFormat:@"    /// %@\n    var %@: Int = 0\n",numValue, key];
        }
    }
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

- (void)generate_Swift_File_withPath:(NSString *)filePath swiftString:(NSMutableString *)swiftString complete:(GenerateFileComplete)complete {
    
    if (swiftString.length) {
        
        if (!filePath) {
            NSString *path = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES).lastObject;
            path = [path stringByAppendingPathComponent:@"SKCodeBuilderModelFiles"];
            NSLog(@"path = %@",path);
            BOOL isDir = NO;
            BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
            if (isExists && isDir) {
                filePath = path;
            } else {
                if ([[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]) {
                    filePath = path;
                }
            }
        }
        
        NSString *fileName = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.swift",self.config.rootModelName]];
        BOOL ret = [swiftString writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        if (complete) {
            complete(ret, filePath);
        }
    }
}

- (NSMutableDictionary *)handleDicts {
    NSMutableDictionary *dicts = objc_getAssociatedObject(self, sk_handleDictsKey);
    if (!dicts) {
        dicts = [NSMutableDictionary new];
        objc_setAssociatedObject(self, sk_handleDictsKey, dicts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dicts;
}

- (void)setHandleDicts:(NSMutableDictionary *)handleDicts {
    objc_setAssociatedObject(self, sk_handleDictsKey, handleDicts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)handlePropertyMapper {
    NSMutableDictionary *dicts = objc_getAssociatedObject(self, sk_handlePropertyMapperKey);
    if (!dicts) {
        dicts = [NSMutableDictionary new];
        objc_setAssociatedObject(self, sk_handlePropertyMapperKey, dicts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dicts;
}

- (void)setHandlePropertyMapper:(NSMutableDictionary *)handlePropertyMapper {
    objc_setAssociatedObject(self, sk_handlePropertyMapperKey, handlePropertyMapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
