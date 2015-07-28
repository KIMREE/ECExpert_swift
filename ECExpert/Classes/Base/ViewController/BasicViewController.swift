//
//  BasicViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/11.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class BasicViewController: UIViewController {
    
    // 背景图片，默认background
    var bacgroundImage: UIImage?
    
    // 显示 navigation bar, default YES
    var showNaavigationBar:Bool = true
    
    // 信息提示框
    var progressHUD: MBProgressHUD?
    
    // 界面需要登录信息才能展示，默认false
    var needLogin: Bool = false
    
    // 是否第一次进入界面
    private var firstEnter = true
    
    var backgroundImageView: UIImageView?{
        get{
            for view in self.view.subviews{
                if view is UIImageView{
                    return view as? UIImageView
                }
            }
            return nil
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.translucent = true
        self.tabBarController?.tabBar.translucent = true
        
        // 让导航栏全透明
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        
        self.view.frame = UIScreen.mainScreen().bounds
        self.navigationController?.navigationBarHidden = !showNaavigationBar
        
        self.initBackgroundImageView()
        self.initNavigationBar()
        self.initMBProgressHUD()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = !showNaavigationBar
        
        if needLogin{
            let loginUserInfo = currentAppDelegate().loginUserInfo
            if loginUserInfo == nil{
                NSNotificationCenter.defaultCenter().postNotificationName(APP_NOTIFICATION_LOGIN, object: nil)
            }
        }
        
        if !firstEnter{
            
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        firstEnter = false
    }
    
    
    // MARK: - 初始化背景视图
    /**
    初始化背景视图
    
    :returns:
    */
    private func initBackgroundImageView(){
        let backgroundImageView = UIImageView(frame: self.view.frame)
        if bacgroundImage == nil {
            bacgroundImage = UIImage(named: "background")
        }
        backgroundImageView.image = bacgroundImage
        
        self.view.insertSubview(backgroundImageView, atIndex: 0)
    }
    
    
    // MARK: - 初始化navigationBar
    /**
    初始化navigationBar
    
    :returns:
    */
    private func initNavigationBar(){
        var titleTextDic: [String: AnyObject] = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleTextDic
        
        // 当前ViewController 不是 root NavigationController
        let rootViewController: UIViewController? = self.navigationController?.viewControllers.first as? UIViewController
        if rootViewController != self {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "goback"), style: UIBarButtonItemStyle.Plain, target: self, action: "goback")
        }
    }
    
    // MARK: - 返回上级界面
    /**
    返回上级界面
    */
    func goback(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - 初始化 progressHUD
    /**
    初始化 progressHUD
    
    :returns:
    */
    private func initMBProgressHUD(){
        self.progressHUD = MBProgressHUD()
        self.progressHUD?.dimBackground = true
        self.navigationController?.view.addSubview(self.progressHUD!)
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "hideProgressHUD")
//        self.progressHUD?.addGestureRecognizer(tapGesture)
    }
    
    func hideProgressHUD(){
        self.progressHUD?.hide(true)
    }
    
    func hideProgressHUD(delay: NSTimeInterval){
        self.progressHUD?.hide(true, afterDelay: delay)
    }
    
    // MARK: - 获取界面可视部分frame
    func getVisibleFrame() -> CGRect{
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var w: CGFloat = KM_FRAME_SCREEN_WIDTH
        var h: CGFloat = KM_FRAME_SCREEN_HEIGHT
        
        // status bar
        y += KM_FRAME_VIEW_STATUSBAR_HEIGHT
        h -= KM_FRAME_VIEW_STATUSBAR_HEIGHT
        
        if self.navigationController != nil && self.navigationController?.navigationBarHidden == false{
            y += KM_FRAME_VIEW_NAVIGATIONBAR_HEIGHT
            h -= KM_FRAME_VIEW_NAVIGATIONBAR_HEIGHT
        }
        if self.tabBarController != nil && self.tabBarController?.tabBar.hidden == false{
            h -= KM_FRAME_VIEW_TABBAR_HEIGHT
        }
        
        let frame = CGRectMake(x, y, w, h)
        return frame
    }
}
