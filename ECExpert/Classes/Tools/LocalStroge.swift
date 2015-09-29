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
        let basicPath = NSSearchPathForDirectoriesInDomains(searchPathDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
        let filePath = basicPath?.stringByAppendingString("/").stringByAppendingString(fileName)
        return filePath!
    }
    
    // MARK: - 对象归档
    /**
    对象归档
    
    - parameter obj:                 归档对象
    - parameter fileName:            保存文件名称
    - parameter searchPathDirectory: 保存目录
    
    - returns: 操作结果
    */
    func addObject(obj: AnyObject!, fileName: String!, searchPathDirectory: NSSearchPathDirectory!) -> Bool{
        let filePath = self.getFilePath(fileName, searchPathDirectory: searchPathDirectory)
        
        var result = false
        result = NSKeyedArchiver.archiveRootObject(obj!, toFile: filePath)
        
        return result
    }
    
    // MARK: - 反归档
    /**
    反归档
    
    - parameter fileName:            反归档对象文件的文件名
    - parameter searchPathDirectory: 所在目录
    
    - returns: 反归档后的对象
    */
    func getObject(fileName: String!, searchPathDirectory: NSSearchPathDirectory!) -> AnyObject? {
        let filePath = self.getFilePath(fileName, searchPathDirectory: searchPathDirectory)
        let decodeObj: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath)
        return decodeObj
    }
    
    // MARK: - 删除保存文件
    /**
    删除保存文件
    
    - parameter fileName:            文件名
    - parameter searchPathDirectory: 文件所在目录
    
    - returns: 删除文件操作结果
    */
    func deleteFile(fileName: String, searchPathDirectory: NSSearchPathDirectory) -> Bool{
        let filePath = self.getFilePath(fileName, searchPathDirectory: searchPathDirectory)
        let fileManager = NSFileManager.defaultManager()
        
        var error: NSError?
        if fileManager.fileExistsAtPath(filePath){
            do {
                try fileManager.removeItemAtPath(filePath)
            } catch let error1 as NSError {
                error = error1
            }
        }
        
        if error == nil{
            return true
        }else{
            KMLog(error!.localizedDescription)
            return false
        }
    }
    
}
