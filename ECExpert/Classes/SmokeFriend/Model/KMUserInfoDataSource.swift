//
//  KMUserInfoDataSource.swift
//  ECExpert
//
//  Created by Fran on 15/7/31.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class KMUserInfoDataSource: NSObject, RCIMUserInfoDataSource {
    
    private override init() {
        super.init()
    }
    
    // 缓存，避免重复走CoreData
    private let dataSourceMap = NSMutableDictionary()
    
    class func shareDataSource() -> KMUserInfoDataSource{
        struct SingleDataSource{
            static var token: dispatch_once_t = 0
            static var dataSource: KMUserInfoDataSource!
        }
        
        dispatch_once(&SingleDataSource.token, { () -> Void in
            SingleDataSource.dataSource = KMUserInfoDataSource()
        })
        
        return SingleDataSource.dataSource
    }
    
    func getUserInfoWithUserId(userId: String!, completion: ((RCUserInfo!) -> Void)!) {
        let nullRc = RCUserInfo()
        
        if userId == nil{
            completion(nullRc)
        }else{
            var dataKeyValue = NSMutableDictionary()
            
            if self.dataSourceMap.objectForKey(userId) != nil{
                dataKeyValue = self.dataSourceMap.objectForKey(userId) as! NSMutableDictionary
                completion(RCUserInfo(userId: dataKeyValue["userId"] as! String, name: dataKeyValue["name"] as! String, portrait: dataKeyValue["portraitUri"] as! String))
            }else{
                let userArray = UserInfoManager.shareManager().queryUserInfoById(userId)
                if userArray.count > 0{
                    let userInfo: UserInfo = userArray[0] as! UserInfo
                    
                    dataKeyValue["userId"] = userInfo.userId
                    dataKeyValue["name"] = userInfo.name
                    dataKeyValue["portraitUri"] = userInfo.portraitUri
                    self.dataSourceMap.setObject(dataKeyValue, forKey: userId)
                    
                    let rc = RCUserInfo(userId: userInfo.userId, name: userInfo.name, portrait: userInfo.portraitUri)
                    completion(rc)
                }else{
                    let array = userId.componentsSeparatedByString("_")
                    if array.count == 3{
                        let userType = (array[2] as NSString).integerValue
                        if userType == 1{
                            // 销售商
                            // 销售商userId = "\(dealerId)_\(name)_1"
                            let rc = RCUserInfo(userId: userId, name: array[1], portrait: "")
                            UserInfoManager.shareManager().addUserInfo(rc.userId, name: rc.name, portraitUri: rc.portraitUri)
                            
                            dataKeyValue["userId"] = rc.userId
                            dataKeyValue["name"] = rc.name
                            dataKeyValue["portraitUri"] = rc.portraitUri
                            self.dataSourceMap.setObject(dataKeyValue, forKey: userId)
                            
                            completion(rc)
                        }else{
                            // 普通客户
                            // userId = "\(customerId)_\(customerVip)_0"
                            AFNetworkingFactory.networkingManager().POST(APP_URL_CHECKVIP, parameters: ["customer_id": array[0], "customer_vip": array[1]], success: { (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
                                let root = responseObj as? NSDictionary
                                let code = root?["code"] as? NSInteger
                                if code != nil && code == 1{
                                    let customerDic = root!["data"] as! NSDictionary
                                    
                                    var name = customerDic["customer_nickname"] as! String
                                    if name.isEmpty{
                                        name = customerDic["customer_name"] as! String
                                    }
                                    
                                    var portraitUri = customerDic["customer_headimage"] as! String
                                    let rc = RCUserInfo(userId: userId, name: name, portrait: portraitUri)
                                    dataKeyValue["userId"] = rc.userId
                                    dataKeyValue["name"] = rc.name
                                    dataKeyValue["portraitUri"] = rc.portraitUri
                                    self.dataSourceMap.setObject(dataKeyValue, forKey: userId)
                                    
                                    UserInfoManager.shareManager().addUserInfo(rc.userId, name: rc.name, portraitUri: rc.portraitUri)
                                    completion(rc)
                                    
                                }else{
                                    completion(nullRc)
                                }
                                
                                }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                                    KMLog("\(error.localizedDescription)")
                                    completion(nullRc)
                            })
                        }
                    }else{
                        completion(nullRc)
                    }
                }
            }
        }
    }
    
    func getNewestChatUserInfo(userId: String, completion: ((userInfoDic :NSDictionary, valueChanged: Bool) -> Void)!){
        let array = userId.componentsSeparatedByString("_")
        var dic = NSMutableDictionary()
        if array.count == 3{
            let userType = (array[2] as NSString).integerValue
            let coreDataUserInfoArray = UserInfoManager.shareManager().queryUserInfoById(userId)
            
            if coreDataUserInfoArray.count > 0{
                let coreDataUserInfo = coreDataUserInfoArray[0] as! UserInfo
                
                if userType == 1{
                    // 销售商
                    // 销售商userId = "\(dealerId)_\(name)_1"
                    // 目前情况下， 销售商信息不会发生改变
                    
                }else{
                    // 普通客户
                    // userId = "\(customerId)_\(customerVip)_0"
                    AFNetworkingFactory.networkingManager().POST(APP_URL_CHECKVIP, parameters: ["customer_id": array[0], "customer_vip": array[1]], success: { (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
                        let root = responseObj as? NSDictionary
                        let code = root?["code"] as? NSInteger
                        if code != nil && code == 1{
                            let customerDic = root!["data"] as! NSDictionary
                            var valueChanged = false
                            
                            var name = customerDic["customer_nickname"] as! String
                            if name.isEmpty{
                                name = customerDic["customer_name"] as! String
                            }
                            var portraitUri = customerDic["customer_headimage"] as! String
                            
                            if coreDataUserInfo.name != name || coreDataUserInfo.portraitUri != portraitUri{
                                dic.setValue(userId, forKey: "userId")
                                dic.setValue(name, forKey: "name")
                                dic.setValue(portraitUri, forKey: "portraitUri")
                                
                                valueChanged = true
                                
                                self.dataSourceMap.removeObjectForKey(userId)
                                UserInfoManager.shareManager().updateUserInfo(userId, updateDic: dic)
                            }
                            
                            completion(userInfoDic: dic, valueChanged: valueChanged)
                            
                        }else{
                            completion(userInfoDic: dic, valueChanged: false)
                        }
                        
                        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                            KMLog("\(error.localizedDescription)")
                            completion(userInfoDic: dic, valueChanged: false)
                    })
                
                }
            }else{
                completion(userInfoDic: dic, valueChanged: false)
            }
            
        }else{
            completion(userInfoDic: dic, valueChanged: false)
        }
    }
}
