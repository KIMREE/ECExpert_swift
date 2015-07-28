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
    
    /**
    根据登陆信息，判断界面需要显示那些view controller
    */
    func showLoginViewController(){
        // 根据AppDelegate 的 loginUserInfo 判断用户是否已经登陆
        let loginUserInfo = (UIApplication.sharedApplication().delegate as! AppDelegate).loginUserInfo
        var showVCArrays =  NSMutableArray()
        let selectIndex = self.selectedIndex
        if loginUserInfo == nil{
            if loginVC == nil{
                self.loginVC = LoginViewController()
                self.loginNav = self.getNavigation(loginVC, imageName: "Me", title: i18n("Me"))
            }
            loginVC.view = nil
            showVCArrays = [newsNav! , nearbyNav!, loginNav!]
        }else{
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
        }
        
//        let dateVC = DatePickerViewController()
//        let dateNav = self.getNavigation(dateVC, imageName: "Me", title: "Date")
//        showVCArrays.addObject(dateNav)
        
        if self.viewControllers == nil || !showVCArrays.isEqualToArray(self.viewControllers!){
            self.viewControllers = showVCArrays as [AnyObject]
        }
        self.selectedIndex = selectedIndex
        
        // viewControllers初始化完成之后， 在转场动画中，需要这个数组，用来判断是执行push还是pop
        self.transitionAnimation = UITabBarTransitionAnimation()
        self.transitionAnimation.tabBarSubviewControllers = self.viewControllers
        
        self.cleanOtherViewController()
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
        if tabBarController.selectedViewController == viewController{
            return false
        }
        return true
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
