//
//  JCUserDefaultsTool.swift
//  ZhiShiLvDongMasterIOS
//
//  Created by Jackie on 2018/7/26.
//  Copyright © 2018年 Jackie. All rights reserved.
//

import UIKit

// 该类是对Defaults的二次封装，添加缓存对象方法
class JCUserDefaultsTool: NSObject {
    
    // 将字符串转成data类型
    func transformStringToData(string: String?) -> Data? {
        
        guard let okString = string else {
            return nil
        }
        let data = okString.data(using: String.Encoding.utf8)
        guard let okData = data else {
            return nil
        }
        return okData
    }
    
    // 保存对象类型
    class func save(model : JSON?, key : String) {
        
        let str = model?.toJSONString()
        UserDefaults.standard.set(str, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    // 获取对象类型
    class func getModel<T: Decodable>(key : String, typeString: T.Type) -> JSON? {
        
        let str : String? = UserDefaults.standard.object(forKey: key) as? String
        guard let okData = JCUserDefaultsTool.init().transformStringToData(string: str) else {
            return nil
        }
        let baseModel = try? JSONDecoder().decode(typeString, from: okData)
        guard let okBaseModel = baseModel else {
            return nil
        }
        return okBaseModel as? JSON
    }
}
