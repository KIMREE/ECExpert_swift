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
    
    - returns: AFHTTPRequestOperationManager 实例
    */
    class func networkingManager() -> AFHTTPRequestOperationManager! {
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        let contentTypes: Set = ["application/json", "text/json", "text/javascript","text/html", "application/x-javascript"]
        manager.responseSerializer.acceptableContentTypes = contentTypes
        manager.requestSerializer.timeoutInterval = 10
        return manager
    }
    
    class func rongCloudNetTool() -> AFHTTPRequestOperationManager!{
        struct SingleManager{
            static var token: dispatch_once_t = 0
            static var singleInstance: AFHTTPRequestOperationManager!
        }
        dispatch_once(&SingleManager.token, { () -> Void in
            let manager = AFHTTPRequestOperationManager(baseURL: NSURL(string: APP_RONG_CLOUD_URL_BASE))            
            manager.requestSerializer = AFHTTPRequestSerializer()
            manager.responseSerializer = AFJSONResponseSerializer()
            let contentTypes: Set = ["application/json", "text/json", "text/javascript","text/html"]
            manager.responseSerializer.acceptableContentTypes = contentTypes
            manager.requestSerializer.timeoutInterval = 10
            
            SingleManager.singleInstance = manager
        })
        
        let appKeyField = "App-Key"
        let appKey = APP_RONG_CLOUD_KEY
        
        let appSecret = APP_RONG_CLOUD_SECRET
        
        let nonceField = "Nonce"
        let nonce = "\(arc4random_uniform(100000))"
        
        let timestampField = "Timestamp"
        let timestamp = "\(NSDate().timeIntervalSince1970)"
        
        let signatureField = "Signature"
        let signature = "\(appSecret)\(nonce)\(timestamp)".sha1()
        
        SingleManager.singleInstance.requestSerializer.setValue(appKey, forHTTPHeaderField: appKeyField)
        SingleManager.singleInstance.requestSerializer.setValue(nonce, forHTTPHeaderField: nonceField)
        SingleManager.singleInstance.requestSerializer.setValue(timestamp, forHTTPHeaderField: timestampField)
        SingleManager.singleInstance.requestSerializer.setValue(signature, forHTTPHeaderField: signatureField)
        
        return SingleManager.singleInstance
    }
    
}
