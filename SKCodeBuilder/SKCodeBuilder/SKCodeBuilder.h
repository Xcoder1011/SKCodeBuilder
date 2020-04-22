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
/// model继承类名... 默认"NSObject"
@property (nonatomic, copy) NSString *superClassName;
/// root model name ... 默认"NSRootModel"
@property (nonatomic, copy) NSString *rootModelName;

@end

