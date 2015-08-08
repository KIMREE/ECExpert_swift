//
//  UserInfoManager.swift
//  ECExpert
//
//  Created by Fran on 15/7/31.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class UserInfoManager: NSObject {
    
    private var managedObjectContext: NSManagedObjectContext!
    private var managedObjectModel: NSManagedObjectModel!
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    
    private override init() {
        super.init()
    }
    
    class func shareManager() -> UserInfoManager{
        struct SingleManager{
            static var token: dispatch_once_t = 0
            static var singleManager: UserInfoManager!
        }
        
        dispatch_once(&SingleManager.token, { () -> Void in
            let manager = UserInfoManager()
            
            // 创建数据库
            // 1. 实例化数据模型(将所有定义的模型都加载进来)
            // merge——合并
            manager.managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
            
            // 2. 实例化持久化存储调度，要建立起桥梁，需要模型
            manager.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: manager.managedObjectModel)
            
            // 3. 添加一个持久化的数据库到存储调度
            // 3.1 建立数据库保存在沙盒的URL
            let basicPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first as! NSString
            let filePath = basicPath.stringByAppendingPathComponent(APP_PATH_CHAT_USERINFO)
            let url = NSURL(fileURLWithPath: filePath)
            
            // 3.2 打开或者新建数据库文件
            // 如果文件不存在，则新建之后打开
            // 否者直接打开数据库
            var error: NSError?
            manager.persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error)
            if error == nil{
                manager.managedObjectContext = NSManagedObjectContext()
                manager.managedObjectContext.persistentStoreCoordinator = manager.persistentStoreCoordinator
            }else{
                KMLog("\(error?.localizedDescription)")
            }
            
            SingleManager.singleManager = manager
        })
        
        return SingleManager.singleManager
    }
    
    func queryUserInfoById(userId: String) -> NSMutableArray{
        let array = NSMutableArray()
        let predicate = NSPredicate(format: "userId = '\(userId)'")
        let request = NSFetchRequest(entityName: APP_CORE_DATA_ENTITY_NAME_USERINFO)
        request.predicate = predicate
        
        let rs = managedObjectContext.executeFetchRequest(request, error: nil)
        if rs != nil{
            for u in rs!{
                KMLog("\(u.userId) \(u.name) \(u.portraitUri)")
                array.addObject(u)
            }
        }
        
        return array
    }
    
    func addUserInfo(userId: String, name: String, portraitUri: String) -> Bool{
        let queryArray = queryUserInfoById(userId)
        if queryArray.count == 0{
            let userInfo = NSEntityDescription.insertNewObjectForEntityForName(APP_CORE_DATA_ENTITY_NAME_USERINFO, inManagedObjectContext: managedObjectContext) as! UserInfo
            userInfo.userId = userId
            userInfo.name = name
            userInfo.portraitUri = portraitUri
            
            return managedObjectContext.save(nil)
        }else{
            return updateUserInfo(userId, updateDic: ["name": name, "portraitUri": portraitUri])
        }
    }
    
    func removeUserInfoById(userId: String) -> Bool{
        var result = false
        let request = NSFetchRequest(entityName: APP_CORE_DATA_ENTITY_NAME_USERINFO)
        request.predicate = NSPredicate(format: "userId = '\(userId)'")
        
        let rs = managedObjectContext.executeFetchRequest(request, error: nil)
        if rs != nil{
            for u in rs!{
                KMLog("\(u.userId) \(u.name) \(u.portraitUri)")
                managedObjectContext.deleteObject(u as! NSManagedObject)
            }
            result = managedObjectContext.save(nil)
        }
        
        return result
    }
    
    func updateUserInfo(userId: String, updateDic: NSDictionary!) -> Bool{
        var result = false
        let request = NSFetchRequest(entityName: APP_CORE_DATA_ENTITY_NAME_USERINFO)
        request.predicate = NSPredicate(format: "userId = '\(userId)'")
        
        if updateDic != nil && updateDic.count > 0{
            let rs = managedObjectContext.executeFetchRequest(request, error: nil)
            if rs != nil{
                for u in rs!{
                    KMLog("\(u.userId) \(u.name) \(u.portraitUri)")
                    for (key, value) in updateDic{
                        u.setValue(value, forKey: key as! String)
                    }
                }
                
                result = managedObjectContext.save(nil)
            }
        }
        
        return result
    }
    
}
