//
//  AppDelegate.swift
//  ECExpert
//
//  Created by Fran on 15/6/11.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit
//import Fabric
//import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var hud: MBProgressHUD?
    var loginUserInfo: Dictionary<String, AnyObject>?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        /**
        *  崩溃信息监测,详情查看 http://www.infoq.com/cn/articles/crashlytics-crash-statistics-tools
        */
//        Fabric.with([Crashlytics()])
        
        // 初始化window
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()
        
        let mainVC = MainViewController()
        self.window?.rootViewController = mainVC
        
        // 初始化 AppDelegate 中需要使用的 MBProgressHUD
        self.hud = MBProgressHUD()
        self.window?.addSubview(self.hud!)
        self.hud!.dimBackground = true
        self.hud!.mode = MBProgressHUDMode.Text
        
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
    :returns: 应用的本地版本号
    */
    func getLocalVersion() -> Double? {
        let dic = bundleInfoDictionary()
        let localVersionString = dic?["CFBundleShortVersionString"] as? NSString
        return localVersionString?.doubleValue
    }
    
    // MARK: - 检查更新
    func checkForUpdate(){
        let manager = AFNetworkingFactory.networkingManager()
        manager.GET(APP_URL, parameters: nil, success: { (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            let remoteAppInfoDic = responseObj as? Dictionary<String, AnyObject>
            let remoteResultArray = remoteAppInfoDic?["results"] as? Array<AnyObject>
            let remoteAppInfo = remoteResultArray?.last as? Dictionary<String, AnyObject>
            let remoteVersionString = remoteAppInfo?["version"] as? NSString
            let remoteVersion = remoteVersionString?.doubleValue
            let localVersion = self.getLocalVersion()
            
            if remoteVersion != nil && localVersion != nil && remoteVersion! > localVersion!{
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
    
    // MARK: - 启动网络连接状况监听
    func startNetStatusListener(){
        let manager = AFNetworkingFactory.networkingManager()
        manager.reachabilityManager.setReachabilityStatusChangeBlock { (status: AFNetworkReachabilityStatus) -> Void in
            switch status{
            case .ReachableViaWiFi,.ReachableViaWWAN:
                KMLog("net work well")
            case .Unknown, .NotReachable:
                
                self.hud!.detailsLabelText = i18n("Unable to connect to the network")
                self.hud!.minShowTime = 2
                self.hud!.showAnimated(true, whileExecutingBlock: { () -> Void in
                    
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
                manager.POST(APP_URL_LOGIN, parameters: loginProof!, success: { [unowned self,loginProof] (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void  in
                    let basicDic = responseObj as? NSDictionary
                    let code = basicDic?["code"] as? NSInteger
                    if code != nil && code == 1{
                        let resultInfo = basicDic!["data"] as! Dictionary<String, AnyObject>
                        
                        // sid 在每次登录之后都会发生改变
                        loginProof!.setValue(resultInfo["sid"], forKey: APP_PATH_LOGIN_PROOF_SID)
                        LocalStroge.sharedInstance().addObject(loginProof, fileName: APP_PATH_LOGIN_PROOF, searchPathDirectory: NSSearchPathDirectory.DocumentDirectory)
                        
                        self.loadLoginUserInfo(loginProof!)
                    }
                    }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                        KMLog("\(error.localizedDescription)")
                })
            }
        }

    }
    
    // MARK: 获取登录用户的信息
    /**
    :param: params 查询登录用户信息需要的参数
    */
    func loadLoginUserInfo(params: NSDictionary!){
        let manager = AFNetworkingFactory.networkingManager()
        manager.POST(APP_URL_LOGIN_USERINFO, parameters: params, success: {[unowned self] (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            let basicDic = responseObj as? NSDictionary
            let code = basicDic?["code"] as? NSInteger
            if code != nil && code == 1{
                let resultInfo = basicDic!["data"] as! Dictionary<String, AnyObject>
                self.loginUserInfo = resultInfo
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
        if APP_SYS_DEVICE_VERSION >= 8{
            let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }else{
            application.registerForRemoteNotificationTypes(UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert)
        }
    }
    
    // MARK: - 远程推送代理
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        KMLog("didRegisterUserNotificationSettings : \(notificationSettings)")
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let pushToken = deviceToken.description.stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "")
        KMLog("\(deviceToken)    :    \(pushToken)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        KMLog("didReceiveRemoteNotification : \(userInfo)")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        KMLog("didFailToRegisterForRemoteNotificationsWithError : \(error.localizedDescription)")
    }
}

