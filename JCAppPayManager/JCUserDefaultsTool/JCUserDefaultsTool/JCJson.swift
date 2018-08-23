//
//  JCJson.swift
//  ZhiShiLvDongMasterIOS
//
//  Created by Jackie on 2018/7/26.
//  Copyright © 2018年 Jackie. All rights reserved.
//

import UIKit

//自定义一个JSON协议
protocol JSON: Codable {
    func toJSONString() -> String?
}

//扩展协议方法
extension JSON {
    //将数据转成可用的JSON模型
    func toJSONString() -> String? {
        //encoded对象
        if let encodedData = try? JSONEncoder().encode(self) {
            //从encoded对象获取String
            return String(data: encodedData, encoding: .utf8)
        }
        return nil
    }
}
