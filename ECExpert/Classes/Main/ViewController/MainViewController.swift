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
    
    private var transitionAnimation: UITabBarTransitionAnimation!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        super.viewDidLoad()
        
        self.initAllViewController()
    }
    
    private func getNavigation(viewController: UIViewController!, imageName: String!, title: String!) -> KMNavigationController{
        let nav = KMNavigationController(rootViewController: viewController)
        viewController.tabBarItem.image = UIImage(named: imageName)
        viewController.tabBarItem.title = title
        viewController.title = title
        return nav
    }
    
    func initAllViewController(){
        self.newsVC = NewsViewController()
        self.newsVC.urlString = APP_URL_NEWS
        self.newsNav = self.getNavigation(newsVC, imageName: "information", title: i18n("News"))
        
        self.nearbyVC = NearByViewController()
        self.nearbyNav = self.getNavigation(nearbyVC, imageName: "circum", title: i18n("Nearby"))
        
        self.loginVC = LoginViewController()
        self.loginNav = self.getNavigation(loginVC, imageName: "Me", title: i18n("Me"))
        
        self.viewControllers = [newsNav! , nearbyNav!, loginNav!]
        self.tabBar.tintColor = KM_COLOR_TABBAR_NAVIGATION
        
        // viewControllers初始化完成之后， 在转场动画中，需要这个数组，用来判断是执行push还是pop
        self.transitionAnimation = UITabBarTransitionAnimation()
        self.transitionAnimation.tabBarSubviewControllers = self.viewControllers
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBarController(tabBarController: UITabBarController, animationControllerForTransitionFromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {        
        return self.transitionAnimation
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
