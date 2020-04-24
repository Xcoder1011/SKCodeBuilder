
//
//  TestModel.h
//  SKCodeBuilder
//
//  Created by wushangkun on 2020/04/24.
//  Copyright © 2020 SKCodeBuilder. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSKemu4Model;
@class NSKemu1Model;
@class NSScorelistModel;
@class NSWelfare_infoModel;
@class NSCstinfoModel;
@class NSBaseinfoModel;
@class NSCoachModel;
@class NSMenuListModel;
@class NSHotMenuListModel;
@class NSDataModel;


@interface TestModel : NSObject

/** eg.  */
@property (nonatomic, copy) NSString *message;
/** data */
@property (nonatomic, strong) NSDataModel *data;
/** eg. 1 */
@property (nonatomic, assign) NSInteger code;

@end



@interface NSDataModel : NSObject

/** eg. 327666024844836864 */
@property (nonatomic, assign) NSInteger userid;
/** menuList */
@property (nonatomic, strong) NSArray <NSMenuListModel *> *menuList;
/** hotMenuList */
@property (nonatomic, strong) NSArray <NSHotMenuListModel *> *hotMenuList;
/** eg.  */
@property (nonatomic, copy) NSString *bind_popup_tips;
/** eg.  */
@property (nonatomic, copy) NSString *badge_token;
/** token */
@property (nonatomic, copy) NSString *token;
/** coach */
@property (nonatomic, strong) NSCoachModel *coach;
/** welfare_info */
@property (nonatomic, strong) NSWelfare_infoModel *welfare_info;
/** eg. 0 */
@property (nonatomic, assign) NSInteger show_bind_popup;

@end



@interface NSHotMenuListModel : NSObject

/** eg. 1 */
@property (nonatomic, assign) NSInteger mtype;
/** eg. 预约练车 */
@property (nonatomic, copy) NSString *title;
/** eg. 1 */
@property (nonatomic, assign) NSInteger show_badge;
/** icon */
@property (nonatomic, copy) NSString *icon;
/** url */
@property (nonatomic, copy) NSString *url;

@end



@interface NSMenuListModel : NSObject

/** eg. 1 */
@property (nonatomic, assign) NSInteger status;
/** eg. myComments */
@property (nonatomic, copy) NSString *name;
/** eg. 我的评价 */
@property (nonatomic, copy) NSString *title;
/** eg. 1 */
@property (nonatomic, assign) NSInteger orderNum;
/** tips */
@property (nonatomic, copy) NSString *tips;
/** icon */
@property (nonatomic, copy) NSString *icon;
/** url */
@property (nonatomic, copy) NSString *url;

@end



@interface NSCoachModel : NSObject

/** baseinfo */
@property (nonatomic, strong) NSBaseinfoModel *baseinfo;
/** cstinfo */
@property (nonatomic, strong) NSCstinfoModel *cstinfo;
/** scorelist */
@property (nonatomic, strong) NSScorelistModel *scorelist;
/** <#识别不出类型#> */
@property (nonatomic, strong) id dateCarInfo;

@end



@interface NSBaseinfoModel : NSObject

/** eg. 9 */
@property (nonatomic, assign) NSInteger stunum;
/** realmobile */
@property (nonatomic, copy) NSString *realmobile;
/** eg. 170****0002 */
@property (nonatomic, copy) NSString *mobile;
/** eg. 安逸驾校 */
@property (nonatomic, copy) NSString *schoolname;
/** eg. 0 */
@property (nonatomic, assign) NSInteger auth;
/** eg. 10931 */
@property (nonatomic, assign) NSInteger cid;
/** eg. 153 */
@property (nonatomic, assign) NSInteger schoolid;
/** avatar */
@property (nonatomic, copy) NSString *avatar;
/** eg. 0 */
@property (nonatomic, assign) NSInteger frozen;
/** eg. 3.5 */
@property (nonatomic, assign) NSInteger stars;
/** eg. 9 */
@property (nonatomic, assign) NSInteger stuCount;
/** encrypt_cid */
@property (nonatomic, copy) NSString *encrypt_cid;
/** eg. 我是学员02 */
@property (nonatomic, copy) NSString *name;

@end



@interface NSCstinfoModel : NSObject

/** eg. 10426 */
@property (nonatomic, assign) NSInteger cst_id;
/** eg. 5 */
@property (nonatomic, assign) NSInteger cst_anonymous;
/** eg. 0 */
@property (nonatomic, assign) NSInteger cst_auto_bind;
/** eg. 0 */
@property (nonatomic, assign) NSInteger cst_invite_u_id;
/** eg. 1587005713081 */
@property (nonatomic, assign) NSInteger cst_coach_agree_time;
/** eg. 1586514238919 */
@property (nonatomic, assign) NSInteger cst_link_time;
/** eg. 1 */
@property (nonatomic, assign) NSInteger cst_status;
/** eg. 1587005713081 */
@property (nonatomic, assign) NSInteger cst_student_agree_time;
/** eg. 10931 */
@property (nonatomic, assign) NSInteger cst_c_id;

@end



@interface NSWelfare_infoModel : NSObject

/** eg. 不过包赔 */
@property (nonatomic, copy) NSString *light_title;
/** sub_title */
@property (nonatomic, copy) NSString *sub_title;
/** eg. #ff471b */
@property (nonatomic, copy) NSString *light_color;
/** eg. #ffffff */
@property (nonatomic, copy) NSString *btn_text_color;
/** eg. 学员福利 */
@property (nonatomic, copy) NSString *title;
/** eg. #ff471b */
@property (nonatomic, copy) NSString *btn_background_color;
/** icon_url */
@property (nonatomic, copy) NSString *icon_url;
/** eg. 领取 */
@property (nonatomic, copy) NSString *btn_title;
/** exam_url */
@property (nonatomic, copy) NSString *exam_url;
/** url */
@property (nonatomic, copy) NSString *url;

@end



@interface NSScorelistModel : NSObject

/** kemu1 */
@property (nonatomic, strong) NSArray <NSKemu1Model *> *kemu1;
/** kemu4 */
@property (nonatomic, strong) NSArray <NSKemu4Model *> *kemu4;

@end



@interface NSKemu1Model : NSObject

/** eg. 3 */
@property (nonatomic, assign) NSInteger cityid;
/** eg. 1587626796000 */
@property (nonatomic, assign) NSInteger addtime;
/** eg. 12 */
@property (nonatomic, assign) NSInteger score;
/** eg. 0 */
@property (nonatomic, assign) NSInteger cartype;
/** eg. 0 */
@property (nonatomic, assign) NSInteger examtype;
/** eg. 764285491059585024 */
@property (nonatomic, assign) NSInteger id;
/** eg. 70 */
@property (nonatomic, assign) NSInteger time;
/** eg. 0 */
@property (nonatomic, assign) NSInteger userid;
/** eg. 1 */
@property (nonatomic, assign) NSInteger kemu;
/** eg.  */
@property (nonatomic, copy) NSString *ip;
/** eg. 3 */
@property (nonatomic, assign) NSInteger provinceid;

@end



@interface NSKemu4Model : NSObject

/** eg. 3 */
@property (nonatomic, assign) NSInteger cityid;
/** eg. 1564384300000 */
@property (nonatomic, assign) NSInteger addtime;
/** eg. 92 */
@property (nonatomic, assign) NSInteger score;
/** eg. 0 */
@property (nonatomic, assign) NSInteger cartype;
/** eg. 0 */
@property (nonatomic, assign) NSInteger examtype;
/** eg. 666799399213879296 */
@property (nonatomic, assign) NSInteger id;
/** eg. 76 */
@property (nonatomic, assign) NSInteger time;
/** eg. 0 */
@property (nonatomic, assign) NSInteger userid;
/** eg. 4 */
@property (nonatomic, assign) NSInteger kemu;
/** eg.  */
@property (nonatomic, copy) NSString *ip;
/** eg. 3 */
@property (nonatomic, assign) NSInteger provinceid;

@end

