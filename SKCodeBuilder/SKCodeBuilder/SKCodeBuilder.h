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

typedef void (^BuildComplete)(NSMutableString *hString, NSMutableString *mString);

@property (nonatomic, strong) SKCodeBuilderConfig *config;

- (void)build_OC_withDict:(NSDictionary *)jsonDict complete:(BuildComplete)complete;

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


