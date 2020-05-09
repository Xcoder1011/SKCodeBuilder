//
//  ExampleMJExtensionModel.h
//  SKCodeBuilder
//
//  Created by wushangkun on 2020/05/09.
//  Copyright © 2020 SKCodeBuilder. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKAuthorModel;
@class SKListModel;
@class SKDataModel;


@interface ExampleMJExtensionModel : NSObject

/** eg. 200 */
@property (nonatomic, assign) NSInteger code;
/** data */
@property (nonatomic, strong) SKDataModel *data;
/** author */
@property (nonatomic, strong) SKAuthorModel *author;
/** eg. success */
@property (nonatomic, copy) NSString *msg;

@end



@interface SKDataModel : NSObject

/** last_update */
@property (nonatomic, copy) NSString *last_update;
/** eg. 微博 ‧ 热搜榜 */
@property (nonatomic, copy) NSString *name;
/** list */
@property (nonatomic, strong) NSArray <SKListModel *> *list;

@end



@interface SKListModel : NSObject

/** title */
@property (nonatomic, copy) NSString *title;
/** link */
@property (nonatomic, copy) NSString *link;
/** eg. 336.5万 */
@property (nonatomic, copy) NSString *other;

@end



@interface SKAuthorModel : NSObject

/** eg. Alone88 */
@property (nonatomic, copy) NSString *name;
/** desc */
@property (nonatomic, copy) NSString *desc;

@end

