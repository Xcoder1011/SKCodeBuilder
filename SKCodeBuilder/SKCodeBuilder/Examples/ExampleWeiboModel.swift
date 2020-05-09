//
//  ExampleWeibotModel.swift
//  SKCodeBuilder
//
//  Created by wushangkun on 2020/05/09.
//  Copyright © 2020 SKCodeBuilder. All rights reserved.
//

import Foundation


class ExampleWeiboModel : NSObject {

    /// 200
    var code: Int = 0
    /// data
    var data: NSDataModel?
    /// author
    var author: NSAuthorModel?
    /// success
    var msg: String?
}


class NSDataModel : NSObject {

    /// last_update
    var last_update: String?
    /// 微博 ‧ 热搜榜
    var name: String?
    /// list
    var list: [NSListModel]?
}


class NSListModel : NSObject {

    /// title
    var title: String?
    /// link
    var link: String?
    /// 373.7万
    var other: String?
}


class NSAuthorModel : NSObject {

    /// Alone88
    var name: String?
    /// desc
    var desc: String?
}
