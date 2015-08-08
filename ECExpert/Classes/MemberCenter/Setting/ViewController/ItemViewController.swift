//
//  ItemViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/30.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class ItemViewController: BasicViewController {
    
    var itemName: String
    var itemValue: String
    var itemKeyField: String
    var nickName: String
    
    private var modifyField: UITextField!
    
    private var oldPasswordField: UITextField!
    private var newPasswordField: UITextField!
    private var rePasswordField: UITextField!
    
    private let manager = AFNetworkingFactory.networkingManager()

    init(itemName: String, itemValue: String, itemKeyField: String, nickName: String){
        self.itemName = itemName
        self.itemValue = itemValue
        self.itemKeyField = itemKeyField
        self.nickName = nickName
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.needLogin = true
        self.title = itemName
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "modify")
        
        let scrollView = TPKeyboardAvoidingScrollView(frame: getVisibleFrame())
        scrollView.backgroundColor = UIColor.clearColor()
        
        let padding: CGFloat = 20
        let x: CGFloat = padding
        let w: CGFloat = KM_FRAME_SCREEN_WIDTH - 2 * padding
        let h: CGFloat = 40
        let firstFrame = CGRectMake(x, padding, w, h)
        modifyField = UITextField(frame: firstFrame)
        modifyField.borderStyle = UITextBorderStyle.RoundedRect
        modifyField.text = itemValue
        
        oldPasswordField = UITextField(frame: firstFrame)
        oldPasswordField.secureTextEntry = true
        oldPasswordField.borderStyle = UITextBorderStyle.RoundedRect
        oldPasswordField.placeholder = i18n("OLD PASSWORD")
        
        let secondFrame = CGRectMake(x, padding * 2 + h, w, h)
        newPasswordField = UITextField(frame: secondFrame)
        newPasswordField.secureTextEntry = true
        newPasswordField.borderStyle = UITextBorderStyle.RoundedRect
        newPasswordField.placeholder = i18n("NEW PASSWORD")
        
        let thirdFrame = CGRectMake(x, padding * 3 + h * 2, w, h)
        rePasswordField = UITextField(frame: thirdFrame)
        rePasswordField.secureTextEntry = true
        rePasswordField.borderStyle = UITextBorderStyle.RoundedRect
        rePasswordField.placeholder = i18n("NEW PASSWORD")
        
        if itemName != i18n("Password"){
            scrollView.addSubview(modifyField)
        }else{
            scrollView.addSubview(oldPasswordField)
            scrollView.addSubview(newPasswordField)
            scrollView.addSubview(rePasswordField)
        }
        self.view.addSubview(scrollView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func modify(){
        let params = NSMutableDictionary()
        var url = APP_URL_EDITUSERINFO
        params.setObject(nickName, forKey: "customer_nickname")
        if itemName != i18n("Password"){
            params.setObject(modifyField.text, forKey: itemKeyField)
        }else{
            url = APP_URL_CHANGEPASSWORD
            let pw = oldPasswordField.text
            let npw1 = newPasswordField.text
            let npw2 = rePasswordField.text
            
            if count(pw) < 5 || count(npw1) < 5{
                let alertView = UIAlertView(title: nil, message: i18n("Password lengh must be greater than or equal to 5 numbers including letters!"), delegate: nil, cancelButtonTitle: i18n("Sure"))
                alertView.show()
                return
            }
            
            if npw1 != npw2{
                let alertView = UIAlertView(title: nil, message: i18n("The two input password does not match!"), delegate: nil, cancelButtonTitle: i18n("Sure"))
                alertView.show()
                return
            }
            
            params.setObject(pw, forKey: "oldpassword")
            params.setObject(npw1, forKey: "newpassword")
        }
        
        manager.POST(url, parameters: params, success: {(operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            let dic = responseObj as? NSDictionary
            let code = dic?["code"] as? NSInteger
            if code != nil && code! == 1{
                JDStatusBarNotification.showWithStatus(i18n("Successful modification!"), dismissAfter: 2)
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
    
    // 获取登录用户信息
    func loadLoginUserInfo(){
        let params = NSMutableDictionary()
        params.setObject(currentLoginUserInfo()!["usertype"]!, forKey: "usertype")
        manager.POST(APP_URL_LOGIN_USERINFO, parameters: params, success: {(operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            let basicDic = responseObj as? NSDictionary
            let code = basicDic?["code"] as? NSInteger
            if code != nil && code == 1{
                let resultInfo = basicDic!["data"] as! Dictionary<String, AnyObject>
                (UIApplication.sharedApplication().delegate as! AppDelegate).loginUserInfo = resultInfo
                LocalStroge.sharedInstance().addObject(resultInfo, fileName: APP_PATH_LOGINUSER_INFO, searchPathDirectory: NSSearchPathDirectory.DocumentDirectory)
                
                NSNotificationCenter.defaultCenter().postNotificationName(APP_NOTIFICATION_CHANGE_LOGINUSERINFO, object: nil)
                self.goback()
                
            }
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                KMLog(error.localizedDescription)
                JDStatusBarNotification.showWithStatus(error.localizedDescription, dismissAfter: 2)
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
