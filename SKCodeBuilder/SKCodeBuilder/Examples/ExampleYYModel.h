//
//  ExampleYYModel.h
//  SKCodeBuilder
//
//  Created by wushangkun on 2020/05/09.
//  Copyright © 2020 SKCodeBuilder. All rights reserved.
//

#import "ExampleModel.h"

@class YYAuthorModel;
@class YYListModel;
@class YYDataModel;


@interface ExampleYYModel : YYModel

/** eg. 200 */
@property (nonatomic, assign) NSInteger code;
/** data */
@property (nonatomic, strong) YYDataModel *data;
/** author */
@property (nonatomic, strong) YYAuthorModel *author;
/** eg. success */
@property (nonatomic, copy) NSString *msg;

@end



@interface YYDataModel : YYModel

/** last_update */
@property (nonatomic, copy) NSString *last_update;
/** eg. 微博 ‧ 热搜榜 */
@property (nonatomic, copy) NSString *name;
/** list */
@property (nonatomic, strong) NSArray <YYListModel *> *list;

@end



@interface YYListModel : YYModel

/** title */
@property (nonatomic, copy) NSString *title;
/** link */
@property (nonatomic, copy) NSString *link;
/** eg. 336.5万 */
@property (nonatomic, copy) NSString *other;

@end



@interface YYAuthorModel : YYModel

/** eg. Alone88 */
@property (nonatomic, copy) NSString *name;
/** desc */
@property (nonatomic, copy) NSString *desc;

@end

