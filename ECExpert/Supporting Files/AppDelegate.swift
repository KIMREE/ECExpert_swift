//
//  AppDelegate.swift
//  ECExpert
//
//  Created by Fran on 15/6/11.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var hud: MBProgressHUD?
    var loginUserInfo: Dictionary<String, AnyObject>?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        /**
        *  崩溃信息监测,详情查看 http://www.infoq.com/cn/articles/crashlytics-crash-statistics-tools
        */
        Fabric.with([Crashlytics.self()])
        
        // 初始化window
        self.window = UIWindow(frame: KM_FRAME_SCREEN_BOUNDS)
        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()
        
        let mainVC = MainViewController()
        self.window?.rootViewController = mainVC
        
        // 初始化融云SDK
        self.setUpRongCloud()
        
        // 初始化 AppDelegate 中需要使用的 MBProgressHUD
        self.hud = MBProgressHUD()
        self.window?.addSubview(self.hud!)
        self.hud!.dimBackground = true
        self.hud!.mode = MBProgressHUDMode.Text
        
        // 修改状态栏显示电池电量、时间、网络部分标示的颜色
        // 在 info.plist 中，将 View controller-based status bar appearance 设为 NO
        // 启动界面也变成白色 ： 在 info.plist 中， Status bar style 设置为 UIStatusBarStyleLightContent
        // 默认的黑色（UIStatusBarStyleDefault）    白色（UIStatusBarStyleLightContent）
        // UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        //设置状态栏通知样式
        JDStatusBarNotification.setDefaultStyle { (style: JDStatusBarStyle!) -> JDStatusBarStyle! in
            style.barColor = UIColor.blackColor()
            style.textColor = UIColor.whiteColor()
            style.animationType = JDStatusBarAnimationType.Move
            style.font = UIFont.systemFontOfSize(12.0)
            return style
        }
        
        // 检查更新
        self.checkForUpdate()
        
        //启动网络连接状况监听
        self.startNetStatusListener()
        
        // 自动登陆
        self.autoLogin()
        
        // 显示引导图
        self.showGuideView()
        
        // 注册远程推送
        self.registerAPNS()
        
        // 在 App 启动时注册百度云推送服务，需要提供 Apikey
        BPush.registerChannel(launchOptions, apiKey: "5Gn0GP2BtXyqmjjT2rAGh9rS", pushMode: BPushMode.Production, withFirstAction: nil, withSecondAction: nil, withCategory: nil, isDebug: false)
        // 处理远程推送消息
        if launchOptions != nil{
            let remoteInfo = launchOptions![UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject]
            if remoteInfo != nil{
                KMLog("remote info: \(remoteInfo)")
                
                BPush.handleNotification(remoteInfo!)
            }
        }
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - 显示使用引导图
    func showGuideView(){
        let userDefaults = getUserDefaults()
        let firstLunch = userDefaults.stringForKey(APP_KEY_FIRST_LUNCH)
        if firstLunch != APP_KEY_FIRST_LUNCH{
            let guideView = GuideView()
            guideView.showInView(self.window!)
            userDefaults.setObject(APP_KEY_FIRST_LUNCH, forKey: APP_KEY_FIRST_LUNCH)
            userDefaults.synchronize()
        }
    }
    
    // MARK: - 获取本地版本号
    /**
    - returns: 应用的本地版本号
    */
    func getLocalVersion() -> String? {
        let dic = bundleInfoDictionary()
        let localVersionString = dic?["CFBundleShortVersionString"] as? String
        return localVersionString
    }
    
    // MARK: - 检查更新
    func checkForUpdate(){
        let manager = AFNetworkingFactory.networkingManager()
        manager.GET(APP_URL, parameters: nil, success: { [weak self](operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            if self == nil{
                return
            }
            let blockSelf = self!
            let remoteAppInfoDic = responseObj as? Dictionary<String, AnyObject>
            let remoteResultArray = remoteAppInfoDic?["results"] as? Array<AnyObject>
            let remoteAppInfo = remoteResultArray?.last as? Dictionary<String, AnyObject>
            let remoteVersionString = remoteAppInfo?["version"] as? String
            let localVersion = blockSelf.getLocalVersion()
            
            if blockSelf.needUpdate(localVersion, remoteVersion: remoteVersionString){
                let alertView = UIAlertView(title: i18n("There is a new version, do you want to update?"), message: "", delegate: nil, cancelButtonTitle: i18n("Update later"), otherButtonTitles: i18n("Update now"))
                alertView.showAlertViewWithCompleteBlock({ (buttonIndex) -> Void in
                    if buttonIndex == 1 {
                        UIApplication.sharedApplication().openURL(NSURL(string: APP_URL_ITUNES)!)
                    }
                })
            }
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                KMLog("\(error.localizedDescription)")
        }
    }
    
    /**
    判断版本是否需要跟新
    
    版本号为 xx.xx.xx格式，需要分段进行比较
    
    - parameter localVersion:  本地版本号
    - parameter remoteVersion: 远程app store版本号
    
    - returns: 是否需要跟新
    */
    func needUpdate(localVersion: String?, remoteVersion: String?) -> Bool{
        var update = false
        if localVersion != nil && remoteVersion != nil{
            let local = localVersion!.componentsSeparatedByString(".")
            let remote = remoteVersion!.componentsSeparatedByString(".")
            
            update = false
            let length = min(local.count, remote.count)
            var verEqual = true
            for i in 0..<length{
                let localV = (local[i] as NSString).doubleValue
                let remoteV = (remote[i] as NSString).doubleValue
                if remoteV > localV{
                    verEqual = false
                    update = true
                    break
                }else if remoteV == localV{
                    verEqual = true
                    continue
                }else{
                    verEqual = false
                    update = false
                    break
                }
            }
            if verEqual{
                if remote.count > local.count{
                    update = true
                }
            }
            
        }
        return update
    }
    
    // MARK: - 启动网络连接状况监听
    func startNetStatusListener(){
        let manager = AFNetworkingFactory.networkingManager()
        manager.reachabilityManager.setReachabilityStatusChangeBlock {[weak self] (status: AFNetworkReachabilityStatus) -> Void in
            if self == nil{
                return
            }
            let blockSelf = self!
            switch status{
            case .ReachableViaWiFi,.ReachableViaWWAN:
                KMLog("net work well")
            case .Unknown, .NotReachable:
                
                blockSelf.hud!.detailsLabelText = i18n("Unable to connect to the network")
                blockSelf.hud!.minShowTime = 2
                blockSelf.hud!.showAnimated(true, whileExecutingBlock: { () -> Void in
                    blockSelf.hud!.hide(true)
                })
            }
        }
        manager.reachabilityManager.startMonitoring()
    }
    
    // MARK: - 自动登陆
    func autoLogin(){
        let loginProof = LocalStroge.sharedInstance().getObject(APP_PATH_LOGIN_PROOF, searchPathDirectory: NSSearchPathDirectory.DocumentDirectory) as? NSMutableDictionary
        if loginProof != nil && loginProof![APP_PATH_LOGIN_PROOF_AUTOLOGIN] != nil{
            let autoLogin = loginProof![APP_PATH_LOGIN_PROOF_AUTOLOGIN] as! Bool
            if autoLogin{
                let manager = AFNetworkingFactory.networkingManager()
                manager.POST(APP_URL_LOGIN, parameters: loginProof!, success: { [weak self,loginProof] (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void  in
                    if self == nil{
                        return
                    }
                    let blockSelf = self!
                    let basicDic = responseObj as? NSDictionary
                    let code = basicDic?["code"] as? NSInteger
                    if code != nil && code == 1{
                        let resultInfo = basicDic!["data"] as! Dictionary<String, AnyObject>
                        
                        // sid 在每次登录之后都会发生改变
                        loginProof!.setValue(resultInfo["sid"], forKey: APP_PATH_LOGIN_PROOF_SID)
                        LocalStroge.sharedInstance().addObject(loginProof, fileName: APP_PATH_LOGIN_PROOF, searchPathDirectory: NSSearchPathDirectory.DocumentDirectory)
                        
                        blockSelf.loadLoginUserInfo(loginProof!)
                    }
                    }, failure: {(operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                        KMLog("\(error.localizedDescription)")
                })
            }
        }

    }
    
    // MARK: 获取登录用户的信息
    /**
    - parameter params: 查询登录用户信息需要的参数
    */
    func loadLoginUserInfo(params: NSDictionary!){
        let manager = AFNetworkingFactory.networkingManager()
        manager.POST(APP_URL_LOGIN_USERINFO, parameters: params, success: { [weak self](operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            if self == nil{
                return
            }
            let blockSelf = self!
            let basicDic = responseObj as? NSDictionary
            let code = basicDic?["code"] as? NSInteger
            if code != nil && code == 1{
                let resultInfo = basicDic!["data"] as! Dictionary<String, AnyObject>
                blockSelf.loginUserInfo = resultInfo
                KMLog("\(resultInfo as NSDictionary)")
                LocalStroge.sharedInstance().addObject(resultInfo, fileName: APP_PATH_LOGINUSER_INFO, searchPathDirectory: NSSearchPathDirectory.DocumentDirectory)
                
                NSNotificationCenter.defaultCenter().postNotificationName(APP_NOTIFICATION_LOGIN, object: nil)
            }
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                KMLog("\(error.localizedDescription)")
        }
    }
    
    // MARK: - 注册远程推送
    func registerAPNS(){
        let application = UIApplication.sharedApplication()
        if #available(iOS 8.0, *) {
            let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Badge, UIUserNotificationType.Sound, UIUserNotificationType.Alert], categories: nil)
            application.registerUserNotificationSettings(settings)
//            application.registerForRemoteNotifications()
        } else {
            // Fallback on earlier versions
            application.registerForRemoteNotificationTypes([UIRemoteNotificationType.Badge, UIRemoteNotificationType.Sound, UIRemoteNotificationType.Alert])
        }
    }
    
    // MARK: - 远程推送代理
    @available(iOS 8.0, *)
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        KMLog("didRegisterUserNotificationSettings : \(notificationSettings)")
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // 融云
        let pushToken = deviceToken.description.stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
        RCIMClient.sharedRCIMClient().setDeviceToken(pushToken)
        
        // 百度
        BPush.registerDeviceToken(deviceToken)
        BPush.bindChannelWithCompleteHandler { (result: AnyObject!, error: NSError!) -> Void in
            KMLog("result : \(result)")
        }
        
        KMLog("\(deviceToken)    :    \(pushToken)")
    }
    
    // 当 DeviceToken 获取失败时，系统会回调此方法
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        KMLog("didFailToRegisterForRemoteNotificationsWithError : \(error.localizedDescription)")
    }
    
    // App 收到推送的通知
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        KMLog("didReceiveRemoteNotification : \(userInfo)")
        
        BPush.handleNotification(userInfo)
    }
    
    // 接收到本地通知
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        KMLog("本地通知")
        BPush.showLocalNotificationAtFront(notification, identifierKey: nil)
    }
    
    // MARK: - 初始化融云SDK
    func setUpRongCloud(){
        RCIM.sharedRCIM().initWithAppKey(APP_RONG_CLOUD_KEY)
        
        // 判断聊天室是否存在
        AFNetworkingFactory.rongCloudNetTool().POST(APP_RONG_CLOUD_URL_QUERY_CHATROOM, parameters: ["chatroomId":APP_RONG_CLOUD_CHATROOM_ID], success: { [weak self](operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            if self == nil{
                return
            }
            let blockSelf = self!
            let root = responseObj as? NSDictionary
            let code = root?["code"] as? NSInteger
            if code != nil && code == 200{
                let chatRoomArray = root!["chatRooms"] as! NSArray
                if chatRoomArray.count == 0 {
                    blockSelf.createChatRoom(APP_RONG_CLOUD_CHATROOM_ID, chatroomName: APP_RONG_CLOUD_CHATROOM_NAME)
                }else{
                    KMLog("query chatroom ok!")
                }
            }
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                KMLog("\(error.localizedDescription)")
        }
    }
    
    private func createChatRoom(chatroomId: String, chatroomName: String){
        // 创建聊天室
        AFNetworkingFactory.rongCloudNetTool().POST(APP_RONG_CLOUD_URL_CREATE_CHATROOM, parameters: ["chatroom[\(chatroomId)]":chatroomName], success: { (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            let root = responseObj as? NSDictionary
            let code = root?["code"] as? NSInteger
            if code != nil && code == 200{
                KMLog("create chatroom ok!")
            }
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                KMLog("\(error.localizedDescription)")
        }
        
    }
}

