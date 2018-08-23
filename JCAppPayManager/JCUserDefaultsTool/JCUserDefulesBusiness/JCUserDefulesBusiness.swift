//
//  JCUserDefulesBusiness.swift
//  ZhiShiLvDongMasterIOS
//
//  Created by Jackie on 2018/7/26.
//  Copyright © 2018年 Jackie. All rights reserved.
//

import UIKit

// 该类是缓存对象业务层

// 缓存对象类型(业务)
// 注意：需要缓存的对象模型 必须继承JSON类

private let applePayOrderListModel = "applePayOrderListModel"

extension JCUserDefaultsTool {
    
    // ApplePay 漏单缓存
    class func saveAppleOrderListModel(model : JCAppleOrderListModel) {

        JCUserDefaultsTool.save(model: model, key: applePayOrderListModel)
    }

    class func getAppleOrderListModel() -> JCAppleOrderListModel {
        
        if let appleOrderListModel = JCUserDefaultsTool.getModel(key: applePayOrderListModel, typeString: JCAppleOrderListModel.self) as? JCAppleOrderListModel {
            return appleOrderListModel
        } else {
            let emptyPppleOrderListModel = JCAppleOrderListModel.init(appleOrderList: [JCAppleOrderItemModel]())
            JCUserDefaultsTool.saveAppleOrderListModel(model: emptyPppleOrderListModel)
            return emptyPppleOrderListModel
        }
    }
}
