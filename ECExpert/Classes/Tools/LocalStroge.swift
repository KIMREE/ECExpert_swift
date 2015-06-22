//
//  LocalStroge.swift
//  ECExpert
//
//  Created by Fran on 15/6/11.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

/**
*  归档操作类
*/
class LocalStroge: NSObject {
    class func sharedInstance() -> LocalStroge{
        struct SingletonInstance{
            static var onceToken: dispatch_once_t = 0
            static var instance: LocalStroge? = nil
        }
        dispatch_once(&SingletonInstance.onceToken, { () -> Void in
            SingletonInstance.instance = LocalStroge()
        })
        return SingletonInstance.instance!
    }
    
    private func getFilePath(fileName: String, searchPathDirectory: NSSearchPathDirectory) -> String {
        let basicPath = NSSearchPathForDirectoriesInDomains(searchPathDirectory, NSSearchPathDomainMask.UserDomainMask, true).first as! NSString
        let filePath = basicPath.stringByAppendingPathComponent(fileName)
        return filePath
    }
    
    // MARK: - 对象归档
    /**
    对象归档
    
    :param: obj                 归档对象
    :param: fileName            保存文件名称
    :param: searchPathDirectory 保存目录
    
    :returns: 操作结果
    */
    func addObject(obj: AnyObject!, fileName: String!, searchPathDirectory: NSSearchPathDirectory!) -> Bool{
        let filePath = self.getFilePath(fileName, searchPathDirectory: searchPathDirectory)
        let fileManager = NSFileManager.defaultManager()
        
        var result = false
        result = NSKeyedArchiver.archiveRootObject(obj!, toFile: filePath)
        
        return result
    }
    
    // MARK: - 反归档
    /**
    反归档
    
    :param: fileName            反归档对象文件的文件名
    :param: searchPathDirectory 所在目录
    
    :returns: 反归档后的对象
    */
    func getObject(fileName: String!, searchPathDirectory: NSSearchPathDirectory!) -> AnyObject? {
        let filePath = self.getFilePath(fileName, searchPathDirectory: searchPathDirectory)
        let decodeObj: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath)
        return decodeObj
    }
    
    // MARK: - 删除保存文件
    /**
    删除保存文件
    
    :param: fileName            文件名
    :param: searchPathDirectory 文件所在目录
    
    :returns: <#return value description#>
    */
    func deleteFile(fileName: String, searchPathDirectory: NSSearchPathDirectory) -> Bool{
        let filePath = self.getFilePath(fileName, searchPathDirectory: searchPathDirectory)
        let fileManager = NSFileManager.defaultManager()
        
        var error: NSError?
        if fileManager.fileExistsAtPath(filePath){
            fileManager.removeItemAtPath(filePath, error: &error)
        }
        
        if error == nil{
            return true
        }else{
            KMLog(error!.localizedDescription)
            return false
        }
    }
    
}
