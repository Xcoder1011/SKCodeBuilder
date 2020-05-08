//
//  SKCodeBuilder.h
//  SKCodeBuilder
//
//  Created by shangkun on 2020/4/22.
//  Copyright © 2020 wushangkun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SKCodeBuilderCodeType) {
    SKCodeBuilderCodeTypeOC = 1,
    SKCodeBuilderCodeTypeSwift,
    SKCodeBuilderCodeTypeJava
};

typedef NS_ENUM(NSInteger, SKCodeBuilderJSONModelType) {
    SKCodeBuilderJSONModelTypeNone = 0,
    SKCodeBuilderJSONModelTypeYYModel,
    SKCodeBuilderJSONModelTypeMJExtension,
    SKCodeBuilderJSONModelTypeHandyJSON,
};

@class SKCodeBuilderConfig;

@interface SKCodeBuilder : NSObject

typedef void (^BuildComplete)(NSMutableString *, NSMutableString *);

typedef void (^GenerateFileComplete)(BOOL success, NSString *filePath);

@property (nonatomic, strong) SKCodeBuilderConfig *config;

- (void)build_OC_withJsonObj:(id)jsonObj complete:(BuildComplete)complete;

- (void)generate_OC_File_withPath:(NSString *)filePath
                          hString:(NSMutableString *)hString
                          mString:(NSMutableString *)mString
                         complete:(GenerateFileComplete)complete;
                           
@end

@interface SKCodeBuilderConfig : NSObject

/// model继承类名... default "NSObject"
@property (nonatomic, copy) NSString *superClassName;
/// root model name ... default "NSRootModel"
@property (nonatomic, copy) NSString *rootModelName;
/// model name prefix  ... default "NS"
@property (nonatomic, copy) NSString *modelNamePrefix;
/// authorName  ... default "SKCodeBuilder"
@property (nonatomic, copy) NSString *authorName;
/// support OC/Swift/Java   ...default "OC"
@property (nonatomic, assign) SKCodeBuilderCodeType codeType;
/// support YYModel/MJExtension/None   ...default "None"
@property (nonatomic, assign) SKCodeBuilderJSONModelType jsonType;

@end


