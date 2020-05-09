//
//  ExampleMJExtensionModel.m
//  SKCodeBuilder
//
//  Created by wushangkun on 2020/05/09.
//  Copyright © 2020 SKCodeBuilder. All rights reserved.
//

#import "ExampleMJExtensionModel.h"



@implementation ExampleMJExtensionModel

+ (NSDictionary *)mj_objectClassInArray
{
     return @{
              @"data" : SKDataModel.class,
              @"author" : SKAuthorModel.class,
             };
}

@end



@implementation SKDataModel

+ (NSDictionary *)mj_objectClassInArray
{
     return @{
              @"list" : SKListModel.class,
             };
}

@end



@implementation SKListModel


@end



@implementation SKAuthorModel


@end

