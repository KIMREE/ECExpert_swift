//
//  VoteViewController.swift
//  ECExpert
//
//  Created by Fran on 15/9/4.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class VoteViewController: BasicViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate , UIWebViewDelegate{
    
    let edge: CGFloat = 5
    
    private var videoUrlAnalysis: VideoUrlAnalysis! = VideoUrlAnalysis()
    
    private var collectionView: UICollectionView!

    var urlArray = ["http://m.v.qq.com/cover/u/u9pngb0cjjopv7t.html", "http://v.qq.com/boke/page/c/0/y/c01573fq7xy.html", "http://m.v.qq.com/page/c/x/y/c01573fq7xy.html?ptag=v.qq.com%23v.play.adaptor%232&mreferrer=http%3A%2F%2Fv.qq.com%2Fsearch.html%3Fpagetype%3D3%26stj2%3Dsearch.smartbox%26stag%3Dtxt.historyword%26ms_key%3D%25E9%25BB%2591%25E6%259A%2597%25E4%25B9%258B%25E9%25AD%2582", "http://v.qq.com/cover/p/plg5dilga1gfazq.html", "http://v.qq.com/cover/p/plg5dilga1gfazq/a0163u3xu21.html", "http://m.v.qq.com/cover/l/la633r8l0psxoqw.html?vid=i0017imywzf&ptag=v_qq_com%23v.play.adaptor%233", "http://v.youku.com/v_show/id_XMTMwMTQxNzMxMg==.html?from=s1.8-1-1.2", "http://v.youku.com/v_show/id_XNDI3MzIyMzc2.html?from=s1.8-1-1.2" ] + ["http://m.v.qq.com/cover/u/u9pngb0cjjopv7t.html", "http://v.qq.com/boke/page/c/0/y/c01573fq7xy.html", "http://m.v.qq.com/page/c/x/y/c01573fq7xy.html?ptag=v.qq.com%23v.play.adaptor%232&mreferrer=http%3A%2F%2Fv.qq.com%2Fsearch.html%3Fpagetype%3D3%26stj2%3Dsearch.smartbox%26stag%3Dtxt.historyword%26ms_key%3D%25E9%25BB%2591%25E6%259A%2597%25E4%25B9%258B%25E9%25AD%2582", "http://v.qq.com/cover/p/plg5dilga1gfazq.html", "http://v.qq.com/cover/p/plg5dilga1gfazq/a0163u3xu21.html", "http://m.v.qq.com/cover/l/la633r8l0psxoqw.html?vid=i0017imywzf&ptag=v_qq_com%23v.play.adaptor%233", "http://v.youku.com/v_show/id_XMTMwMTQxNzMxMg==.html?from=s1.8-1-1.2" ]
    
    private var videoInfoArray = NSMutableArray()
    
    private var webViewArray = NSMutableArray()
    
    deinit{
        videoUrlAnalysis = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
        KMLog("VoteViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.progressHUD != nil{
            let tapGesture = UITapGestureRecognizer(target: self, action: "hideProgressHUD")
            self.progressHUD?.addGestureRecognizer(tapGesture)
        }
        
        // Do any additional setup after loading the view.
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "goback"), style: UIBarButtonItemStyle.Plain, target: self, action: "goback")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enteredFullScreen", name: UIWindowDidBecomeVisibleNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "exitedFullScreen", name: UIWindowDidBecomeHiddenNotification, object: nil)
        
        self.navigationController!.edgesForExtendedLayout = UIRectEdge.None
        
        setUpView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func goback(){
        self.view.endEditing(true)
//        videoUrlAnalysis = nil
        self.navigationController!.dismissViewControllerAnimated(true, completion: { [weak self]() -> Void in
            if self != nil{
                
                // important 
                for web in self!.webViewArray{
                    (web as! UIWebView).delegate = nil
                }
            }
        })
    }
    
    func setUpView(){
        let layOut = UICollectionViewFlowLayout()
        layOut.scrollDirection = UICollectionViewScrollDirection.Vertical
        
        collectionView = UICollectionView(frame: getVisibleFrame(), collectionViewLayout: layOut)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.contentInset = UIEdgeInsetsMake(edge, edge, edge, edge)
        collectionView.userInteractionEnabled = true
        
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "VoteIdentifier")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.view.addSubview(collectionView)
        
        analysisUrl(urlArray)
    }
    
    // MARK: - 开始分析url
    func analysisUrl(urls: Array<String>){
        videoUrlAnalysis.startAnalysisUrl(urlArray, completeOne: { [weak self](vInfo: NSMutableDictionary) -> Void in
            if self != nil{
                self!.videoInfoArray.addObject(vInfo)
                let index = self?.videoInfoArray.indexOfObject(vInfo)
                
                self!.collectionView.insertItemsAtIndexPaths([NSIndexPath(forRow: index!, inSection: 0)])
            }
            }) { [weak self]() -> Void in
                if self != nil{
                    KMLog("complete all : \(self!.videoInfoArray.count)")
                    self!.collectionView.reloadData()
                }
        }
        
    }
    
    // MARK: - 投票
    func clickButtonAction(sender: AnyObject!){
        let voteButton = sender as! UIButton
        let cell = voteButton.superview?.superview as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        
        KMLog("\(indexPath!.row)")
    }
    
    // MARK: - 点击播放
    func clickWebViewAction(sender: AnyObject!){
        KMLog("clickWebViewAction")
        beginEnterFullScreen()
    }
    
    // MARK: - 屏幕变化
    func beginEnterFullScreen(){
        KMLog("beginEnterFullScreen")
        
        self.progressHUD?.labelText = "Loading..."
        self.progressHUD?.show(true)
    }
    
    func enteredFullScreen(){
        KMLog("enteredFullScreen")
        
        self.progressHUD?.hide(true)
    }
    
    func exitedFullScreen(){
        KMLog("exitedFullScreen : \(self.navigationController?.navigationBar.frame) ==  \(self.navigationController?.view.frame)")

        self.progressHUD?.hide(true)
        self.navigationController?.navigationBar.frame.origin.y = 0
        self.navigationController?.navigationBar.frame.size.height = 64
        self.navigationController?.view.frame = self.view.frame
    }
    
    // MARK: - UICollectionViewDelegate
    
    // MARK: - UICollectionViewDataSource
    func buildWebViewOnMainThread() -> UIWebView{
        let webView = UIWebView()
        webView.backgroundColor = UIColor.whiteColor()
        webView.userInteractionEnabled = true
        webView.scrollView.scrollEnabled = false
        
        webViewArray.addObject(webView)
        
        return webView
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoInfoArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VoteIdentifier", forIndexPath: indexPath)
        cell.userInteractionEnabled = true
        cell.contentView.userInteractionEnabled = true
        cell.backgroundColor = RGBA(red: 255, green: 255, blue: 255, alpha: 0.3)
        
        var playerView: UIWebView
        var titleLabel: UILabel
        var voteNumberLabel: UILabel
        var voteButton: UIButton
        if cell.contentView.subviews.count == 0{
            let cellBounds = cell.bounds
            
            // You can't access any UI code from a background thread. but current thread is main thread
            playerView = buildWebViewOnMainThread()
            playerView.frame = CGRectMake(0, 0, cellBounds.width, cellBounds.width)
            playerView.tag = 10
            playerView.delegate = self
            
            let tap = UITapGestureRecognizer(target: self, action: "clickWebViewAction:")
            tap.cancelsTouchesInView = false
            tap.delegate = self
            playerView.addGestureRecognizer(tap)
            
            titleLabel = UILabel(frame: CGRectMake(0, playerView.frame.origin.y + playerView.frame.size.height, cellBounds.width, 20 * 2))
            titleLabel.tag = 11
            titleLabel.numberOfLines = 2
            titleLabel.textAlignment = NSTextAlignment.Center
            titleLabel.font = UIFont.systemFontOfSize(14)
            
            voteNumberLabel = UILabel(frame: CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height, cellBounds.width, 20))
            voteNumberLabel.tag = 12
            voteNumberLabel.font = UIFont.systemFontOfSize(12)
            
            voteButton = UIButton(type: UIButtonType.Custom)
            voteButton.frame = CGRectMake(cellBounds.size.width - 15 - (20 - 15) / 2.0, cellBounds.size.height - 15 - (20 - 15) / 2.0, 15, 15)
            voteButton.backgroundColor = UIColor.redColor()
            voteButton.addTarget(self, action: "clickButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.contentView.addSubview(playerView)
            cell.contentView.addSubview(titleLabel)
            cell.contentView.addSubview(voteNumberLabel)
            cell.contentView.addSubview(voteButton)
        }
        
        playerView = cell.contentView.viewWithTag(10) as! UIWebView
        titleLabel = cell.contentView.viewWithTag(11) as! UILabel
        voteNumberLabel = cell.contentView.viewWithTag(12) as! UILabel
        
//        playerView.delegate = nil
        playerView.stopLoading()
        
        let data = videoInfoArray[indexPath.row] as! NSDictionary
        titleLabel.text = data.objectForKey("title") as? String
        let baseUrl = data.objectForKey("baseUrl") as! String!
        
        var htmlStr = ""
        if baseUrl != nil{
            if baseUrl.containsString(YouKuIdentifier){
                let vid = data.objectForKey("vid") as? String ?? ""
                if vid != ""{
                    htmlStr = NSString(format: YouKu_html, playerView.frame.size.width, playerView.frame.size.height, vid) as String
                }

            }else if baseUrl.containsString(TencentIdentifier){
                let thumbnail = data.objectForKey("thumbnail") as? String ?? ""
                let videoUrl = data.objectForKey("videoUrl") as? String ?? ""
                if videoUrl != ""{
                    htmlStr = NSString(format: Tencent_html, playerView.frame.size.width - 2 * webPadding, playerView.frame.size.height - 2 * webPadding, thumbnail, videoUrl) as String
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) { [weak self]() -> Void in
            if self != nil{
                if htmlStr != ""{
                    playerView.loadHTMLString(htmlStr, baseURL: NSURL(string: KimreeBaseUrl)!)
                }else{
                    playerView.loadRequest(NSURLRequest(URL: NSURL(string: baseUrl)!))
                }
            }
        }
        
        voteNumberLabel.text = "\t得票数:\(indexPath.row)"
        
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellWidth = (KM_FRAME_SCREEN_WIDTH - 3 * 2 * edge) / 2.0
        let cellHeight = cellWidth + 20*2 + 20
        return CGSizeMake(cellWidth, cellHeight)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(edge, edge, edge, edge)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - UIWebViewDelegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        // 优酷视频
        if request.URL != nil && (request.URL!.absoluteString.hasPrefix(YouKuPlayEnd) || request.URL!.absoluteString.hasPrefix(YouKuPlayerReady) || request.URL!.absoluteString.hasPrefix(YouKuPlayStart)) {
            if request.URL!.absoluteString.hasPrefix(YouKuPlayStart){
                self.beginEnterFullScreen()
            }
            return false
        }
        
        // 腾讯视频
        if request.URL != nil && (request.URL!.absoluteString.hasPrefix(TencentPlayerBeginFullScreen) || request.URL!.absoluteString.hasPrefix(TencentPlayerEndFullScreen) ){
            
            if request.URL!.absoluteString.hasPrefix(TencentPlayerBeginFullScreen){
                self.beginEnterFullScreen()
            }
            
            if request.URL!.absoluteString.hasPrefix(TencentPlayerEndFullScreen){
                self.enteredFullScreen()
            }
            
            return false
        }
        
        // 是根据 js 来获取 video 地址
        if request.URL != nil && request.URL!.absoluteString.hasPrefix(KimreeVideo){
            buildVideoInfoUseJsBackString(request.URL!.absoluteString, webView: webView)
            return false
        }
        
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        let requestUrl = webView.request?.URL?.absoluteString ?? ""
        if requestUrl != KimreeBaseUrl{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), { [weak self]() -> Void in
                if self != nil{
                    let jsStr = (try! NSString(contentsOfFile: NSBundle.mainBundle().pathForResource("GetVideo", ofType: "js")!, encoding: NSUTF8StringEncoding)) as String
                    webView.stringByEvaluatingJavaScriptFromString(jsStr)
                }
            })
            
        }else{
            let jsStr = (try! NSString(contentsOfFile: NSBundle.mainBundle().pathForResource("FullScreen", ofType: "js")!, encoding: NSUTF8StringEncoding)) as String
            webView.stringByEvaluatingJavaScriptFromString(jsStr)
        }

    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        KMLog("didFailLoadWithError : \(error!.localizedDescription)")
        
        self.progressHUD?.hide(true)
    }
    
    // MARK: - 根据 js 返回的 视频地址， 重新刷新界面对应的 webView
    func buildVideoInfoUseJsBackString(jsBackStr: String, webView: UIWebView){
        let videoUrl = jsBackStr.stringByReplacingOccurrencesOfString(KimreeVideo, withString: "")
        
        let cell = webView.superview?.superview as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        
        let row = indexPath?.row
        if row != nil && videoUrl != ""{
            webView.stopLoading()
            let vInfo = videoInfoArray[row!] as! NSMutableDictionary
            vInfo.setObject(videoUrl, forKey: "videoUrl")
            self.collectionView.reloadItemsAtIndexPaths([indexPath!])
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
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}
