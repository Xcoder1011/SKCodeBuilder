//
//  TestModel.h
//  SKCodeBuilder
//
//  Created by shangkun on 2020/4/23.
//  Copyright © 2020 wushangkun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class listModel;
@class dataModel;


@interface TestModel : NSObject

/** eg.  */
@property (nonatomic, copy) NSString *message;
/** data */
@property (nonatomic, strong) dataModel *data;
/** eg. 1 */
@property (nonatomic, assign) NSInteger code;

@end



@interface dataModel : NSObject

/** list */
@property (nonatomic, strong) NSArray <listModel *> *list;

@end



@interface listModel : NSObject

/** bg_img */
@property (nonatomic, copy) NSString *bg_img;
/** eg. #FFFFFF */
@property (nonatomic, copy) NSString *btn_txt_color;
/** eg. 1 */
@property (nonatomic, assign) NSInteger id;
/** eg. #EE775B */
@property (nonatomic, copy) NSString *btn_bg_color;
/** eg. VIP快速过理论 */
@property (nonatomic, copy) NSString *title;
/** jump_url */
@property (nonatomic, copy) NSString *jump_url;
/** eg. 不过包赔 */
@property (nonatomic, copy) NSString *btn_title;
/** btn_right_icon */
@property (nonatomic, copy) NSString *btn_right_icon;
/** eg. 1 */
@property (nonatomic, copy) NSString *mtype;

@end



