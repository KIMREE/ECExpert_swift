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
    
    private var progressView: UIView!
    
    deinit{
        KMLog("NewsViewController deinit")
        toolBar.removeFromSuperview()
    }
    
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
        
        let activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.startAnimating()
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
        toolBar.tintColor = KM_COLOR_MAIN
        
        //到底部只能放到父视图去，否则无效，
        self.parentViewController?.view.addSubview(toolBar)
        
        homeButton = UIBarButtonItem(image: UIImage(named: "homePage"), style: UIBarButtonItemStyle.Plain, target: self, action: "gotoHomePage:")
        stopLoadingButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "stopLoading:")
        reloadButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "reload:")
        backButton = UIBarButtonItem(image: UIFactory.leftTriangleImage(14, height: 16, fillColor: UIColor.whiteColor()), style: UIBarButtonItemStyle.Plain, target: self, action: "back:")
        forwardButton = UIBarButtonItem(image: UIFactory.rightTriangleImage(14, height: 16, fillColor: UIColor.whiteColor()), style: UIBarButtonItemStyle.Plain, target: self, action: "forward:")
        browserButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "openBrowser:")
        
        backButton.enabled = false
        forwardButton.enabled = false
        
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let array = [homeButton, space, stopLoadingButton, space, backButton, space, forwardButton, space, browserButton]
        self.toolBar.setItems(array, animated: true)
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
        let progress = CGFloat(progress)
        var frame = getVisibleFrame()
        frame.size.height = 5
        let w = frame.size.width
        
        if progressView == nil{
            progressView = UIView(frame: frame)
            progressView.backgroundColor = UIColor.clearColor()
            let subView = UIView(frame: CGRectMake(0, 0, 0, frame.size.height))
            progressView.addSubview(subView)
        }
        
        let subView = progressView.subviews.last as! UIView
        if progress == 0{
            self.view.addSubview(progressView)
            subView.frame = CGRectMake(0, 0, 0, frame.size.height)
            subView.backgroundColor = UIColor.clearColor()
        }
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            subView.frame.size.width = w * progress
            
            var color = subView.backgroundColor
            if progress <= 0.3{
                color = RGB(152, 245, 255)
            }else if progress <= 0.6{
                color = RGB(230, 230, 250)
            }else if progress <= 0.9{
                color = RGB(135, 206, 250)
            }else{
                color = KM_COLOR_MAIN
            }
            subView.backgroundColor = color
            
            }) { (finished: Bool) -> Void in
                if progress == 1{
                    self.progressView.removeFromSuperview()
                }
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
