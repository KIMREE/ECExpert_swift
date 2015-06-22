//
//  DealerHelper.swift
//  ECExpert
//
//  Created by Fran on 15/6/18.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class DealerHelper: NSObject {
    
    /**
    获取要显示在地图上面的销售商
    
    :param: array 所有销售商
    
    :returns: 要在地图上显示的销售商
    */
    class func getMapShowDealerArray(array: NSArray!) -> NSArray{
        let showArray = NSMutableArray()
        if array != nil{
            for item in array{
                let dealer = item as? NSDictionary
                let dealer_type = dealer?["dealer_type"] as? String
                if dealer_type != nil && (dealer_type == "1" || dealer_type == "4"){
                    showArray.addObject(dealer!)
                }
            }
        }
        return NSArray(array: showArray)
    }
    
}
