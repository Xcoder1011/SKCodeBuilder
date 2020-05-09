//
//  ExampleYYModel.m
//  SKCodeBuilder
//
//  Created by wushangkun on 2020/05/09.
//  Copyright © 2020 SKCodeBuilder. All rights reserved.
//

#import "ExampleYYModel.h"



@implementation ExampleYYModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass
{
     return @{
              @"data" : YYDataModel.class,
              @"author" : YYAuthorModel.class,
             };
}

@end



@implementation YYDataModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass
{
     return @{
              @"list" : YYListModel.class,
             };
}

@end



@implementation YYListModel


@end



@implementation YYAuthorModel


@end

