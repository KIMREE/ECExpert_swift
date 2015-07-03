//
//  CustomerSettingViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/29.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class CustomerSettingViewController: BasicViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let CellIdentifier = "CellIdentifier"
    
    private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.needLogin = true
        self.title = i18n("Setting")
        
        setUpView()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: i18n("Logout"), style: UIBarButtonItemStyle.Plain, target: self.tabBarController, action: "logout")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTableView", name: APP_NOTIFICATION_CHANGE_LOGINUSERINFO, object: nil)
    }
    
    func reloadTableView(){
        if self.tableView != nil{
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView(){
        tableView = UITableView(frame: getVisibleFrame(), style: UITableViewStyle.Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = RGBA(0, 0, 0, 0.3)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        self.view.addSubview(tableView)
    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 160
        }
        return 50
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        if section == 0{
            let accountVC = AccountViewController()
            self.navigationController?.pushViewController(accountVC, animated: true)
            
        }else if section == 1{
            let heartTestVC =  HeartRateTestViewController()
            self.navigationController?.pushViewController(heartTestVC, animated: true)
        }else if section == 2{
            if row == 0{
                showAbout()
            }else if row == 1{
                let feedBack = FeedbackViewController()
                self.navigationController?.pushViewController(feedBack, animated: true)
            }else{
                clearCacche()
            }
        }else{
            if row == 1{
                UIApplication.sharedApplication().openURL(NSURL(string: APP_URL_ITUNES_COMMENT)!)
            }
        }
        
    }
    
    func showAbout(){
        let statusH: CGFloat = 20
        let bottomH: CGFloat = 60
        
        let aboutVC = UIViewController()
        aboutVC.view.backgroundColor = RGB(26,188,156)
        
        let label = UIFactory.labelWithFrame(CGRectMake(10, 80, KM_FRAME_SCREEN_WIDTH - 10 * 2, 30), text: "电子烟专家", textColor: UIColor.whiteColor(), fontSize: 26, numberOfLines: 0, textAlignment: NSTextAlignment.Center)
        
        let detailLabel = UIFactory.labelWithFrame(CGRectMake(10, 110, KM_FRAME_SCREEN_WIDTH - 10 * 2, 150), text: "       专注电子烟行业，是全球最大最全的电子烟门户APP。\n       为您提供电子烟行业最权威的新闻、品牌、政策、展会等最新资讯。", textColor: UIColor.whiteColor(), fontSize: 15, numberOfLines: 0, fontName: "Arial-BoldItalicMT")
        
        let emptyView = UIView(frame: CGRectMake(0, aboutVC.view.frame.size.height - bottomH, aboutVC.view.frame.size.width, bottomH))
        emptyView.backgroundColor = RGB(26,188,156)
        
        let backButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        backButton.frame = CGRectMake(10, 10, emptyView.frame.size.width - 10 * 2, bottomH - 10 * 2)
        backButton.setTitle(i18n("Back"), forState: UIControlState.Normal)
        backButton.backgroundColor = RGB(26,188,156)
        backButton.layer.masksToBounds = true
        backButton.layer.cornerRadius = 5
        backButton.layer.borderWidth = 2
        backButton.layer.borderColor = UIColor.whiteColor().CGColor
        backButton.addTarget(self, action: "aboutViewBack:", forControlEvents: UIControlEvents.TouchUpInside)
        
        emptyView.addSubview(backButton)
        
        aboutVC.view.addSubview(label)
        aboutVC.view.addSubview(detailLabel)
        aboutVC.view.addSubview(emptyView)
        
        self.navigationController?.presentViewController(aboutVC, animated: true, completion: { () -> Void in
            
        })
    }
    
    func aboutViewBack(sender: AnyObject!){
        self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    func clearCacche(){
        let alertView = UIAlertView(title: "", message: i18n("Confirm to clear the cache?"), delegate: nil, cancelButtonTitle: i18n("Cancel"), otherButtonTitles: i18n("Sure"))
        alertView.showAlertViewWithCompleteBlock {[unowned self] (buttonIndex) -> Void in
            if buttonIndex == 1{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {[unowned self] () -> Void in
                    let cachePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first as! String
                    let files = NSFileManager.defaultManager().subpathsAtPath(cachePath)
                    if files != nil{
                        for item in files!{
                            let path = cachePath.stringByAppendingPathComponent(item as! String)
                            if NSFileManager.defaultManager().fileExistsAtPath(path){
                                NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
                            }
                        }
                    }
                    LocalStroge.sharedInstance().deleteFile(APP_PATH_DEALER_INFO, searchPathDirectory: NSSearchPathDirectory.CachesDirectory)
                    
                    dispatch_sync(dispatch_get_main_queue(), {[unowned self] () -> Void in
                        self.progressHUD?.mode = MBProgressHUDMode.Text
                        self.progressHUD?.labelText = ""
                        self.progressHUD?.detailsLabelText = i18n("Clean up success!")
                        self.progressHUD?.show(true)
                        self.progressHUD?.hide(true, afterDelay: 2)
                        })
                    })
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            return 1
        }else if section == 2{
            return 3
        }else{
            return 2
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UIFactory.tableViewCellForTableView(tableView, cellIdentifier: CustomerSettingViewController.CellIdentifier, cellType: UITableViewCellStyle.Subtitle) { (tableViewCell: UITableViewCell!) -> Void in
            
            tableViewCell.backgroundColor = UIColor.clearColor()
            tableViewCell.textLabel?.textColor = UIColor.whiteColor()
            tableViewCell.detailTextLabel?.textColor = UIColor.whiteColor()
            tableViewCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }

        
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0{
            cell?.accessoryType = UITableViewCellAccessoryType.None
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
            
            let view = getUserInfoView(cell!, indexPath: indexPath)
            cell?.contentView.addSubview(view)
            
        }else if section == 1{
            cell?.textLabel?.text = i18n("Heart rate test")
            cell?.imageView?.image = UIImage(named: "heartRateTest")
        }else if section == 2{
            if row == 0 {
                cell?.textLabel?.text = i18n("About")
                cell?.imageView?.image = UIImage(named: "aboutUs")
            }else if row == 1{
                cell!.textLabel?.text = i18n("Your suggestion")
                cell?.imageView?.image = UIImage(named: "feedBack")
            }else {
                cell?.textLabel?.text = i18n("Clear the cache")
                cell?.imageView?.image = UIImage(named: "clearCache")
            }
        }else{
            if row == 0 {
                
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell?.selectionStyle = UITableViewCellSelectionStyle.None
                
                cell?.textLabel?.text = i18n("Current version")
                cell?.imageView?.image = UIImage(named: "versionNumber")
                
                let versionNum = bundleInfoDictionary()?["CFBundleShortVersionString"] as? String ?? ""
                cell?.detailTextLabel?.text = versionNum
            }else {
                cell?.textLabel?.text = i18n("Comment")
                cell?.imageView?.image = UIImage(named: "Comment")
            }
        }
        
        return cell!
    }
    
    private func getUserInfoView(cell: UITableViewCell, indexPath: NSIndexPath) -> UIView{
        let h = self.tableView(tableView, heightForRowAtIndexPath: indexPath)
        let frame = CGRectMake(0, 0, cell.frame.size.width, h)
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.clearColor()
        
        let backgroundImageView = UIImageView(frame: frame)
        backgroundImageView.image = UIImage(named: "accountBg")
        view.addSubview(backgroundImageView)
        
        
        let loginUserInfo = currentLoginUserInfo()
        let name = i18n("User Name")
        let userName = loginUserInfo!["customer_name"] as! String
        
        let nickName = i18n("Nickname")
        let userNickName = loginUserInfo!["customer_nickname"] as! String
        
        let phone = i18n("Phone")
        let userPhone = loginUserInfo!["customer_phone"] as! String
        
        let imageUrl = loginUserInfo!["customer_headimage"] as! String
        
        let imageW: CGFloat = 90
        let imageH: CGFloat = 90
        let padding: CGFloat = 20
        let imageFrame = CGRectMake(0 + padding, (h - imageH) / 2.0, imageW, imageH)
        let accountImageView = UIImageView(frame: imageFrame)
        accountImageView.layer.masksToBounds = true
        accountImageView.layer.cornerRadius = imageW / 2.0
        accountImageView.layer.borderWidth = 4
        accountImageView.layer.borderColor = RGBA(255, 255, 255, 0.9).CGColor
        accountImageView.contentMode = UIViewContentMode.ScaleAspectFit
        accountImageView.sd_setImageWithURL(NSURL(string: imageUrl), placeholderImage: UIImage(named: "accountHeader"))
        view.addSubview(accountImageView)
        
        
        let labelPadding: CGFloat = 5
        let labelH: CGFloat = 20
        let labelW: CGFloat = cell.frame.size.width - padding - imageW - labelPadding - padding
        let firstFrame = CGRectMake(0 + padding + imageW + labelPadding, (h - labelH * 3 - labelPadding * 2) / 2.0, labelW, labelH)
        let userLabel = UIFactory.labelWithFrame(firstFrame, text: "\(name):\(userName)", textColor: UIColor.whiteColor(), fontSize: 13, numberOfLines: 1, textAlignment: NSTextAlignment.Left)
        
        var secondFrame = firstFrame
        secondFrame.origin.y = secondFrame.origin.y + labelH + labelPadding
        let userNickNameLabel  = UIFactory.labelWithFrame(secondFrame, text: "\(nickName):\(userNickName)", textColor: UIColor.whiteColor(), fontSize: 13, numberOfLines: 1, textAlignment: NSTextAlignment.Left)
        
        var thirdFrame = secondFrame
        thirdFrame.origin.y = thirdFrame.origin.y + labelH + labelPadding
        let userPhoneLabel = UIFactory.labelWithFrame(thirdFrame, text: "\(phone):\(userPhone)", textColor: UIColor.whiteColor(), fontSize: 13, numberOfLines: 1, textAlignment: NSTextAlignment.Left)
        
        view.addSubview(userLabel)
        view.addSubview(userNickNameLabel)
        view.addSubview(userPhoneLabel)
        
        return view
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