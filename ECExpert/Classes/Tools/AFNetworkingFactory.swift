//
//  AFNetworkingFactory.swift
//  ECExpert
//
//  Created by Fran on 15/6/11.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class AFNetworkingFactory: NSObject {
    
    /**
    生成 AFHTTPRequestOperationManager 类实例的工厂方法
    这里没有使用单例
    
    :returns: AFHTTPRequestOperationManager 实例
    */
    class func networkingManager() -> AFHTTPRequestOperationManager! {
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        var contentTypes: Set = ["application/json", "text/json", "text/javascript","text/html"]
        manager.responseSerializer.acceptableContentTypes = contentTypes
        manager.requestSerializer.timeoutInterval = 10
        return manager
    }
}
