//
//  AFNetworkingFactory.swift
//  ECExpert
//
//  Created by Fran on 15/6/11.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class AFNetworkingFactory: NSObject {
    class func networkingManager() -> AFHTTPRequestOperationManager! {
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        var contentTypes: Set = ["application/json", "text/json", "text/javascript","text/html"]
        manager.responseSerializer.acceptableContentTypes = contentTypes
        return manager
    }
}
