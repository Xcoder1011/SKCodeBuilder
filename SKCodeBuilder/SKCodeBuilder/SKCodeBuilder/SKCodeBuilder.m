//
//  SKCodeBuilder.m
//  SKCodeBuilder
//
//  Created by shangkun on 2020/4/22.
//  Copyright © 2020 wushangkun. All rights reserved.
//

#import "SKCodeBuilder.h"
#import "NSString+CodeBuilder.h"
#import "SKCodeBuilder+Swift.h"

@interface SKCodeBuilder ()

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
// @property (nonatomic, strong) NSMutableDictionary *handlePropertyMapper;

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

- (void)build_OC_withJsonObj:(id)jsonObj complete:(BuildComplete)complete {
    
    NSMutableString *hString = [NSMutableString string];
    NSMutableString *mString = [NSMutableString string];

    [self handleDictValue:jsonObj key:@"" hString:hString mString:mString];
    
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
    
    if ([dictValue isKindOfClass:[NSArray class]]) {
        
        [self handleArrayValue:(NSArray *)dictValue key:@"dataList" hString:hString];
        
    } else if ([dictValue isKindOfClass:[NSDictionary class]])  {
        
        [dictValue enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
            
            if ([value isKindOfClass:[NSNumber class]]) {
                // NSNumber 类型
                [self handleIdNumberValue:value key:key hString:hString ignoreIdValue:self.config.jsonType == SKCodeBuilderJSONModelTypeNone];
                
            } else if ([value isKindOfClass:[NSString class]]) {
                // NSString 类型
                [self handleIdValue:value key:key hString:hString ignoreIdValue:self.config.jsonType == SKCodeBuilderJSONModelTypeNone];
                
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
        
    } else {
        [hString appendFormat:@"\n@end\n\n"];
        [mString appendFormat:@"\n@end\n\n"];
        NSLog(@" handleDictValue (%@) error !!!!!!",dictValue);
        return;
    }
    
    [hString appendFormat:@"\n@end\n\n"];

    if (self.config.jsonType == SKCodeBuilderJSONModelTypeYYModel) { // 适配YYModel
        
        /// 1.The generic class mapper for container properties.
        
        BOOL needLineBreak = NO;
        if (self.yymodelPropertyGenericClassDicts.count) {
            [mString appendFormat:@"+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass\n"];
            [mString appendFormat:@"{\n     return @{\n"];
            [self.yymodelPropertyGenericClassDicts enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [mString appendFormat:@"              @\"%@\" : %@.class,\n",key, obj];
            }];
            [mString appendFormat:@"             };"];
            [mString appendFormat:@"\n}\n"];
            needLineBreak = YES;
        }
        
        /// 2.Custom property mapper.
        
        if (self.handlePropertyMapper.count) {
            if (needLineBreak) {
                [mString appendFormat:@"\n"];
            }
            [mString appendFormat:@"+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper\n"];
            [mString appendFormat:@"{\n     return @{\n"];
            [self.handlePropertyMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [mString appendFormat:@"              @\"%@\" : @\"%@\",\n",key, obj];  //   **\"
            }];
            [mString appendFormat:@"             };"];
            [mString appendFormat:@"\n}\n"];
        }
        
    } else if (self.config.jsonType == SKCodeBuilderJSONModelTypeMJExtension){ // 适配MJExtension
        
        /// 1.The generic class mapper for container properties.
        
        BOOL needLineBreak = NO;
        if (self.yymodelPropertyGenericClassDicts.count) {
            [mString appendFormat:@"+ (NSDictionary *)mj_objectClassInArray\n"];
            [mString appendFormat:@"{\n     return @{\n"];
            [self.yymodelPropertyGenericClassDicts enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [mString appendFormat:@"              @\"%@\" : %@.class,\n",key, obj];
            }];
            [mString appendFormat:@"             };"];
            [mString appendFormat:@"\n}\n"];
            needLineBreak = YES;
        }
        
        /// 2.Custom property mapper.
        
        if (self.handlePropertyMapper.count) {
            if (needLineBreak) {
                [mString appendFormat:@"\n"];
            }
            [mString appendFormat:@"+ (NSDictionary *)mj_replacedKeyFromPropertyName\n"];
            [mString appendFormat:@"{\n     return @{\n"];
            [self.handlePropertyMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [mString appendFormat:@"              @\"%@\" : @\"%@\",\n",key, obj];  //   **\"
            }];
            [mString appendFormat:@"             };"];
            [mString appendFormat:@"\n}\n"];
        }
    }
    
    if (key.length) {
        [self.handleDicts removeObjectForKey:key];
    }
    
    [mString appendFormat:@"\n@end\n\n"];
    
    [self.yymodelPropertyGenericClassDicts removeAllObjects];
    [self.handlePropertyMapper removeAllObjects];

    if (self.handleDicts.count) {
        NSString *firstKey = self.handleDicts.allKeys.firstObject;
        NSDictionary *firstObject = self.handleDicts[firstKey];
        [self handleDictValue:firstObject key:firstKey hString:hString mString:mString];
    }
}

- (void)handleIdValue:(NSString *)idValue key:(NSString *)key hString:(NSMutableString *)hString ignoreIdValue:(BOOL)ignoreIdValue {
    
    if ([key isEqualToString:@"id"] && !ignoreIdValue) { // 字符串id 替换成 itemId
        [self.handlePropertyMapper setObject:@"id" forKey:@"itemId"];
        [hString appendFormat:@"/** eg. %@ */\n@property (nonatomic, copy) NSString *%@;\n",idValue,@"itemId"];
    } else { // 忽略id，不处理
        if ([(NSString *)idValue length] > 12) {
            [hString appendFormat:@"/** %@ */\n@property (nonatomic, copy) NSString *%@;\n",key, key];
        } else {
            [hString appendFormat:@"/** eg. %@ */\n@property (nonatomic, copy) NSString *%@;\n",idValue,key];
        }
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

- (void)handleIdNumberValue:(NSNumber *)numValue key:(NSString *)key hString:(NSMutableString *)hString ignoreIdValue:(BOOL)ignoreIdValue{
    
    const char *type = [numValue objCType];
    
    if (strcmp(type, @encode(double)) == 0 || strcmp(type, @encode(float)) == 0) {
        // 浮点型
        [hString appendFormat:@"/** eg. %@ */\n@property (nonatomic, assign) CGFloat %@;\n",numValue,key];
        
    } else if (strcmp(type, @encode(BOOL)) == 0) {
        // 布尔值类型
        [hString appendFormat:@"/** eg. %@ */\n@property (nonatomic, assign) BOOL %@;\n",numValue,key];
        
    } else if (strcmp(type, @encode(char)) == 0 || strcmp(type, @encode(unsigned char)) == 0) {
        
        [self handleIdValue:(NSString *)numValue key:key hString:hString ignoreIdValue:ignoreIdValue];
             
    } else  {
        // int, long, longlong, unsigned int,unsigned longlong 类型
        if ([key isEqualToString:@"id"] && !ignoreIdValue) { // 字符串id 替换成 itemId
            [self.handlePropertyMapper setObject:@"id" forKey:@"itemId"];
            [hString appendFormat:@"/** eg. %@ */\n@property (nonatomic, assign) NSInteger %@;\n",numValue,@"itemId"];
        } else {
            [hString appendFormat:@"/** eg. %@ */\n@property (nonatomic, assign) NSInteger %@;\n",numValue,key];
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

+ (void)encryptString:(NSString *)str withKey:(NSString *)key completion:(void (^)(NSString *, NSString *))completion{
    
    NSString *tempString = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (tempString.length == 0
        || !completion) return;
    
    NSMutableString *value = [NSMutableString string];
    NSMutableString *secretValues= [NSMutableString string];
  
    const char *cstring = str.UTF8String;
    int length = (int)strlen(cstring);
    
    int keyLength = 0;
    const char *ckeystring = NULL;
    if (key.length) {
        ckeystring = key.UTF8String;
        keyLength =(int)strlen(ckeystring);
    }
    const char factor = arc4random_uniform(pow(2, sizeof(char) * 8) - 1);
    char a = 'c';
    
    if (keyLength > 0 && ckeystring) {
        char b = 'd';
        for (int i = 0; i< keyLength; i++) {
            int k = b ^ factor ^ ckeystring[i];
            [secretValues appendFormat:@"%d,",k];
        }
        [secretValues appendString:@"0"];
        
        int cipherIndex = 0;
        for (int i = 0; i< length; i++) {
            cipherIndex = cipherIndex % keyLength;
            int v = a ^ factor ^ ckeystring[cipherIndex];
            [value appendFormat:@"%d,", v ^ cstring[i]];
            cipherIndex++;
        }
    } else {
        for (int i = 0; i< length; i++) {
            [value appendFormat:@"%d,",  a ^ factor ^ cstring[i]];
        }
    }
    [value appendString:@"0"];
    
    NSString *var = [NSString stringWithFormat:@"_%@", str.adler32];
    NSMutableString *hStr = [NSMutableString string];
    [hStr appendFormat:@"/** %@ */\n",str];
    [hStr appendFormat:@"extern const SKEncryptString * const %@;",var];
    
    NSMutableString *mStr = [NSMutableString string];
    [mStr appendFormat:@"/** %@ */\n",str];
    [mStr appendFormat:@"const SKEncryptString * const %@ = &(SKEncryptString){\n",var];
    
    [mStr appendFormat:@"       .factor = (char)%@,\n",[NSString stringWithFormat:@"%d", factor]];
    [mStr appendFormat:@"       .value = (char[]){%@},\n",value];
    [mStr appendFormat:@"       .length = %d,\n",length];
    
    if (keyLength > 0) {
        [mStr appendFormat:@"       .key = (char[]){%@},\n",secretValues];
        [mStr appendFormat:@"       .kl = %d\n",keyLength];
    }
    
    [mStr appendFormat:@"};\n"];

    if (completion) {
        completion(hStr, mStr);
    }
}

- (NSMutableDictionary *)yymodelPropertyGenericClassDicts {
    if (!_yymodelPropertyGenericClassDicts) {
        _yymodelPropertyGenericClassDicts = [NSMutableDictionary new];
    }
    return _yymodelPropertyGenericClassDicts;
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
