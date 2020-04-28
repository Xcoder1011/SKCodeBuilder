//
//  SKCodeBuilder.m
//  SKCodeBuilder
//
//  Created by shangkun on 2020/4/22.
//  Copyright © 2020 wushangkun. All rights reserved.
//

#import "SKCodeBuilder.h"
#import "NSString+CodeBuilder.h"

@interface SKCodeBuilder ()
/// 接下来需要处理的 字典 key - value
@property (nonatomic, strong) NSMutableDictionary *handleDicts;

/*
 *  + (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass
 *   {
 *    return @{@"shadows" : [YYShadow class],
 *               @"borders" : YYBorder.class,
 *               @"attachments" : @"YYAttachment" };
 *   }
 */
@property (nonatomic, strong) NSMutableDictionary *yymodelPropertyGenericClassDicts;

/*
*  + (NSDictionary<NSString *,id> *)modelCustomPropertyMapper
*   {
*    return @{@"name"  : @"n",
*             @"page"  : @"p",
*             @"desc"  : @"ext.desc",
*             @"bookID": @[@"id", @"ID", @"book_id"]};
*   }
*/
@property (nonatomic, strong) NSMutableDictionary *yymodelPropertyMapper;

@property (nonatomic, strong) NSMutableString *hString;
@property (nonatomic, strong) NSMutableString *mString;

@end

@implementation SKCodeBuilder

- (instancetype)init {
    if (self = [super init]) {
        _config = [SKCodeBuilderConfig new];
    }
    return self;
}

- (void)build_OC_withDict:(NSDictionary *)jsonDict complete:(BuildComplete)complete {
    
    NSMutableString *hString = [NSMutableString string];
    NSMutableString *mString = [NSMutableString string];

    [self handleDictValue:jsonDict key:@"" hString:hString mString:mString];
    
    if ([self.config.superClassName isEqualToString:@"NSObject"]) { // 默认
        [hString insertString:@"\n#import <Foundation/Foundation.h>\n\n" atIndex:0];
    } else {
        [hString insertString:[NSString stringWithFormat:@"\n#import \"%@.h\"\n\n",self.config.superClassName] atIndex:0];
    }
    
    [mString insertString:[NSString stringWithFormat:@"\n#import \"%@.h\"\n\n",self.config.rootModelName] atIndex:0];

    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    NSString *year = [[time componentsSeparatedByString:@"/"] firstObject];

    NSString *hCommentString = [NSString stringWithFormat:
                               @"//\n"
                                "//  %@.h\n"
                                "//  SKCodeBuilder\n"
                                "//\n"
                                "//  Created by %@ on %@.\n"
                                "//  Copyright © %@ SKCodeBuilder. All rights reserved.\n"
                                "//\n", self.config.rootModelName, self.config.authorName, time, year];
    
    NSString *mCommentString = [NSString stringWithFormat:
                               @"//\n"
                               "//  %@.m\n"
                               "//  SKCodeBuilder\n"
                               "//\n"
                               "//  Created by %@ on %@.\n"
                               "//  Copyright © %@ SKCodeBuilder. All rights reserved.\n"
                               "//\n", self.config.rootModelName, self.config.authorName, time, year];
    
    [hString insertString:hCommentString atIndex:0];
    [mString insertString:mCommentString atIndex:0];
    
    if (complete) {
        complete(hString, mString);
    }
}

- (void)handleDictValue:(NSDictionary *)dictValue key:(NSString *)key hString:(NSMutableString *)hString mString:(NSMutableString *)mString{
   
    if (key && key.length) { // sub model
        NSString *modelName = [self modelNameWithKey:key];
        [hString insertString:[NSString stringWithFormat:@"@class %@;\n", modelName] atIndex:0];
        [hString appendFormat:@"\n\n@interface %@ : %@\n\n", modelName ,self.config.superClassName];
        
        [mString appendFormat:@"\n\n@implementation %@\n\n", modelName];

    } else { // Root model
        [hString appendFormat:@"\n\n@interface %@ : %@\n\n", self.config.rootModelName ,self.config.superClassName];
        
        [mString appendFormat:@"\n\n@implementation %@\n\n", self.config.rootModelName];
    }
    
    if (![dictValue isKindOfClass:[NSDictionary class]]) {
        [hString appendFormat:@"\n@end\n\n"];
        [mString appendFormat:@"\n@end\n\n"];
        NSLog(@" handleDictValue (%@) error !!!!!!",dictValue);
        return;
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
                if (self.config.jsonType == SKCodeBuilderJSONModelTypeNone) {
                    [hString appendFormat:@"/** eg. %@ */\n@property (nonatomic, copy) NSString *%@;\n",value,key];
                } else {
                    [self handleIdValue:value key:key hString:hString];
                }
            }
            
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            // NSDictionary 类型
            NSString *modelName = [self modelNameWithKey:key];
            [hString appendFormat:@"/** %@ */\n@property (nonatomic, strong) %@ *%@;\n",key, modelName, key];\
            
            NSString *propertyValue = [NSString stringWithFormat:@"%@", modelName];
            [self.yymodelPropertyGenericClassDicts setObject:propertyValue forKey:key];
            
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

    if (self.config.jsonType == SKCodeBuilderJSONModelTypeYYModel) { // 适配YYModel
        
        /// The generic class mapper for container properties.
        BOOL needLineBreak = NO;
        if (self.yymodelPropertyGenericClassDicts.count) {
            [mString appendFormat:@"+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass\n"];
            [mString appendFormat:@"{\n     return @{\n"];
            [self.yymodelPropertyGenericClassDicts enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [mString appendFormat:@"                    @\"%@\" : %@.class,\n",key, obj];
            }];
            [mString appendFormat:@"                    };"];
            [mString appendFormat:@"\n}\n"];
            needLineBreak = YES;
        }
        
        /// Custom property mapper.
        
        if (self.yymodelPropertyMapper.count) {
            if (needLineBreak) {
                [mString appendFormat:@"\n"];
            }
            [mString appendFormat:@"+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper\n"];
            [mString appendFormat:@"{\n     return @{\n"];
            [self.yymodelPropertyMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [mString appendFormat:@"                    @\"%@\" : @""\"%@\",\n",key, obj];  //   **\"
            }];
            [mString appendFormat:@"                    };"];
            [mString appendFormat:@"\n}\n"];
        }
    }
    
    if (key.length) {
        NSLog(@">>>>> self.handleDicts removeObjectForKey: >>>>> %@ ,total: %zd, keys: %@",key , self.handleDicts.count,self.handleDicts.allKeys);
        [self.handleDicts removeObjectForKey:key];
    }
    
    [mString appendFormat:@"\n@end\n\n"];
    
    [self.yymodelPropertyGenericClassDicts removeAllObjects];
    [self.yymodelPropertyMapper removeAllObjects];

    if (self.handleDicts.count) {
        NSString *firstKey = self.handleDicts.allKeys.firstObject;
        NSDictionary *firstObject = self.handleDicts[firstKey];
        [self handleDictValue:firstObject key:firstKey hString:hString mString:mString];
    }
}

- (void)handleIdValue:(NSString *)idValue key:(NSString *)key hString:(NSMutableString *)hString {
    // 字符串id 替换成 itemId
    if ([key isEqualToString:@"id"]) {
        [self.yymodelPropertyMapper setObject:@"id" forKey:@"itemId"];
        [hString appendFormat:@"/** eg. %@ */\n@property (nonatomic, copy) NSString *%@;\n",idValue,@"itemId"];
    } else {
        [hString appendFormat:@"/** eg. %@ */\n@property (nonatomic, copy) NSString *%@;\n",idValue,key];
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
            
            NSString *propertyValue = [NSString stringWithFormat:@"%@", modelName];
            [self.yymodelPropertyGenericClassDicts setObject:propertyValue forKey:key];
            
            [hString appendFormat:@"/** %@ */\n@property (nonatomic, strong) NSArray <%@ *> *%@;\n",key, modelName, key];
            
        } else if ([firstObject isKindOfClass:[NSArray class]]) {
           
            [self handleArrayValue:(NSArray *)firstObject key:key hString:hString];
            
        } else {
            
            [hString appendFormat:@"/** %@ */\n@property (nonatomic, strong) NSArray *%@;\n",key, key];
        }
    }
}

- (void)handleNumberValue:(NSNumber *)numValue key:(NSString *)key hString:(NSMutableString *)hString {
        
    const char *type = [numValue objCType];
    
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

- (void)generate_OC_File_withPath:(NSString *)filePath
                          hString:(NSMutableString *)hString
                          mString:(NSMutableString *)mString
                         complete:(GenerateFileComplete)complete {
    if (hString.length && mString.length) {
        
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
        
        NSString *fileNameH = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h",self.config.rootModelName]];
        NSString *fileNameM = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m",self.config.rootModelName]];
        BOOL retH = [hString writeToFile:fileNameH atomically:YES encoding:NSUTF8StringEncoding error:nil];
        BOOL retM = [mString writeToFile:fileNameM atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        if (complete) {
            complete(retH&&retM, filePath);
        }
    }
}

- (NSMutableDictionary *)handleDicts {
    if (!_handleDicts) {
        _handleDicts = [NSMutableDictionary new];
    }
    return _handleDicts;
}

- (NSMutableDictionary *)yymodelPropertyGenericClassDicts {
    if (!_yymodelPropertyGenericClassDicts) {
        _yymodelPropertyGenericClassDicts = [NSMutableDictionary new];
    }
    return _yymodelPropertyGenericClassDicts;
}

- (NSMutableDictionary *)yymodelPropertyMapper {
    if (!_yymodelPropertyMapper) {
        _yymodelPropertyMapper = [NSMutableDictionary new];
    }
    return _yymodelPropertyMapper;
}

@end

@implementation SKCodeBuilderConfig

- (instancetype)init {
    if (self = [super init]) {
        _superClassName = @"NSObject";
        _rootModelName = @"NSRootModel";
        _modelNamePrefix = @"NS";
        _authorName = @"SKCodeBuilder";
        _codeType = SKCodeBuilderCodeTypeOC;
        _jsonType = SKCodeBuilderJSONModelTypeNone;
    }
    return self;
}

@end
