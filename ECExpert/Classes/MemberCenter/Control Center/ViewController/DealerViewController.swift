//
//  DealerViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/24.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class DealerViewController: BasicViewController {
    
    var tradeView: UIView!
    var sellRecordView: UIView!
    
    var dealerImageView: UIImageView!
    var dealerNameLabel: UILabel!
    var dealerEmailOrPhoneLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.needLogin = true
        
        setUpView()
        setUpViewData()
        setUpViewTapGesture()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "setting"), style: UIBarButtonItemStyle.Plain, target: self, action: "settingAction")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setUpPageData", name: APP_NOTIFICATION_CHANGE_LOGINUSERINFO, object: nil)
    }
    
    func settingAction(){
        let settingVC = DealerSettingViewController()
        self.navigationController?.pushViewController(settingVC, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView(){
        let visibleFrame = getVisibleFrame()
        let x = visibleFrame.origin.x
        let y = visibleFrame.origin.y
        let w = visibleFrame.size.width
        let h = visibleFrame.size.height
        
        let headerViewH = h / 3.0
        let headerView = UIView(frame: CGRectMake(x, y, w, headerViewH))
        headerView.backgroundColor = RGBA(0, 0, 0, 0.1)
        
        let imageW: CGFloat = 100
        let imageH: CGFloat = 100
        let twoLabelDistance: CGFloat = 20
        let labelHeight: CGFloat = 21
        let headerPadding: CGFloat = 20
        dealerImageView = UIImageView(frame: CGRectMake(headerPadding, (headerViewH - imageH) / 2.0, imageW, imageH))
        dealerImageView.backgroundColor = UIColor.clearColor()
        dealerImageView.layer.masksToBounds = true
        dealerImageView.layer.borderWidth = 3
        dealerImageView.layer.borderColor = RGB(202, 201, 200).CGColor
        dealerImageView.layer.cornerRadius = imageW / 2.0
        
        
        let nameLabelFrame = CGRectMake(headerPadding + imageW + headerPadding / 2.0, (headerViewH - 2 * labelHeight - twoLabelDistance) / 2.0, w - (headerPadding + imageW + headerPadding / 2.0) - headerPadding, labelHeight)
        dealerNameLabel = UIFactory.labelWithFrame(nameLabelFrame, text: "111", textColor: UIColor.whiteColor(), fontSize: 17, numberOfLines: 1, textAlignment: NSTextAlignment.Left)
        
        
        let phoneEmailLabelFrame = CGRectMake(headerPadding + imageW + headerPadding / 2.0, nameLabelFrame.origin.y + labelHeight + twoLabelDistance, w - (headerPadding + imageW + headerPadding / 2.0) - headerPadding, labelHeight)
        dealerEmailOrPhoneLabel = UIFactory.labelWithFrame(phoneEmailLabelFrame, text: "222@qq.com", textColor: UIColor.whiteColor(), fontSize: 17, numberOfLines: 2, textAlignment: NSTextAlignment.Left)
        
        headerView.addSubview(dealerImageView)
        headerView.addSubview(dealerNameLabel)
        headerView.addSubview(dealerEmailOrPhoneLabel)
        self.view.addSubview(headerView)
        
        
        // scrollView
        let scrollViewFrame = CGRectMake(x, y + headerViewH, w, h - headerViewH)
        let scrollView = ControlCenterScrollView(frame: scrollViewFrame)
        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.contentSize = CGSizeMake(scrollViewFrame.size.width + 0.5, scrollViewFrame.size.height + 0.5)
        scrollView.scrollEnabled = true
        scrollView.userInteractionEnabled = true
        
        let contentView = UIView(frame: CGRectMake(0, 0, scrollViewFrame.size.width, scrollViewFrame.size.height))
        contentView.backgroundColor = UIColor.clearColor()
        scrollView.addSubview(contentView)
        self.view.addSubview(scrollView)
        
        // magent
        var rowNum: CGFloat = 0
        let cardDistance: CGFloat = 10
        let cardHeight: CGFloat = contentView.frame.size.height / 2.0 - cardDistance
        let rowHeight: CGFloat = contentView.frame.size.height / 2.0
        let rowWidth: CGFloat = contentView.frame.size.width - 2 * cardDistance
        let sizeSmall: CGFloat = 1.0
        let sizeLarge: CGFloat = 1.2
        let clickViewTag = 11
        
        rowNum = 0
        let tradeCardFrame = CGRectMake(cardDistance, rowNum * rowHeight + cardDistance / 2.0, rowWidth, cardHeight)
        let tradeCard = UIFactory.magnetViewWithFrame(tradeCardFrame, backgroundColor: RGB(59, 88, 158), imageName:"trade" , title: i18n("Trading"), clickViewTag: clickViewTag, clickViewWidth: 150)
        tradeView = tradeCard.viewWithTag(clickViewTag)
        
        rowNum = 1
        let recordCardFrame = CGRectMake(cardDistance, rowNum * rowHeight + cardDistance / 2.0, rowWidth, cardHeight)
        let recordCard = UIFactory.magnetViewWithFrame(recordCardFrame, backgroundColor: RGB(39, 178, 233), imageName:"traderecord" , title: i18n("Trading Record"), clickViewTag: clickViewTag, clickViewWidth: 150)
        sellRecordView = recordCard.viewWithTag(clickViewTag)
        
        contentView.addSubview(tradeCard)
        contentView.addSubview(recordCard)
    }
    
    
    func setUpViewData(){
        let loginUserInfo = currentAppDelegate().loginUserInfo
        let dealerName = loginUserInfo!["dealer_name"] as? String
        var dealerPhoneOrEmail = loginUserInfo!["dealer_telephone"] as? String
        if dealerPhoneOrEmail == nil || dealerPhoneOrEmail!.isEmpty{
            dealerPhoneOrEmail = loginUserInfo!["dealer_phone"] as? String
        }
        if dealerPhoneOrEmail == nil || dealerPhoneOrEmail!.isEmpty{
            dealerPhoneOrEmail = loginUserInfo!["dealer_email"] as? String
        }
        
        dealerNameLabel.text = dealerName
        dealerEmailOrPhoneLabel.text = dealerPhoneOrEmail
        
        var headerImageName = loginUserInfo!["customer_headimage"] as? String
        if headerImageName == nil || headerImageName!.isEmpty{
            dealerImageView.image = UIImage(named: "accountHeader")
        }else{
            dealerImageView.sd_setImageWithURL(NSURL(string: headerImageName!))
        }
    }
    
    func setUpViewTapGesture(){
        let tradeTapGesture = UITapGestureRecognizer(target: self, action: "tradeInputAction")
        tradeView.addGestureRecognizer(tradeTapGesture)
        
        let recordTapGesture = UITapGestureRecognizer(target: self, action: "tradeRecordAction")
        sellRecordView.addGestureRecognizer(recordTapGesture)
    }
    
    func tradeInputAction(){
//        let scanVC = ScanViewController(scanType: ScanType.All) { (scanViewControlelr, scanResult) -> Void in
//            scanViewControlelr.goback()
//            KMLog(scanResult)
//        }
//        self.navigationController?.pushViewController(scanVC, animated: true)
        
        let tradeInputVC = TradeInputViewController()
        self.navigationController?.pushViewController(tradeInputVC, animated: true)
    }
    
    func tradeRecordAction(){
        let tradeRecordVC = TradeRecordViewController(tradeRecordType: TradeRecordType.Dealer)
        self.navigationController?.pushViewController(tradeRecordVC, animated: true)
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
