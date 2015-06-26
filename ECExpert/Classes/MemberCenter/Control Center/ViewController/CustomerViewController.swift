//
//  CustomerViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/24.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class CustomerViewController: BasicViewController {
    
    var vipCardView: UIView!
    var showProductsView: UIView!
    var nearbyStoreView: UIView!
    var feedbackView: UIView!
    var recordView: UIView!
    
    var userImageView: UIImageView!
    var userNameLabel: UILabel!
    var vipNumberLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 界面需要登录后才能显示
        self.needLogin = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self.tabBarController, action: "logout")
        
        setUpPageViews()
        setUpPageData()
        setUpTapGesture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - 构建界面
    func setUpPageViews(){
        let visibleFrame = getVisibleFrame()
        let x = visibleFrame.origin.x
        let y = visibleFrame.origin.y
        let w = visibleFrame.size.width
        let h = visibleFrame.size.height
        
        
        // headerView
        
        let headerView = UIView(frame: CGRectMake(x, y, w, h / 4.0))
        headerView.backgroundColor = RGBA(0, 0, 0, 0.5)
        
        let headerViewH = headerView.frame.size.height
        let imageW: CGFloat = 80
        let imageH: CGFloat = 80
        let tagLabelW: CGFloat = 70
        let tagLabelH: CGFloat = 15
        let tagLabelFontSize: CGFloat = 14
        let twoLabelDistance: CGFloat = 10
        
        let userImageViewFrame = CGRectMake(20, (headerViewH - imageH) / 2.0, imageW, imageH)
        userImageView = UIImageView(frame: userImageViewFrame)
        userImageView.image = UIImage(named: "accountHeader")
        userImageView.backgroundColor = UIColor.clearColor()
        userImageView.layer.masksToBounds = true
        userImageView.layer.borderWidth = 3
        userImageView.layer.borderColor = RGB(202, 201, 200).CGColor
        userImageView.layer.cornerRadius = imageW / 2.0
        
        let userTagLabel = UIFactory.labelWithFrame(CGRectMake(20 + imageW + 5, (headerViewH - twoLabelDistance) / 2.0 - tagLabelH , tagLabelW, tagLabelH), text: i18n("User") + ":", textColor: UIColor.whiteColor(), fontSize: tagLabelFontSize, numberOfLines: 1)
        userNameLabel = UIFactory.labelWithFrame(CGRectMake(userTagLabel.frame.origin.x + tagLabelW, userTagLabel.frame.origin.y , w - (userTagLabel.frame.origin.x + tagLabelW) - 5, tagLabelH), text: "", textColor: UIColor.whiteColor(), fontSize: tagLabelFontSize, numberOfLines: 1)
        
        let vipTagLabel = UIFactory.labelWithFrame(CGRectMake(20 + imageW + 5, (headerViewH - twoLabelDistance) / 2.0 + twoLabelDistance , tagLabelW, tagLabelH), text: i18n("VIP") + ":", textColor: UIColor.whiteColor(), fontSize: tagLabelFontSize, numberOfLines: 1)
        vipNumberLabel = UIFactory.labelWithFrame(CGRectMake(vipTagLabel.frame.origin.x + tagLabelW, vipTagLabel.frame.origin.y , w - (vipTagLabel.frame.origin.x + tagLabelW) - 5, tagLabelH), text: "", textColor: UIColor.whiteColor(), fontSize: tagLabelFontSize, numberOfLines: 0)
        
        headerView.addSubview(userImageView)
        headerView.addSubview(userTagLabel)
        headerView.addSubview(userNameLabel)
        headerView.addSubview(vipTagLabel)
        headerView.addSubview(vipNumberLabel)
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
        let cardHeight: CGFloat = contentView.frame.size.height / 3.0 - cardDistance
        let rowHeight: CGFloat = contentView.frame.size.height / 3.0
        let rowWidth: CGFloat = contentView.frame.size.width - 2 * cardDistance
        let sizeSmall: CGFloat = 1.0
        let sizeLarge: CGFloat = 1.2
        let clickViewTag = 11
        
        // rowNum = 0
        rowNum = 0
        let vipCardFrame = CGRectMake(cardDistance, rowNum * rowHeight + cardDistance / 2.0 , (rowWidth - cardDistance) * sizeLarge / (sizeLarge + sizeSmall) , cardHeight)
        let vipCard = UIFactory.magnetViewWithFrame(vipCardFrame, backgroundColor: RGB(241, 79, 89), imageName: "vipcard", title: i18n("Vip Card"), clickViewTag: clickViewTag)
        vipCardView = vipCard.viewWithTag(clickViewTag)
        
        let shopCardFrame = CGRectMake(vipCardFrame.origin.x + vipCardFrame.size.width + cardDistance,rowNum * rowHeight + cardDistance / 2.0, (rowWidth - cardDistance) * sizeSmall / (sizeSmall + sizeLarge), cardHeight)
        let shopCard = UIFactory.magnetViewWithFrame(shopCardFrame, backgroundColor: RGB(77, 167, 217), imageName: "products", title: i18n("Boutique"), clickViewTag: clickViewTag)
        showProductsView = shopCard.viewWithTag(clickViewTag)
        
        // rowNum = 1
        rowNum = 1
        let nearByCardFrame = CGRectMake(cardDistance, rowNum * rowHeight + cardDistance / 2.0, rowWidth, cardHeight)
        let nearByCard = UIFactory.magnetViewWithFrame(nearByCardFrame, backgroundColor: RGB(247, 191, 80), imageName: "shops", title: i18n("Experience"), clickViewTag: clickViewTag)
        nearbyStoreView = nearByCard.viewWithTag(clickViewTag)
        
        // rowNum = 2
        rowNum = 2
        let recordFrame = CGRectMake(cardDistance, rowNum * rowHeight + cardDistance / 2.0, (rowWidth - cardDistance) * sizeSmall / (sizeSmall + sizeLarge), cardHeight)
        let recordCard = UIFactory.magnetViewWithFrame(recordFrame, backgroundColor: RGB(131, 199, 92), imageName: "myrecord", title: i18n("Record"), clickViewTag: clickViewTag)
        recordView = recordCard.viewWithTag(clickViewTag)
        
        let feedBackFrame = CGRectMake(recordFrame.origin.x + recordFrame.size.width + cardDistance,rowNum * rowHeight + cardDistance / 2.0, (rowWidth - cardDistance) * sizeLarge / (sizeSmall + sizeLarge), cardHeight)
        let feedBackCard = UIFactory.magnetViewWithFrame(feedBackFrame, backgroundColor: RGB(239, 97, 66), imageName: "feedback", title: i18n("Feedback"), clickViewTag: clickViewTag)
        feedbackView = feedBackCard.viewWithTag(clickViewTag)
        
        contentView.addSubview(vipCard)
        contentView.addSubview(shopCard)
        contentView.addSubview(nearByCard)
        contentView.addSubview(recordCard)
        contentView.addSubview(feedBackCard)
    }
    
    // 加载界面数据
    func setUpPageData(){
        let loginUserInfo = currentAppDelegate().loginUserInfo
        var userName = loginUserInfo!["customer_nickname"] as? NSString
        if userName?.length == 0{
            userName = loginUserInfo!["customer_name"] as? NSString
        }
        userNameLabel.text = userName as? String
        
        var vipNo = loginUserInfo!["customer_vip"] as? String
        vipNumberLabel.text = vipNo
        
        var headerImageName = loginUserInfo!["customer_headimage"] as? String
        if headerImageName == nil || headerImageName!.isEmpty{
            userImageView.image = UIImage(named: "accountHeader")
        }else{
            userImageView.sd_setImageWithURL(NSURL(string: headerImageName!))
        }
        
    }
    
    func setUpTapGesture(){
        let cardTapGesture = UITapGestureRecognizer(target: self, action: "vipCardTapAction")
        vipCardView.addGestureRecognizer(cardTapGesture)
        
        let showProductsTapGesture = UITapGestureRecognizer(target: self, action: "showProductsTapAction")
        showProductsView.addGestureRecognizer(showProductsTapGesture)
        
        let nearByStoreTapGesture = UITapGestureRecognizer(target: self, action: "nearbyStoreTapAction")
        nearbyStoreView.addGestureRecognizer(nearByStoreTapGesture)
        
        let recordTapGesture = UITapGestureRecognizer(target: self, action: "recordTapAction")
        recordView.addGestureRecognizer(recordTapGesture)
        
        let feedbackTapGesture = UITapGestureRecognizer(target: self, action: "feedbackTapAction")
        feedbackView.addGestureRecognizer(feedbackTapGesture)
    }
    
    func vipCardTapAction(){
        let loginUserInfo = currentAppDelegate().loginUserInfo
        let customerId = loginUserInfo!["customer_id"] as? String
        let customerVip = loginUserInfo!["customer_vip"] as? String
        
        let qrcode = "{\"customer_id\":\(customerId!),\"customer_vip\":\(customerVip!)}"
        let showQRCode = ShowQRCodeViewController()
        showQRCode.qrcodeString = qrcode
        showQRCode.title = i18n("Show Vip Card")
        self.navigationController?.pushViewController(showQRCode, animated: true)
    }
    
    func showProductsTapAction(){
        let webVC = NewsViewController()
        webVC.urlString = APP_URL_KIMREE
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    func nearbyStoreTapAction(){
        self.tabBarController?.selectedIndex = 1
    }
    
    func recordTapAction(){
        let tradeRecordVC = TradeRecordViewController(tradeRecordType: TradeRecordType.Customer)
        self.navigationController?.pushViewController(tradeRecordVC, animated: true)
    }
    
    func feedbackTapAction(){
        let feedbackVC = FeedbackViewController()
        self.navigationController?.pushViewController(feedbackVC, animated: true)
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
