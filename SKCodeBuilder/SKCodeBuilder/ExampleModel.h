//
//  ExampleModel.h
//  SKCodeBuilder
//
//  Created by wushangkun on 2020/04/28.
//  Copyright © 2020 SKCodeBuilder. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSPoiRegionsModel;
@class NSLocationModel;
@class NSAddressComponentModel;
@class NSResultModel;


@interface ExampleModel : NSObject

/** eg. 0 */
@property (nonatomic, assign) NSInteger status;
/** result */
@property (nonatomic, strong) NSResultModel *result;

@end



@interface NSResultModel : NSObject

/** location */
@property (nonatomic, strong) NSLocationModel *location;
/** poiRegions */
@property (nonatomic, strong) NSArray <NSPoiRegionsModel *> *poiRegions;
/** eg. 东方明珠内 */
@property (nonatomic, copy) NSString *sematic_description;
/** addressComponent */
@property (nonatomic, strong) NSAddressComponentModel *addressComponent;
/** eg. 289 */
@property (nonatomic, assign) NSInteger cityCode;
/** eg. 东方路,陆家嘴,外滩 */
@property (nonatomic, copy) NSString *business;
/** eg. 上海市浦东新区丰和路 */
@property (nonatomic, copy) NSString *formatted_address;

@end



@interface NSAddressComponentModel : NSObject

/** eg.  */
@property (nonatomic, copy) NSString *town_code;
/** eg. 0 */
@property (nonatomic, assign) NSInteger country_code;
/** eg. 2 */
@property (nonatomic, assign) NSInteger city_level;
/** eg. 上海市 */
@property (nonatomic, copy) NSString *province;
/** eg. 丰和路 */
@property (nonatomic, copy) NSString *street;
/** eg.  */
@property (nonatomic, copy) NSString *town;
/** eg.  */
@property (nonatomic, copy) NSString *street_number;
/** eg. 上海市 */
@property (nonatomic, copy) NSString *city;
/** eg. CN */
@property (nonatomic, copy) NSString *country_code_iso2;
/** eg. 浦东新区 */
@property (nonatomic, copy) NSString *district;
/** eg. 310115 */
@property (nonatomic, copy) NSString *adcode;
/** eg.  */
@property (nonatomic, copy) NSString *distance;
/** eg. CHN */
@property (nonatomic, copy) NSString *country_code_iso;
/** eg.  */
@property (nonatomic, copy) NSString *direction;
/** eg. 中国 */
@property (nonatomic, copy) NSString *country;

@end



@interface NSLocationModel : NSObject

/** eg. 121.5065669299999 */
@property (nonatomic, assign) CGFloat lng;
/** eg. 31.24530443842053 */
@property (nonatomic, assign) CGFloat lat;

@end



@interface NSPoiRegionsModel : NSObject

/** eg. 文化传媒;广播电视 */
@property (nonatomic, copy) NSString *tag;
/** uid */
@property (nonatomic, copy) NSString *uid;
/** name */
@property (nonatomic, copy) NSString *name;
/** eg. 0 */
@property (nonatomic, copy) NSString *distance;
/** eg. 内 */
@property (nonatomic, copy) NSString *direction_desc;

@end

