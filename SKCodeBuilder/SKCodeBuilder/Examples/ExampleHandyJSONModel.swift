//
//  ExampleSwiftModel.swift
//  SKCodeBuilder
//
//  Created by wushangkun on 2020/05/08.
//  Copyright © 2020 SKCodeBuilder. All rights reserved.
//

import Foundation

/* >>>>>>>>>>>>>>>>>>>>>>>>>>  for HandyJSON lib.

import HandyJSON

*/

class ExampleSwiftModel : HandyJSON {

    /// 0
    var status: Int = 0
    /// result
    var result: NSResultModel?

    // required init() {}
}


class NSResultModel : HandyJSON {

    /// location
    var location: NSLocationModel?
    /// poiRegions
    var poiRegions: [NSPoiRegionsModel]?
    /// sematic_description
    var sematic_description: String?
    /// addressComponent
    var addressComponent: NSAddressComponentModel?
    /// 289
    var cityCode: Int = 0
    /// 东方路,陆家嘴,外滩
    var business: String?
    /// 上海市浦东新区丰和路
    var formatted_address: String?
    
    /* >>>>>>>>>>>>>>>>>>>>>>>>>>  for HandyJSON lib.
    
    required init() {}
    
    */
}


class NSAddressComponentModel : HandyJSON {

    /// 
    var town_code: String?
    /// CHN
    var country_code_iso: String?
    /// 2
    var city_level: Int = 0
    /// 上海市
    var province: String?
    /// 丰和路
    var street: String?
    /// 
    var town: String?
    /// 
    var street_number: String?
    /// 上海市
    var city: String?
    /// CN
    var country_code_iso2: String?
    /// 浦东新区
    var district: String?
    /// 310115
    var adcode: String?
    /// 
    var distance: String?
    /// 中国
    var country: String?
    /// 
    var direction: String?
    /// 0
    var country_code: Int = 0

    /* >>>>>>>>>>>>>>>>>>>>>>>>>>  for HandyJSON lib.
    
    required init() {}
    
    */
}


class NSLocationModel : HandyJSON {

    /// 121.5065669299999
    var lng: Double?
    /// 31.24530443842053
    var lat: Double?

    /* >>>>>>>>>>>>>>>>>>>>>>>>>>  for HandyJSON lib.
     
     required init() {}
     
     */
}


class NSPoiRegionsModel : HandyJSON {

    /// 0
    var distance: String?
    /// b643224025414952f4e73b2f
    var itemId: String?
    /// 东方明珠广播电视塔
    var name: String?
    /// 内
    var direction_desc: String?
    /// 旅游景点;其他
    var tag: String?

    /* >>>>>>>>>>>>>>>>>>>>>>>>>>  for HandyJSON lib.

    required init() {}

    public func mapping(mapper: HelpingMapper) {

        mapper <<< self.itemId <-- "id"

     }
 
     */
}
