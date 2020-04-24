//
//  SKCodeBuilder.h
//  SKCodeBuilder
//
//  Created by shangkun on 2020/4/22.
//  Copyright © 2020 wushangkun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKCodeBuilderConfig;
@interface SKCodeBuilder : NSObject

@property (nonatomic, strong) SKCodeBuilderConfig *config;

- (NSMutableString *)build_OC_withDict:(NSDictionary *)jsonDict;

- (NSMutableString *)build_OC_h_withDict:(NSDictionary *)jsonDict;
- (NSMutableString *)build_OC_m_withDict:(NSDictionary *)jsonDict;

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

@end


