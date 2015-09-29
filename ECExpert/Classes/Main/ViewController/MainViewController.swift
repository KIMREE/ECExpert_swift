//
//  MainViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/12.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController, UITabBarControllerDelegate {
    
    var newsVC: NewsViewController!
    var newsNav: KMNavigationController!
    
    var nearbyVC: NearByViewController!
    var nearbyNav: KMNavigationController!
    
    var loginVC: LoginViewController!
    var loginNav: KMNavigationController!
    
    var customerVC: CustomerViewController!
    var customerNav: KMNavigationController!
    
    var dealerVC: DealerViewController!
    var dealerNav: KMNavigationController!
    
    var emptyVC: KMNavigationController!
    var chatVC: SmokeFriendChatRoomViewController!
    var chatNav: KMNavigationController!
    private var canBeginChat = false
    
    private var transitionAnimation: UITabBarTransitionAnimation!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        super.viewDidLoad()
        
        self.setUpAllViewController()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showLoginViewController", name: APP_NOTIFICATION_LOGIN, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK: - 组装界面
    
    private func getNavigation(viewController: UIViewController!, imageName: String!, title: String!) -> KMNavigationController{
        let nav = KMNavigationController(rootViewController: viewController)
        viewController.tabBarItem.image = UIImage(named: imageName)
        viewController.tabBarItem.title = title
        viewController.title = title
        return nav
    }
    
    func setUpAllViewController(){
        self.newsVC = NewsViewController()
        self.newsVC.urlString = APP_URL_NEWS
        self.newsNav = self.getNavigation(newsVC, imageName: "information", title: i18n("News"))
        
        self.nearbyVC = NearByViewController()
        self.nearbyNav = self.getNavigation(nearbyVC, imageName: "circum", title: i18n("Nearby"))

        self.tabBar.tintColor = KM_COLOR_MAIN
        
        self.showLoginViewController()
    }
    
    // 进入投票界面
    func voteAction(){
        
        let voteNav = getNavigation(VoteViewController(), imageName: "Me", title: i18n("vote"))
        self.presentViewController(voteNav, animated: true) { () -> Void in
            
        }
    }
    
    /**
    根据登陆信息，判断界面需要显示那些view controller
    */
    func showLoginViewController(){
        
        // TODO: 投票功能，暂时不需要上线
//        self.newsVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "voteAction")
        
        // 根据AppDelegate 的 loginUserInfo 判断用户是否已经登陆
        let loginUserInfo = (UIApplication.sharedApplication().delegate as! AppDelegate).loginUserInfo
        var showVCArrays =  NSMutableArray()
//        let selectIndex = self.selectedIndex
        if loginUserInfo == nil{
            if loginVC == nil{
                self.loginVC = LoginViewController()
                self.loginNav = self.getNavigation(loginVC, imageName: "Me", title: i18n("Me"))
            }
            loginVC.view = nil
            showVCArrays = [newsNav! , nearbyNav!, loginNav!]
        }else{
            
            // 连接RongCloud
            self.connectRongCloud()
            
            // 只要登录状态发生变化，都要重新初始化聊天室
            chatVC = SmokeFriendChatRoomViewController(conversationType: RCConversationType.ConversationType_CHATROOM, targetId: APP_RONG_CLOUD_CHATROOM_ID)
            chatNav = self.getNavigation(chatVC, imageName: "chatroom", title: i18n("Smoking Friends"))
            
            let usertype = loginUserInfo!["usertype"] as! Int
            if usertype == 0{
                if customerVC == nil{
                    self.customerVC = CustomerViewController()
                    self.customerNav = self.getNavigation(customerVC, imageName: "Me", title: i18n("Customer Center"))
                }
                customerVC.view = nil
                showVCArrays = [newsNav! , nearbyNav!, customerNav!]
            }else if usertype == 1{
                if dealerVC == nil{
                    self.dealerVC = DealerViewController()
                    self.dealerNav = self.getNavigation(dealerVC, imageName: "Me", title: i18n("Dealer Center"))
                }
                dealerVC.view = nil
                showVCArrays = [newsNav! , nearbyNav!, dealerNav!]
            }
            
            if emptyVC == nil{
                emptyVC = self.getNavigation(UIViewController(), imageName: "chatroom", title: i18n("Smoking Friends"))
            }
            
            // TODO : 烟友会还未正式决定上架
            showVCArrays.addObject(emptyVC)
        }
        
        if self.viewControllers == nil || !showVCArrays.isEqualToArray(self.viewControllers!){
            self.viewControllers = NSArray(array: showVCArrays) as? [UIViewController]
        }
        self.selectedIndex = selectedIndex
        
        // viewControllers初始化完成之后， 在转场动画中，需要这个数组，用来判断是执行push还是pop
        self.transitionAnimation = UITabBarTransitionAnimation(tabBarSubviewControllers: self.viewControllers!)
        
        self.cleanOtherViewController()
    }
    
    //
    func connectRongCloud(){
        canBeginChat = false
        
        let loginUserInfo = (UIApplication.sharedApplication().delegate as! AppDelegate).loginUserInfo
        var userId = ""
        var name = ""
        var portraitUri = ""
        
        if loginUserInfo != nil{
            let userType = loginUserInfo!["usertype"] as! NSInteger
            if userType == 0{
                let customerId = loginUserInfo!["customer_id"] as! String
                let customerVip = loginUserInfo!["customer_vip"] as! String
                
                userId = "\(customerId)_\(customerVip)_0"
                
                name = loginUserInfo!["customer_nickname"] as! String
                if (loginUserInfo!["customer_nickname"] as! String).isEmpty{
                    name = loginUserInfo!["customer_name"] as! String
                }
                
                portraitUri = loginUserInfo!["customer_headimage"] as! String
                
            }else if userType == 1{
                let dealerId = loginUserInfo!["dealer_id"] as! String
                name = loginUserInfo!["dealer_name"] as! String
                
                userId = "\(dealerId)_\(name)_1"
            }
        }
        
        // 获取token
        AFNetworkingFactory.rongCloudNetTool().POST(APP_RONG_CLOUD_URL_GET_TOKEN, parameters: ["userId":userId], success: { [weak self](operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            if self == nil{
                return
            }
            let blockSelf = self!
            let root = responseObj as? NSDictionary
            let code = root?["code"] as? NSInteger
            if code != nil && code == 200{
                let token = root!["token"] as! String
                blockSelf.connectRongCloud(token)
            }
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                KMLog("\(error.localizedDescription)")
        }
        
        RCIM.sharedRCIM().currentUserInfo = RCUserInfo(userId: userId, name: name, portrait: portraitUri)
        RCIM.sharedRCIM().userInfoDataSource = KMUserInfoDataSource.shareDataSource()
    }
    
    // 连接RongCloud
    private func connectRongCloud(token: String){
        RCIM.sharedRCIM().connectWithToken(token, success: { [weak self](userId: String!) -> Void in
            if self == nil{
                return
            }
            let blockSelf = self!
            KMLog("\(userId)")
            blockSelf.canBeginChat = true
            }, error: { (status: RCConnectErrorCode) -> Void in
                KMLog("\(status)")
            }) { () -> Void in
                KMLog("nothing")
        }
    }
    
    // 移除掉不需要显示的viewcontroller
    private func cleanOtherViewController(){
        let showArray = NSArray(array: self.viewControllers!)
        
        if loginNav != nil && !showArray.containsObject(loginNav){
            loginNav = nil
            loginVC = nil
        }
        
        if customerNav != nil && !showArray.containsObject(customerNav){
            customerNav = nil
            customerVC = nil
        }
        
        if dealerNav != nil && !showArray.containsObject(dealerNav){
            dealerNav = nil
            dealerVC = nil
        }
        
    }
    
    // MARK: - 注销登录
    func logout(){
        let alertView = UIAlertView(title: i18n("Logout"), message: i18n("Confirm log out?"), delegate: nil, cancelButtonTitle: i18n("Sure"), otherButtonTitles: i18n("Cancel"))
        alertView.showAlertViewWithCompleteBlock { (buttonIndex) -> Void in
            if buttonIndex == 0{
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let loginUserInfo = appDelegate.loginUserInfo
                
                let params = ["usertype": loginUserInfo!["usertype"] as? Int ?? -1]
                AFNetworkingFactory.networkingManager().POST(APP_URL_LOGOUT, parameters: params, success: { (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
                    let dic = responseObj as? NSDictionary
                    let code = dic?["code"] as? NSInteger
                    if code != nil && code == 1{
                        appDelegate.loginUserInfo = nil
                        let loginProof = LocalStroge.sharedInstance().getObject(APP_PATH_LOGIN_PROOF, searchPathDirectory: NSSearchPathDirectory.DocumentDirectory) as? NSMutableDictionary
                        loginProof?.setValue(false, forKey: APP_PATH_LOGIN_PROOF_AUTOLOGIN)
                        LocalStroge.sharedInstance().addObject(loginProof, fileName: APP_PATH_LOGIN_PROOF, searchPathDirectory: NSSearchPathDirectory.DocumentDirectory)
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(APP_NOTIFICATION_LOGIN, object: nil)
                    }else {
                        KMLog("\(dic)")
                    }
                    
                    }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                        KMLog(error.localizedDescription)
                }
            
            }
        }
    }
    
    // MARK: - 切换动画
    func tabBarController(tabBarController: UITabBarController, animationControllerForTransitionFromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transitionAnimation
    }
    
    // MARK: - UITabBarControllerDelegate
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        var canEnter = true
        if tabBarController.selectedViewController == viewController{
            canEnter = false
        }
        
        // 如果要进入聊天室， 需要根据 canBeginChat 判断是否能进入, 使用模态视图打开聊天室
        if emptyVC != nil && viewController == emptyVC{
            if canBeginChat{
                self.presentViewController(chatNav, animated: true, completion: { () -> Void in
                    
                })
            }
            
            canEnter = false
        }
        return canEnter
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK : - 屏幕旋转， tabView不允许旋转
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait // | UIInterfaceOrientationMask.PortraitUpsideDown | UIInterfaceOrientationMask.LandscapeLeft | UIInterfaceOrientationMask.LandscapeRight
    }

}
