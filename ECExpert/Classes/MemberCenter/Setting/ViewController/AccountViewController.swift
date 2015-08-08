//
//  AccountViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/29.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class AccountViewController: BasicViewController, UITableViewDataSource, UITableViewDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate,UIPickerViewDataSource{
    
    static let CellIdentifier = "CellIdentifier"
    
    private let manager = AFNetworkingFactory.networkingManager()
    
    private var birthDayPickView: UIView!
    private var datePick: UIDatePicker!
    
    private var sexPickView: UIView!
    private var sexPick: UIPickerView!
    private var selectSex: Int!
    
    private var firstCellView: UIView!
    private var photoView: UIImageView!
    private var nameLabel: UILabel!
    private var levelLabel: UILabel!
    
    private var tableView: UITableView!
    
    private let dateFormat = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.hidesBottomBarWhenPushed = true
        self.title = i18n("Account information")
        
        dateFormat.dateFormat = "yyyy-MM-dd"
        
        setUpView()
        
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
        var tableFrame = getVisibleFrame()
        
        tableView = UITableView(frame: tableFrame, style: UITableViewStyle.Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = RGBA(0, 0, 0, 0.3)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        self.view.addSubview(tableView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 界面不显示时，自动弹回生日和性别选择框
        if birthDayPickView != nil{
            popBirthdayPick()
        }
        
        if sexPickView != nil{
            popSexPick()
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 3
        }else if section == 1{
            return 5
        }else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UIFactory.tableViewCellForTableView(tableView, cellIdentifier: AccountViewController.CellIdentifier, cellType: UITableViewCellStyle.Value1) { (tableViewCell: UITableViewCell!) -> Void in
            tableViewCell!.backgroundColor = UIColor.clearColor()
            tableViewCell!.textLabel?.font = UIFont.systemFontOfSize(15)
            tableViewCell!.textLabel?.textColor = UIColor.whiteColor()
            tableViewCell!.detailTextLabel?.font = UIFont.systemFontOfSize(15)
            tableViewCell!.detailTextLabel?.textColor = UIColor.whiteColor()
            tableViewCell!.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        let loginUserInfo = currentLoginUserInfo()
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0{
            if row == 0{
                cell?.accessoryType = UITableViewCellAccessoryType.None
                if firstCellView == nil{
                    setUpFirstCellView()
                }
                let name = i18n("User Name")
                let userName = loginUserInfo!["customer_name"] as! String
                let Level = i18n("Level")
                let userLevel = loginUserInfo!["customer_degree"] as! String
                let imageUrl = loginUserInfo!["customer_headimage"] as! String
                
                nameLabel.text = "\(name):\(userName)"
                levelLabel.text = "\(Level):\(userLevel)"
                photoView.sd_setImageWithURL(NSURL(string: imageUrl), placeholderImage: UIImage(named: "accountHeader"))
                
                cell?.contentView.addSubview(firstCellView)
            }else if row == 1{
                cell?.textLabel?.text = i18n("Nickname")
                cell?.detailTextLabel?.text = (loginUserInfo!["customer_nickname"] as! String)
            }else{
                cell?.textLabel?.text = i18n("Signature")
                cell?.detailTextLabel?.text = (loginUserInfo!["customer_sign"] as! String)
            }
        }else if section == 1{
            if row == 0{
                cell?.textLabel?.text = i18n("Gender")
                let sex = (loginUserInfo!["customer_sex"] as! NSString).integerValue
                selectSex = sex
                var cunstomerSex = ""
                if sex == 0{
                    cunstomerSex = i18n("male")
                }else if sex == 1{
                    cunstomerSex = i18n("female")
                }
                cell?.detailTextLabel?.text = cunstomerSex
            }else if row == 1{
                cell?.textLabel?.text = i18n("Region")
                cell?.detailTextLabel?.text = (loginUserInfo!["customer_address"] as! String)
            }else if row == 2{
                cell?.textLabel?.text = i18n("Birthday")
                cell?.detailTextLabel?.text = (loginUserInfo!["customer_birth"] as! String)
            }else if row == 3{
                cell?.textLabel?.text = i18n("Email")
                cell?.detailTextLabel?.text = (loginUserInfo!["customer_email"] as! String)
            }else {
                cell?.textLabel?.text = i18n("Phone")
                cell?.detailTextLabel?.text = (loginUserInfo!["customer_phone"] as! String)
            }
        }else{
            if row == 0{
                cell?.textLabel?.text = i18n("Password")
            }
        }
        
        return cell!
    }
    
    
    func setUpFirstCellView(){
        let loginUserInfo = currentLoginUserInfo()
        let name = i18n("User Name")
        let userName = loginUserInfo!["customer_name"] as! String
        
        let Level = i18n("Level")
        let userLevel = loginUserInfo!["customer_degree"] as! String
        
        let imageUrl = loginUserInfo!["customer_headimage"] as! String
        
        let height = self.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        let width = self.view.frame.size.width
        let x: CGFloat = 0
        let y: CGFloat = 0
        
        firstCellView = UIView(frame: CGRectMake(x, y, width, height))
        firstCellView.backgroundColor = UIColor.clearColor()
        
        let headerH: CGFloat = 160
        let headerImageViewFrame = CGRectMake(x, y, width, headerH)
        let headerImageView = UIImageView(frame: headerImageViewFrame)
        headerImageView.image = UIImage(named: "accountBg")
        
        let photoW: CGFloat = 100
        let photoH: CGFloat = 100
        let padding: CGFloat = 20
        let photoFrame = CGRectMake(padding, headerH - photoH / 2.0, photoW, photoH)
        photoView = UIImageView(frame: photoFrame)
        photoView.layer.masksToBounds = true
        photoView.layer.cornerRadius = photoW / 2.0
        photoView.layer.borderWidth = 4
        photoView.layer.borderColor = RGBA(240, 240, 240, 0.8).CGColor
        photoView.sd_setImageWithURL(NSURL(string: imageUrl), placeholderImage: UIImage(named: "accountHeader"))
        
        tableView.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: "choosePhoto")
        photoView.addGestureRecognizer(tapGesture)
        
        let infoViewFrame = CGRectMake(x, y + headerH, width, height - headerH)
        let labelH: CGFloat = 20
        let labelPadding = (infoViewFrame.size.height - 2 * labelH) / 2.0
        let labelX = padding + photoW + labelPadding
        let labelW = width - labelX - labelPadding
        
        let nameLabelFrame = CGRectMake(labelX, infoViewFrame.origin.y + labelPadding, labelW, labelH)
        nameLabel = UIFactory.labelWithFrame(nameLabelFrame, text: "\(name):\(userName)", textColor: UIColor.whiteColor(), fontSize: 13, numberOfLines: 1)
        
        let levelLabelFrame = CGRectMake(labelX, nameLabelFrame.origin.y + labelH, labelW, labelH)
        levelLabel = UIFactory.labelWithFrame(levelLabelFrame, text: "\(Level):\(userLevel)", textColor: UIColor.whiteColor(), fontSize: 13, numberOfLines: 1)
        
        firstCellView.addSubview(headerImageView)
        firstCellView.addSubview(nameLabel)
        firstCellView.addSubview(levelLabel)
        firstCellView.addSubview(photoView)
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0{
            return 220
        }else{
            return 50
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let loginUserInfo = currentLoginUserInfo()
        let section = indexPath.section
        let row = indexPath.row
        if section == 0 && row == 0{
            choosePhoto()
        }else if section == 1 && row == 2{
            pushBirthdayPick()
        }else if section == 1 && row == 0{
            pushSexPick()
        }else{
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            var itemName = cell!.textLabel!.text!
            var itemValue = ""
            var itemKeyField = ""
            let nickName = loginUserInfo!["customer_nickname"] as! String
            
            if section == 0{
                if row == 1{
                    itemKeyField = "customer_nickname"
                }else if row == 2{
                    itemKeyField = "customer_sign"
                }
            }else if section == 1{
                if row == 1{
                    itemKeyField = "customer_address"
                }else if row == 3{
                    itemKeyField = "customer_email"
                }else if row == 4{
                    itemKeyField = "customer_phone"
                }
            }else{
                if row == 0{
                    itemKeyField = "customer_id"
                }
            }
            itemValue = loginUserInfo![itemKeyField] as! String
            let itemVC = ItemViewController(itemName: itemName, itemValue: itemValue, itemKeyField: itemKeyField, nickName: nickName)
            self.navigationController?.pushViewController(itemVC, animated: true)
        }
    }
    
    // MARK: - Action
    func choosePhoto(){
        var actionSheet: UIActionSheet!
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            actionSheet = UIActionSheet(title: i18n("change your icon"), delegate: nil, cancelButtonTitle: i18n("Cancel"), destructiveButtonTitle: nil, otherButtonTitles: i18n("take photo from library"),i18n("take photo from camera"))
        }else{
            actionSheet = UIActionSheet(title: i18n("change your icon"), delegate: nil, cancelButtonTitle: i18n("Cancel"), destructiveButtonTitle: nil, otherButtonTitles: i18n("take photo from library"))
        }
        actionSheet.showActionSheetWithCompleteBlock(self.view, completeActionSheetFunc: { (buttonIndex) -> Void in
            if buttonIndex != 0 {
                var sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                if buttonIndex == 2{
                    sourceType = UIImagePickerControllerSourceType.Camera
                }
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = true
                imagePicker.sourceType = sourceType
                
                self.navigationController?.presentViewController(imagePicker, animated: true, completion: { () -> Void in
                    
                })
            }
        })
    }
    
    func changeUserPhoto(image: UIImage){
        let imageData = UIImageJPEGRepresentation(image, 1)
        
        self.progressHUD?.mode = MBProgressHUDMode.Indeterminate
        self.progressHUD?.labelText = ""
        self.progressHUD?.detailsLabelText = ""
        self.progressHUD?.show(true)
        manager.POST(APP_URL_UPLOADUSERHEADER, parameters: nil, constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
            formData.appendPartWithFileData(imageData, name: "customer_headimage", fileName: "head.jpeg", mimeType: "image/jpeg")
            }, success: {(operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
                let dic = responseObj as? NSDictionary
                let code = dic?["code"] as? NSInteger
                if code != nil && code == 1{
                    self.progressHUD?.hide(true)
                    self.loadLoginUserInfo()
                    
                }else if code != nil && code == 0{
                    self.progressHUD?.mode = MBProgressHUDMode.Text
                    self.progressHUD?.detailsLabelText = dic!["data"] as! String
                    self.hideProgressHUD(2)
                }else{
                    KMLog("\(dic)")
                    self.hideProgressHUD()
                }
            }) {(operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                KMLog(error.localizedDescription)
                self.progressHUD?.mode = MBProgressHUDMode.Text
                self.progressHUD?.labelText = i18n("Failed to connect link to server!")
                self.progressHUD?.detailsLabelText = error.localizedDescription
                self.hideProgressHUD(2)
        }
    }
    
    // 获取登录用户信息
    func loadLoginUserInfo(){
        let params = NSMutableDictionary()
        params.setObject(currentLoginUserInfo()!["usertype"]!, forKey: "usertype")
        manager.POST(APP_URL_LOGIN_USERINFO, parameters: params, success: { (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            let basicDic = responseObj as? NSDictionary
            let code = basicDic?["code"] as? NSInteger
            if code != nil && code == 1{
                let resultInfo = basicDic!["data"] as! Dictionary<String, AnyObject>
                (UIApplication.sharedApplication().delegate as! AppDelegate).loginUserInfo = resultInfo
                LocalStroge.sharedInstance().addObject(resultInfo, fileName: APP_PATH_LOGINUSER_INFO, searchPathDirectory: NSSearchPathDirectory.DocumentDirectory)
                
                NSNotificationCenter.defaultCenter().postNotificationName(APP_NOTIFICATION_CHANGE_LOGINUSERINFO, object: nil)
                
            }
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                KMLog(error.localizedDescription)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var photo = info[UIImagePickerControllerEditedImage] as! UIImage
        photo = UIFactory.originImage(photo, scaleSize: CGSizeMake(180, 180))
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.changeUserPhoto(photo)
        })
    }
    
    // MARK: - birthdayPick
    private func setUpBirthDayPickView(){
        // There are only three valid heights for UIPickerView (162.0, 180.0 and 216.0)
        let buttonH: CGFloat = 50
        let pickH: CGFloat = 216
        let frame = CGRectMake(0, KM_FRAME_SCREEN_HEIGHT, KM_FRAME_SCREEN_WIDTH, buttonH + pickH + KM_FRAME_VIEW_TABBAR_HEIGHT)
        birthDayPickView = UIView(frame: frame)
        
        let width = frame.size.width
        let height = frame.size.height
        
        let buttonW: CGFloat = width / 2.0
        let cancelBtnFrame = CGRectMake(0, 0, buttonW, buttonH)
        let cancelBtn = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        cancelBtn.frame = cancelBtnFrame
        cancelBtn.backgroundColor = KM_COLOR_MAIN
        cancelBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        cancelBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        cancelBtn.setTitle(i18n("Cancel"), forState: UIControlState.Normal)
        cancelBtn.addTarget(self, action: "popBirthdayPick", forControlEvents: UIControlEvents.TouchUpInside)
        
        let saveBtnFrame = CGRectMake(0 + buttonW, 0, buttonW, buttonH)
        let saveBtn = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        saveBtn.frame = saveBtnFrame
        saveBtn.backgroundColor = KM_COLOR_MAIN
        saveBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        saveBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        saveBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        saveBtn.setTitle(i18n("Save"), forState: UIControlState.Normal)
        saveBtn.addTarget(self, action: "saveBirthday", forControlEvents: UIControlEvents.TouchUpInside)
        
        let datePickFrame = CGRectMake(0, 0 + buttonH, width, pickH)
        datePick = UIDatePicker()
        datePick.backgroundColor = RGB(236,240,243)
        datePick.datePickerMode = UIDatePickerMode.Date
        let currentDate = NSDate()
        let dateComponents = NSDateComponents()
        dateComponents.year = -18
        let selectDate = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: currentDate, options: NSCalendarOptions.allZeros)
        datePick.setDate(selectDate!, animated: true)
        datePick.maximumDate = currentDate
        datePick.frame = datePickFrame
                
        birthDayPickView.addSubview(cancelBtn)
        birthDayPickView.addSubview(saveBtn)
        birthDayPickView.addSubview(datePick)
        self.view.addSubview(birthDayPickView)
    }
    
    func pushBirthdayPick(){
        if birthDayPickView == nil{
            setUpBirthDayPickView()
        }
        
        if sexPickView != nil{
            popSexPick()
        }
        
        let birth = currentLoginUserInfo()!["customer_birth"] as! String
        if !birth.isEmpty{
            datePick.setDate(dateFormat.dateFromString(birth)!, animated: true)
        }
        
        var newFrame = birthDayPickView.frame
        newFrame.origin.y = KM_FRAME_SCREEN_HEIGHT - newFrame.size.height
        
        
        UIView.beginAnimations("pushBirthdayPick", context: nil)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        UIView.setAnimationDuration(0.3)
        birthDayPickView.frame = newFrame
        UIView.commitAnimations()
    }
    
    func popBirthdayPick(){
        var newFrame = birthDayPickView.frame
        newFrame.origin.y = KM_FRAME_SCREEN_HEIGHT
        
        UIView.beginAnimations("popBirthdayPick", context: nil)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        UIView.setAnimationDuration(0.3)
        birthDayPickView.frame = newFrame
        UIView.commitAnimations()
    }
    
    func saveBirthday(){
        let loginUserInfo = currentLoginUserInfo()
        let nickName = loginUserInfo!["customer_nickname"] as! String
        
        let birthDay = dateFormat.stringFromDate(datePick.date)
        
        let params = ["customer_nickname": nickName, "customer_birth": birthDay]
        manager.POST(APP_URL_EDITUSERINFO, parameters: params, success: { (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            let dic = responseObj as? NSDictionary
            let code = dic?["code"] as? NSInteger
            if code != nil && code! == 1{
                JDStatusBarNotification.showWithStatus(i18n("Successful modification!"), dismissAfter: 2)
                self.popBirthdayPick()
                self.loadLoginUserInfo()
            }else if code != nil && code! == 0{
                JDStatusBarNotification.showWithStatus(dic!["data"] as! String, dismissAfter: 2)
            }else{
                JDStatusBarNotification.showWithStatus(i18n("Unknown error!"), dismissAfter: 2)
            }
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            JDStatusBarNotification.showWithStatus(i18n("Failed to connect link to server!"), dismissAfter: 2)
        }
    }
    
    // MARK: - SexPick
    private func setUpSexPickView(){
        // There are only three valid heights for UIPickerView (162.0, 180.0 and 216.0)
        let pickH: CGFloat = 162
        let buttonH: CGFloat = 50
        
        let frame = CGRectMake(0, KM_FRAME_SCREEN_HEIGHT, KM_FRAME_SCREEN_WIDTH, pickH + buttonH + KM_FRAME_VIEW_TABBAR_HEIGHT)
        sexPickView = UIView(frame: frame)
        
        let width = frame.size.width
        let height = frame.size.height
        
        let buttonW: CGFloat = width / 2.0
        let cancelBtnFrame = CGRectMake(0, 0, buttonW, buttonH)
        let cancelBtn = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        cancelBtn.frame = cancelBtnFrame
        cancelBtn.backgroundColor = KM_COLOR_MAIN
        cancelBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        cancelBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        cancelBtn.setTitle(i18n("Cancel"), forState: UIControlState.Normal)
        cancelBtn.addTarget(self, action: "popSexPick", forControlEvents: UIControlEvents.TouchUpInside)
        
        let saveBtnFrame = CGRectMake(0 + buttonW, 0, buttonW, buttonH)
        let saveBtn = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        saveBtn.frame = saveBtnFrame
        saveBtn.backgroundColor = KM_COLOR_MAIN
        saveBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        saveBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        saveBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        saveBtn.setTitle(i18n("Save"), forState: UIControlState.Normal)
        saveBtn.addTarget(self, action: "saveSex", forControlEvents: UIControlEvents.TouchUpInside)
        
        let sexPickFrame = CGRectMake(0, 0 + buttonH, width, pickH)
        sexPick = UIPickerView()
        sexPick.backgroundColor = RGB(236,240,243)
        sexPick.delegate = self
        sexPick.dataSource = self
        sexPick.frame = sexPickFrame
        
        sexPickView.addSubview(cancelBtn)
        sexPickView.addSubview(saveBtn)
        sexPickView.addSubview(sexPick)
        self.view.addSubview(sexPickView)
    }
    
    func pushSexPick(){
        if sexPickView == nil{
            setUpSexPickView()
        }
        
        if birthDayPickView != nil{
            popBirthdayPick()
        }
        
        sexPick.selectRow(selectSex, inComponent: 0, animated: true)
        
        var newFrame = sexPickView.frame
        newFrame.origin.y = KM_FRAME_SCREEN_HEIGHT - newFrame.size.height
        
        UIView.beginAnimations("pushSexPick", context: nil)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        UIView.setAnimationDuration(0.3)
        sexPickView.frame = newFrame
        UIView.commitAnimations()
    }
    
    func popSexPick(){
        var newFrame = sexPickView.frame
        newFrame.origin.y = KM_FRAME_SCREEN_HEIGHT
        
        UIView.beginAnimations("popSexPick", context: nil)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        UIView.setAnimationDuration(0.3)
        sexPickView.frame = newFrame
        UIView.commitAnimations()
    }
    
    func saveSex(){
        let loginUserInfo = currentLoginUserInfo()
        let nickName = loginUserInfo!["customer_nickname"] as! String
        
        let params = ["customer_nickname": nickName, "customer_sex": selectSex]
        manager.POST(APP_URL_EDITUSERINFO, parameters: params, success: {(operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            let dic = responseObj as? NSDictionary
            let code = dic?["code"] as? NSInteger
            if code != nil && code! == 1{
                JDStatusBarNotification.showWithStatus(i18n("Successful modification!"), dismissAfter: 2)
                self.popSexPick()
                self.loadLoginUserInfo()
            }else if code != nil && code! == 0{
                JDStatusBarNotification.showWithStatus(dic!["data"] as! String, dismissAfter: 2)
            }else{
                JDStatusBarNotification.showWithStatus(i18n("Unknown error!"), dismissAfter: 2)
            }
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                JDStatusBarNotification.showWithStatus(i18n("Failed to connect link to server!"), dismissAfter: 2)
        }
    }
    // MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectSex = row
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if row == 0{
            return i18n("male")
        }else{
            return i18n("female")
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
