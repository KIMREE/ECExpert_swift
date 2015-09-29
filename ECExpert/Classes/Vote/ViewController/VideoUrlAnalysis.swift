//
//  VideoUrlAnalysis.swift
//  ECExpert
//
//  Created by Fran on 15/9/14.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

typealias CompleteOneFunc = (NSMutableDictionary) -> Void
typealias CompleteAllFunc = () -> Void

@objc protocol VideoUrlAnalysisCompleteDelegate: NSObjectProtocol{
    optional func AnalysisCompleteOne(vInfo: NSMutableDictionary)
    optional func AnalysisCompleteAll()
}

class VideoUrlAnalysis: NSObject {
    var completeOne: CompleteOneFunc?
    var completeAll: CompleteAllFunc?
    
    weak var delegate: VideoUrlAnalysisCompleteDelegate? = nil
    
    private var tencentInfoManager: AFHTTPRequestOperationManager!
    private var tencentUrlManager: AFHTTPRequestOperationManager!
    
    private var youkuManager: AFHTTPRequestOperationManager!
    
    deinit{
        KMLog("VideoUrlAnalysis deinit")
        
        completeOne = nil
        completeAll = nil
        
        tencentInfoManager.operationQueue.cancelAllOperations()
        tencentUrlManager.operationQueue.cancelAllOperations()
        youkuManager.operationQueue.cancelAllOperations()
        
        tencentInfoManager = nil
        tencentUrlManager = nil
        youkuManager = nil
    }
    
    override init() {
        tencentInfoManager = AFHTTPRequestOperationManager()
        tencentInfoManager.requestSerializer = AFHTTPRequestSerializer()
        tencentInfoManager.responseSerializer = AFHTTPResponseSerializer()
        let contentTypes: Set = ["application/json", "text/json", "text/javascript","text/html", "application/x-javascript"]
        tencentInfoManager.responseSerializer.acceptableContentTypes = contentTypes
        tencentInfoManager.requestSerializer.timeoutInterval = 10
        
        tencentUrlManager = tencentInfoManager.copy() as! AFHTTPRequestOperationManager
        youkuManager =  AFNetworkingFactory.networkingManager()
        
    }
    
    func startAnalysisUrl(urls: Array<String>, completeOne: CompleteOneFunc?, completeAll: CompleteAllFunc?){
        self.completeOne = completeOne
        self.completeAll = completeAll
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self]() -> Void in
            let queue = dispatch_queue_create("get_url_info", nil)
            dispatch_async(queue, { [weak self]() -> Void in
                for urlStr in urls{
                    if self != nil{
                        if urlStr.containsString(YouKuIdentifier){
                            self?.getYouKuUrlInfo(urlStr as String)
                        }else if urlStr.containsString(TencentIdentifier){
                            self?.getTencentUrlInfo(urlStr as String)
                        }
                    }
                }
                
                })
            
            dispatch_barrier_async(queue, { [weak self]() -> Void in
                if self != nil{
                    KMLog("==========================")
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        completeAll?()
                    })
                }
            })
            
        })
    }
    
    
    // 获取优酷视频信息
    func getYouKuUrlInfo(url: String){
//        KMLog("getYouKuUrlInfo")
        
        let vInfo = NSMutableDictionary()
        vInfo.setObject(url, forKey: "baseUrl")
        
        let signal = dispatch_semaphore_create(0)
        youkuManager.completionQueue = dispatch_queue_create("afnetworking", nil)
        
        youkuManager.GET(YouKuApi, parameters: ["client_id" : YouKuClientId, "video_url" : url], success: { [weak self](operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            if self == nil{
                return
            }
            
            let data = responseObj as! NSDictionary
            vInfo.setObject(data["title"]!, forKey: "title")
            vInfo.setObject(data["thumbnail"]!, forKey: "thumbnail")
            vInfo.setObject(data["id"]!, forKey: "vid")
            
            dispatch_sync(dispatch_get_main_queue(), {[weak self] () -> Void in
                if self != nil{
                    self!.completeOne?(vInfo)
                }
            })
            
            dispatch_semaphore_signal(signal)
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                KMLog("getYouKuUrlInfo: \(error.localizedDescription)")
                
                dispatch_sync(dispatch_get_main_queue(), {[weak self] () -> Void in
                    if self != nil{
                        self!.completeOne?(vInfo)
                    }
                })
                
                dispatch_semaphore_signal(signal)
        }
        
        dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER)
    }
    
    // 获取优酷视频信息
    private func getTencentUrlInfo(url: String){
//        KMLog("getTencentUrlInfo")
        
        var tcUrl = url as NSString
        tcUrl = tcUrl.stringByReplacingOccurrencesOfString("http://", withString: "")
        var tcUrlArray = tcUrl.componentsSeparatedByString("/")
        
        //        KMLog("\(tcUrlArray)")
        
        let identifierStr = tcUrlArray[1] ?? ""
        var vid = ""
        if identifierStr == TencentBoke || identifierStr == TencentPage{
            let lastStr = tcUrlArray[tcUrlArray.count - 1] ?? ""
            let lastArray = lastStr.componentsSeparatedByString(".html")
            if lastArray.count > 0{
                vid = lastArray[0] as String
            }
        }else if identifierStr == TencentCover{
            
            if tcUrlArray.count >= 4{
                let vidStr = tcUrlArray[3] ?? ""
                if vidStr.containsString(".html") && vidStr.containsString("vid="){
                    let lastArray = vidStr.componentsSeparatedByString("vid=")
                    if lastArray.count >= 2{
                        let vidStr = lastArray[1]
                        let vidStrArray = vidStr.componentsSeparatedByString("&")
                        vid = vidStrArray[0]
                    }
                }else{
                    if tcUrlArray.count >= 5{
                        let vidStr = tcUrlArray[4] ?? ""
                        let vidStrArray = vidStr.componentsSeparatedByString(".html") 
                        vid = vidStrArray[0]
                    }else{
                        vid = getTencentVidByUrl(url)
                    }
                }
            }
            
        }
        
        if vid != ""{
            getTencentVideoInfo(vid, url:url)
        }
    }
    
    // 解析html内容获得vid
    private func getTencentVidByUrl(url: String) -> String{
//        KMLog("getTencentVidByUrl")
        
        var vid = ""
        
        let data = NSData(contentsOfURL: NSURL(string: url)!)
        let xpath = TFHpple(HTMLData: data)
        let elements = xpath.searchWithXPathQuery("//script")
        
        var jsonStr = ""
        for i in elements as! [TFHppleElement]{
            let i = i as TFHppleElement
            let content = i.raw
            if content.containsString("QZOutputJson="){
                jsonStr = content.stringByReplacingOccurrencesOfString("<script type=\"text/javascript\"><![CDATA[", withString: "").stringByReplacingOccurrencesOfString("QZOutputJson=", withString: "").stringByReplacingOccurrencesOfString("]]></script>", withString: "")
                break
            }
        }
        
        if jsonStr != ""{
            let data = jsonStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            let json = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSDictionary
            let videos = json?.objectForKey("videos") as? NSArray
            if videos != nil && videos!.count > 0{
                let video = videos![0] as! NSDictionary
                vid = video["vid"] as! String
            }
        }else{
            let links = xpath.searchWithXPathQuery("//link")
            for i in links as![TFHppleElement]{
                let rel = i.attributes["rel"] as? String
                if rel != nil && rel == "canonical"{
                    let linkHref  = i.attributes["href"] as? String ?? ""
                    var tcUrlArray = linkHref.stringByReplacingOccurrencesOfString("http://", withString: "").componentsSeparatedByString("/")
                    let vidStr = tcUrlArray[tcUrlArray.count - 1] as String
                    vid = (vidStr.componentsSeparatedByString(".html"))[0]
                    break
                }
            }
        }
        
        return vid
    }
    
    // 根据视频 vid， 获取视频title 和 thumbnail
    private func getTencentVideoInfo(vid: String, url: String){
//        KMLog("getTencentVideoInfo")
        
        let vInfo = NSMutableDictionary()
        vInfo.setObject(url, forKey: "baseUrl")
        vInfo.setObject(vid, forKey: "vid")
        
        let signal = dispatch_semaphore_create(0)
        let manager = tencentInfoManager
        manager.completionQueue = dispatch_queue_create("afnetworking_video_info", nil)
        
        manager.GET(TencentGetInfoApi, parameters: ["otype": "json", "platform": "2", "vids": vid], success: { [weak self](operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            if self == nil{
                return
            }
            var jsonStr = NSString(data: responseObj as! NSData, encoding: NSUTF8StringEncoding)
            jsonStr = jsonStr?.stringByReplacingOccurrencesOfString("QZOutputJson=", withString: "").stringByReplacingOccurrencesOfString(";", withString: "")
            let jsonData = jsonStr?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            let json = (try? NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers)) as? NSDictionary
            
            let title = (((json?["vl"] as! NSDictionary)["vi"] as! NSArray)[0] as! NSDictionary)["ti"] as? NSString ?? ""
            let thumbnail = NSString(format: TencentThumbnail, vid)
            
            vInfo.setObject(title, forKey: "title")
            vInfo.setObject(thumbnail, forKey: "thumbnail")
            
            self?.getTencentVideoAddress(vInfo)
            
            dispatch_semaphore_signal(signal)
            }) { [weak self](operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                KMLog("getTencentVideoInfo: \(error.localizedDescription)")
                
                if self != nil{
                    self?.completeOne?(vInfo)
                }
                
                dispatch_semaphore_signal(signal)
        }
        
        dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER)
        
    }
    
    // 获取 腾讯视频的 真实播放地址
    private func getTencentVideoAddress(vInfo: NSMutableDictionary){
//        KMLog("getTencentVideoAddress")
        
        let signal = dispatch_semaphore_create(0)
        let manager = tencentInfoManager
        manager.completionQueue = dispatch_queue_create("afnetworking_video_url", nil)
        
        manager.GET(TencentGetVideoApi, parameters: ["otype": "json", "platform": "2", "vid": vInfo.objectForKey("vid") ?? ""], success: { [weak self](operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            if self == nil{
                return
            }
            var jsonStr = NSString(data: responseObj as! NSData, encoding: NSUTF8StringEncoding)
            jsonStr = jsonStr?.stringByReplacingOccurrencesOfString("QZOutputJson=", withString: "").stringByReplacingOccurrencesOfString(";", withString: "")
            let jsonData = jsonStr?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            let json = (try? NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers)) as? NSDictionary
            
            let msg = json?["msg"] as? String
            var url = ""
            if msg != nil && msg != ""{
                url = ""
            }else{
                url = ((((json?["vd"] as! NSDictionary)["vi"] as! NSArray)[0] as! NSDictionary)["url"] as? NSString ?? "") as String
            }
            
            vInfo.setObject(url, forKey: "videoUrl")
            
            dispatch_sync(dispatch_get_main_queue(), {[weak self] () -> Void in
                if self != nil{
                    self!.completeOne?(vInfo)
                }
            })
            dispatch_semaphore_signal(signal)
            
            }) { [weak self](operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                KMLog("getTencentVideoAddress: \(error.localizedDescription)")
                
                // 获取 video url 失败的话，就默认 videoUrl 为空字符串
                vInfo.setObject("", forKey: "videoUrl")
                dispatch_sync(dispatch_get_main_queue(), {[weak self] () -> Void in
                    if self != nil{
                        self!.completeOne?(vInfo)
                    }
                })
                
                dispatch_semaphore_signal(signal)
        }
        
        dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER)
        
    }
    
}
