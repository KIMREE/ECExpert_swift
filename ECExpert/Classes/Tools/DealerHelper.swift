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
    
    /**
    计算用户当前位置与经销商店铺的距离，根据距离从小到大进行排序
    
    :param: currentLocation 用户当前位置
    :param: dealerArray     经销商店铺列表
    
    :returns: 计算距离并且排序后的经销商店铺列表
    */
    class func distanceFromCurrentLocation(currentLocation: CLLocation, dealerArray: NSArray) -> NSMutableArray{
        var distanceArray = NSMutableArray()
        for item in dealerArray{
            let dealer = NSMutableDictionary(dictionary: item as! NSDictionary)
            let dealerLocation = CLLocation(latitude: (dealer["dealer_lat"] as! NSString).doubleValue, longitude: (dealer["dealer_lng"] as! NSString).doubleValue)
            let distance = currentLocation.distanceFromLocation(dealerLocation)
            dealer["dealer_distance"] = NSString(format: "%.3f", Double(distance / 1000.0))
            distanceArray.addObject(dealer)
        }
        
        distanceArray.sortUsingComparator({ (dic1: AnyObject!, dic2: AnyObject!) -> NSComparisonResult in
            let dealer1 = dic1 as! NSDictionary
            let distance1 = (dealer1["dealer_distance"] as! NSString).doubleValue
            let dealer2 = dic2 as! NSDictionary
            let distance2 = (dealer2["dealer_distance"] as! NSString).doubleValue
            if distance1 > distance2{
                return NSComparisonResult.OrderedDescending
            }else if distance1 < distance2{
                return NSComparisonResult.OrderedAscending
            }else{
                return NSComparisonResult.OrderedSame
            }
        })
        
        return distanceArray
    }
    
}
