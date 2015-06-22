//
//  NewsViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/13.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class NewsViewController: BasicViewController, UIWebViewDelegate, UIGestureRecognizerDelegate, NJKWebViewProgressDelegate {
    
    var urlString: String!
    
    private var progressProxy: NJKWebViewProgress!
    
    private var clickLinkToOpenURL: Bool = false
    private var basicTitle: String!
    private var basicTabBarFrame: CGRect!
    private var currentURL: NSURL!
    
    private var webView: UIWebView!
    private var toolBar: UIToolbar!
    
    private var stopLoadingButton: UIBarButtonItem!
    private var reloadButton: UIBarButtonItem!
    private var backButton: UIBarButtonItem!
    private var forwardButton: UIBarButtonItem!
    
    private var homeButton: UIBarButtonItem!
    private var browserButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.basicTitle = self.title == nil ? (self.tabBarItem.title == nil ? "" : self.tabBarItem.title) : self.title
        
        //  原生态的toolbar不显示， 显示自定义的toolBar
        self.navigationController?.toolbarHidden = true
        
        self.setUpWebView()
        
        self.setUpToolBar()
        
        // 监控界面点击手势
        let singleTap = UITapGestureRecognizer(target: self, action: "singleTapAction")
        // 注意：不做如下处理，无法监控到单击手势
        singleTap.cancelsTouchesInView = false
        singleTap.delegate = self
        self.view.addGestureRecognizer(singleTap)
        
        self.basicTabBarFrame = self.tabBarController?.tabBar.frame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.showTabBar()
    }
    
    // MARK: - 监控界面点击手势
    func singleTapAction(){
        self.clickLinkToOpenURL = true
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - 初始化webView
    func setUpWebView(){
        let webFrame = self.getVisibleFrame()
        self.webView = UIWebView()
        self.webView.frame = webFrame
        self.webView.scalesPageToFit = true
        self.webView.backgroundColor = UIColor.whiteColor()
        self.webView.opaque = false
        self.webView.loadRequest(NSURLRequest(URL: NSURL(string: self.urlString)!))
        
        self.view.addSubview(self.webView)
        
        self.progressProxy = NJKWebViewProgress()
        self.webView.delegate = self.progressProxy
        self.progressProxy.webViewProxyDelegate = self
        self.progressProxy.progressDelegate = self
    }
    
    // MARK: - 初始化toolBar
    func setUpToolBar(){
        let toolBarFrame = CGRectMake(0, KM_FRAME_SCREEN_HEIGHT - KM_FRAME_VIEW_TOOLBAR_HEIGHT , KM_FRAME_SCREEN_WIDTH, KM_FRAME_VIEW_TOOLBAR_HEIGHT)
        self.toolBar = UIToolbar()
        toolBar.frame = toolBarFrame
        toolBar.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin
        toolBar.barStyle = UIBarStyle.Default
        toolBar.barTintColor = UIColor.whiteColor()
        toolBar.tintColor = KM_COLOR_TABBAR_NAVIGATION
        
        //到底部只能放到父视图去，否则无效，
        self.parentViewController?.view.addSubview(toolBar)
        
        homeButton = UIBarButtonItem(image: UIImage(named: "homePage"), style: UIBarButtonItemStyle.Plain, target: self, action: "gotoHomePage:")
        stopLoadingButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "stopLoading:")
        reloadButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "reload:")
        backButton = UIBarButtonItem(image: leftTriangleImage(), style: UIBarButtonItemStyle.Plain, target: self, action: "back:")
        forwardButton = UIBarButtonItem(image: rightTriangleImage(), style: UIBarButtonItemStyle.Plain, target: self, action: "forward:")
        browserButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "openBrowser:")
        
        backButton.enabled = false
        forwardButton.enabled = false
        
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let array = [homeButton, space, stopLoadingButton, space, backButton, space, forwardButton, space, browserButton]
        self.toolBar.setItems(array, animated: true)
    }
    
    func leftTriangleImage() -> UIImage!{
        struct SingleImage{
            static var imageInstance: UIImage?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&SingleImage.token, { () -> Void in
            let size = CGSizeMake(14.0, 16.0)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(0.0, 8.0))
            path.addLineToPoint(CGPointMake(14.0, 0.0))
            path.addLineToPoint(CGPointMake(14.0, 16.0))
            path.closePath()
            path.fill()
            
            SingleImage.imageInstance = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        })
        return SingleImage.imageInstance
    }
    
    func rightTriangleImage() -> UIImage!{
        struct SingleImage{
            static var imageInstance: UIImage?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&SingleImage.token, { () -> Void in
            let size = CGSizeMake(14.0, 16.0)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(0.0, 0.0))
            path.addLineToPoint(CGPointMake(14.0, 8.0))
            path.addLineToPoint(CGPointMake(0.0, 16.0))
            path.closePath()
            path.fill()
            
            SingleImage.imageInstance = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        })
        return SingleImage.imageInstance
    }
    
    // MARK: - webview delegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {        
        let basicURL = NSURL(string: self.urlString)
        let requestURL = request.URL
        let requestURLString = requestURL?.absoluteString
        
        if requestURL != nil && requestURL!.isEqual(basicURL){
            self.showTabBar()
        }else{
            if self.clickLinkToOpenURL == true{
                self.hideTabBar()
                self.clickLinkToOpenURL = false
            }
        }
        
        if requestURLString != nil && requestURLString!.hasPrefix("sms:"){
            UIApplication.sharedApplication().openURL(requestURL!)
            return false
        }
        
        if requestURLString != nil && ( requestURLString!.hasPrefix("http://www.youtube.com/v/") || requestURLString!.hasPrefix("http://itunes.apple.com/") || requestURLString!.hasPrefix("https://itunes.apple.com/") || requestURLString!.hasPrefix("http://phobos.apple.com/") ){
            UIApplication.sharedApplication().openURL(requestURL!)
            return false
        }
        
        let progressHUD = self.progressHUD
        if progressHUD!.alpha == 0.0 {
            progressHUD?.dimBackground = false
            progressHUD?.minShowTime = 1
            progressHUD!.mode = MBProgressHUDMode.DeterminateHorizontalBar
            progressHUD?.progress = 0
            progressHUD!.show(true)
        }
        
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        if self.title == nil || self.title!.isEmpty{
            self.title = self.basicTitle
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.toggleState()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.finishLoad()
        self.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        
        self.tabBarItem.title = self.basicTitle
        self.currentURL = self.webView.request?.URL
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        KMLog(error.localizedDescription)
        self.finishLoad()
    }
    
    // MARK: - toolBar  tabBar  hidden state
    func toggleState(){
        backButton.enabled = self.webView.canGoBack
        forwardButton.enabled = self.webView.canGoForward
        
        var newToolbarItems = NSMutableArray(array: self.toolBar.items!)
        let changeIndex = newToolbarItems.containsObject(reloadButton) ? newToolbarItems.indexOfObject(reloadButton) : newToolbarItems.indexOfObject(stopLoadingButton)
        
        if self.webView.loading{
            newToolbarItems[changeIndex] = self.stopLoadingButton
        }else {
            newToolbarItems[changeIndex] = self.reloadButton
        }
        
        self.toolBar.setItems(newToolbarItems as [AnyObject], animated: true)
    }
    
    func finishLoad(){
        self.toggleState()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func showTabBar(){
//        self.tabBarController?.tabBar.hidden = false
        
        var newFrame = self.basicTabBarFrame
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        self.tabBarController?.tabBar.frame = newFrame
        UIView.commitAnimations()
    }
    
    func hideTabBar(){
        var newFrame = self.basicTabBarFrame
        newFrame.origin.y += KM_FRAME_VIEW_TABBAR_HEIGHT
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        self.tabBarController?.tabBar.frame = newFrame
        UIView.commitAnimations()
        
//        self.tabBarController?.tabBar.hidden = true
    }
    
    // MARK: - toolBar button action
    func gotoHomePage(sender: UIBarButtonItem?){
        self.webView.loadRequest(NSURLRequest(URL: NSURL(string: self.urlString)!))
    }
    
    func stopLoading(sender: UIBarButtonItem?){
        self.webView.stopLoading()
    }
    
    func reload(sender: UIBarButtonItem?){
        self.webView.reload()
    }
    
    func back(sender: UIBarButtonItem?){
        self.webView.goBack()
    }
    
    func forward(sender: UIBarButtonItem?){
        self.webView.goForward()
    }
    
    func openBrowser(sender: UIBarButtonItem?){
        let actionSheet = UIActionSheet(title: nil, delegate: nil, cancelButtonTitle: i18n("Cancel"), destructiveButtonTitle: nil, otherButtonTitles: i18n("Open With Safari"), i18n("Copy link address") )
        actionSheet.showActionSheetWithCompleteBlock(self.view, completeActionSheetFunc: { (buttonIndex) -> Void in
            if buttonIndex == 1{
                UIApplication.sharedApplication().openURL(self.currentURL)
            }else if buttonIndex == 2{
                UIPasteboard.generalPasteboard().string = self.currentURL.absoluteString
            }
        })
        
    }
    
    // MARK: - NJKWebViewProgressDelegate
    func webViewProgress(webViewProgress: NJKWebViewProgress!, updateProgress progress: Float) {
        let progressHUD = self.progressHUD
        progressHUD?.progress = progress
        if progress == 1.0{
            self.hideProgressHUD(0.1)
        }
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
