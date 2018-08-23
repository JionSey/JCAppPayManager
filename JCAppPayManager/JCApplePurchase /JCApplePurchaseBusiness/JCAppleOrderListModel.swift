//
//  JCHomeOnlineNumModel.swift
//  ZhiShiLvDongMasterIOS
//
//  Created by Jackie on 2018/8/2.
//  Copyright © 2018年 Jackie. All rights reserved.
//

import Foundation

struct JCAppleOrderListModel: JSON {

    var appleOrderList :[JCAppleOrderItemModel]  = [JCAppleOrderItemModel]()
}

struct JCAppleOrderItemModel: JSON {
    
    var orderId: String = ""
    var receipt: String = ""
    var token: String   = ""
}
