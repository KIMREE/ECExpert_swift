//
//  RegisterViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/23.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit
import Crashlytics

class RegisterViewController: BasicViewController {
    
    private var containerView: UIView!
    
    // 用户类型，  0 普通用户   1 销售商
    private var segmented: UISegmentedControl!
    
    private var accountField: UITextField!
    private var passwordField: UITextField!
    private var rePasswordField: UITextField!
    
    private var agreeButton: UIButton!
    private var agreeImageView: UIImageView!
    private var agreeImage: UIImage!
    private var disagreeImage: UIImage!
    
    private var useAgreementButton: UIButton!
    
    private var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = i18n("Register")
        
        setUpContainerView()
        
        RAC(self.submitButton, "enabled").assignSignal(RACSignal.combineLatest([accountField.rac_textSignal(), passwordField.rac_textSignal(), rePasswordField.rac_textSignal()]).map({ (tuple: AnyObject!) -> AnyObject! in
            let tuple   = tuple as! RACTuple
            let account = tuple.first as! String
            let pwd     = tuple.second as! String
            let rePwd   = tuple.third as! String
            
            var result = true
            if count(account) < 5 || count(pwd) < 5 || count(rePwd) < 5 || (pwd != rePwd){
                result = false
            }
            return result
        }))

        // TODO: 主动引起崩溃，测试Fabric
//         Crashlytics.sharedInstance().crash()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpContainerView(){
        let scrollView = TPKeyboardAvoidingScrollView(frame: getVisibleFrame())
        self.view.addSubview(scrollView)
        
        let visibleFrame = getVisibleFrame()
        
        let h1: CGFloat = 50
        let h2: CGFloat = 50
        let h3: CGFloat = 50
        let h4: CGFloat = 50
        let h5: CGFloat = 50
        let h6: CGFloat = 50
        let h: CGFloat = h1 + h2 + h3 + h4 + h5 + h6
        let padding: CGFloat = 20
        let w = visibleFrame.size.width - 2 * padding
        let y: CGFloat = (visibleFrame.size.height - h) / 2.0
        let x = visibleFrame.origin.x + padding
        
        containerView = UIView(frame: CGRectMake(x, y, w, h))
        scrollView.addSubview(containerView)
        containerView.backgroundColor = RGBA(0, 0, 0, 0.3)
        
        var startH: CGFloat = 0
        let segmentedX: CGFloat = 0
        let segmentedY: CGFloat = 0
        let segmentedW: CGFloat = w
        let segmentedH: CGFloat = h1
        segmented = UISegmentedControl(frame: CGRectMake(segmentedX, segmentedY, segmentedW, segmentedH))
        segmented.insertSegmentWithTitle(i18n("Customer Register"), atIndex: 0, animated: true)
        segmented.insertSegmentWithTitle(i18n("Dealer Register"), atIndex: 1, animated: true)
        segmented.tintColor = RGB(163, 134, 130)
        
        segmented.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Selected)
        segmented.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Disabled)
        segmented.selectedSegmentIndex = 0
        segmented.setEnabled(false, forSegmentAtIndex: 1)
        segmented.layer.borderColor = segmented.tintColor.CGColor
        segmented.layer.cornerRadius = 0.0
        segmented.layer.borderWidth = 1.5
        containerView.addSubview(segmented)
        
        
        let leftRightPadding = padding / 2.0
        startH += h1
        let accountW: CGFloat = 30
        let accountH: CGFloat = 30
        let accountX = leftRightPadding
        let accountY = startH + (h2 - accountH) / 2.0
        let accountImageView = UIImageView(frame: CGRectMake(accountX, accountY, accountW, accountH))
        accountImageView.image = UIImage(named: "account")
        
        accountField = UITextField(frame: CGRectMake(accountX + accountW + leftRightPadding, accountY, w - (accountX + accountW + leftRightPadding + leftRightPadding), accountH))
        accountField.textAlignment = NSTextAlignment.Left
        accountField.attributedPlaceholder = NSAttributedString(string: i18n("Account"), attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        accountField.textColor = UIColor.whiteColor()
        accountField.font = UIFont.systemFontOfSize(18)
        accountField.clearButtonMode = UITextFieldViewMode.WhileEditing
        
        let accountLine = UIView(frame: CGRectMake(accountX, accountY + accountH + 1, w - leftRightPadding - leftRightPadding, 1))
        accountLine.backgroundColor = UIColor.whiteColor()
        
        containerView.addSubview(accountImageView)
        containerView.addSubview(accountField)
        containerView.addSubview(accountLine)
        
        
        startH += h2
        let passwordW: CGFloat = 30
        let passwordH: CGFloat = 30
        let passwordX = leftRightPadding
        let passwordY = startH + (h3 - passwordH) / 2.0
        let passwordImageView = UIImageView(frame: CGRectMake(passwordX, passwordY, passwordW, passwordH))
        passwordImageView.image = UIImage(named: "password")
        
        passwordField = UITextField(frame: CGRectMake(passwordX + passwordW + leftRightPadding, passwordY, w - (passwordX + passwordW + leftRightPadding + leftRightPadding), passwordH))
        passwordField.secureTextEntry = true
        passwordField.textAlignment = NSTextAlignment.Left
        passwordField.attributedPlaceholder = NSAttributedString(string: i18n("Password"), attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordField.textColor = UIColor.whiteColor()
        passwordField.font = UIFont.systemFontOfSize(18)
        passwordField.clearButtonMode = UITextFieldViewMode.WhileEditing
        
        let passwordLine = UIView(frame: CGRectMake(passwordX, passwordY + passwordH + 1, w - leftRightPadding - leftRightPadding, 1))
        passwordLine.backgroundColor = UIColor.whiteColor()
        
        containerView.addSubview(passwordImageView)
        containerView.addSubview(passwordField)
        containerView.addSubview(passwordLine)
        
        
        startH += h3
        let rePasswordW: CGFloat = 30
        let rePasswordH: CGFloat = 30
        let rePasswordX = leftRightPadding
        let rePasswordY = startH + (h4 - rePasswordH) / 2.0
        let rePasswordImageView = UIImageView(frame: CGRectMake(rePasswordX, rePasswordY, rePasswordW, rePasswordH))
        rePasswordImageView.image = UIImage(named: "password")
        
        rePasswordField = UITextField(frame: CGRectMake(rePasswordX + rePasswordW + leftRightPadding, rePasswordY, w - (rePasswordX + rePasswordW + leftRightPadding + leftRightPadding), rePasswordH))
        rePasswordField.secureTextEntry = true
        rePasswordField.textAlignment = NSTextAlignment.Left
        rePasswordField.attributedPlaceholder = NSAttributedString(string: i18n("Confirm your password"), attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        rePasswordField.textColor = UIColor.whiteColor()
        rePasswordField.font = UIFont.systemFontOfSize(18)
        rePasswordField.clearButtonMode = UITextFieldViewMode.WhileEditing
        
        let rePasswordLine = UIView(frame: CGRectMake(rePasswordX, rePasswordY + rePasswordH + 1, w - leftRightPadding - leftRightPadding, 1))
        rePasswordLine.backgroundColor = UIColor.whiteColor()
        
        containerView.addSubview(rePasswordImageView)
        containerView.addSubview(rePasswordField)
        containerView.addSubview(rePasswordLine)
        
        
        startH += h4
        let agreeW: CGFloat = 20
        let agreeH: CGFloat = 20
        let agreeX = leftRightPadding
        let agreeY = startH + (h5 - agreeH) / 2.0
        agreeImageView = UIImageView(frame: CGRectMake(0, 0, agreeW, agreeH))
        
        let agreeLabel = UIFactory.labelWithFrame(CGRectZero, text: i18n("Read and Agree"), textColor: UIColor.whiteColor(), fontSize: 14, numberOfLines: 1)
        let agreeSize = agreeLabel.sizeThatFits(CGSizeZero)
        agreeLabel.frame = CGRectMake(agreeW, 0, agreeSize.width, agreeH)
        
        agreeButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        agreeButton.frame = CGRectMake(agreeX, agreeY, agreeW + agreeSize.width, agreeH)
        
        agreeButton.addSubview(agreeImageView)
        agreeButton.addSubview(agreeLabel)
        containerView.addSubview(agreeButton)
        
        let agreementLabel = UIFactory.labelWithFrame(CGRectZero, text: i18n("Agreement"), textColor: UIColor.whiteColor(), fontSize: 14, numberOfLines: 1)
        let agreementSize = agreementLabel.sizeThatFits(CGSizeZero)
        agreementLabel.frame = CGRectMake(0, 0, agreementSize.width, agreeH)
        
        useAgreementButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        useAgreementButton.frame = CGRectMake( w - leftRightPadding - agreementSize.width, agreeY, agreementSize.width, agreeH)
        
        useAgreementButton.addSubview(agreementLabel)
        containerView.addSubview(useAgreementButton)
        
        
        startH += h5
        let submitH = h6
        let submitX: CGFloat = 0
        let submitY = startH + (h6 - submitH) / 2.0
        let submitW = w - 2 * submitX
        submitButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        submitButton.frame = CGRectMake(submitX, submitY, submitW, submitH)
        submitButton.setTitle(i18n("Register"), forState: UIControlState.Normal)
        submitButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        submitButton.setBackgroundImage(UIFactory.imageWithColor(KM_COLOR_REGISTER, size: submitButton.frame.size), forState: UIControlState.Normal)
        submitButton.setBackgroundImage(UIFactory.imageWithColor(segmented.tintColor, size: submitButton.frame.size), forState: UIControlState.Disabled)
        submitButton.showsTouchWhenHighlighted = true
        
        containerView.addSubview(submitButton)
        
        
        setUpComponentAction()
    }
    
    func setUpComponentAction(){
        agreeImage = UIImage(named: "select")
        disagreeImage = UIImage(named: "unSelect")
        
        agreeImageView.image = disagreeImage
        agreeButton.addTarget(self, action: "agree:", forControlEvents: UIControlEvents.TouchUpInside)
        useAgreementButton.addTarget(self, action: "showAgreement:", forControlEvents: UIControlEvents.TouchUpInside)
        submitButton.addTarget(self, action: "submit:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func agree(sender: AnyObject!){
        if agreeImageView.image == agreeImage{
            agreeImageView.image = disagreeImage
        }else{
            agreeImageView.image = agreeImage
        }
    }
    
    func showAgreement(sender: AnyObject!){
        let agreementVC = UIViewController()
        agreementVC.view.backgroundColor = UIColor.whiteColor()
        
        let statusH: CGFloat = 20
        let bottomH: CGFloat = 60
        let webView = UIWebView(frame: CGRectMake(0, 0 + statusH, agreementVC.view.frame.size.width, agreementVC.view.frame.size.height - statusH - bottomH))
        webView.backgroundColor = UIColor.whiteColor()
        let htmlPath = NSBundle.mainBundle().pathForResource("agreement_strings", ofType: "html")
        let htmlStr = NSString(contentsOfFile: htmlPath!, encoding: NSUTF8StringEncoding, error: nil)
        webView.loadHTMLString(htmlStr as! String, baseURL: NSURL(fileURLWithPath: htmlPath!) )
        agreementVC.view.addSubview(webView)
        
        let emptyView = UIView(frame: CGRectMake(0, agreementVC.view.frame.size.height - bottomH, agreementVC.view.frame.size.width, bottomH))
        emptyView.backgroundColor = UIColor.whiteColor()
        
        let backButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        backButton.frame = CGRectMake(10, 10, emptyView.frame.size.width - 10 * 2, bottomH - 10 * 2)
        backButton.setTitle(i18n("Back"), forState: UIControlState.Normal)
        backButton.backgroundColor = KM_COLOR_MAIN
        backButton.layer.masksToBounds = true
        backButton.layer.cornerRadius = 5
        backButton.addTarget(self, action: "agreementViewBack:", forControlEvents: UIControlEvents.TouchUpInside)
        
        emptyView.addSubview(backButton)
        agreementVC.view.addSubview(emptyView)
        
        self.navigationController?.presentViewController(agreementVC, animated: true, completion: { () -> Void in
            
        })
    }
    
    func agreementViewBack(sender: AnyObject!){
        self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    func submit(sender: AnyObject!){
        let agree = agreeImageView.image == agreeImage
        let usertype = segmented.selectedSegmentIndex
        let account = accountField.text
        let password = passwordField.text
        let rePassword = rePasswordField.text
        
        if !agree{
            let alertView = UIAlertView(title: nil, message: i18n("Please read and tick the appropriate box below"), delegate: nil, cancelButtonTitle: i18n("Sure"))
            alertView.show()
            return
        }
        
        if count(account) < 5 {
            let alertView = UIAlertView(title: nil, message: i18n("UserName lengh must be greater than or equal to 5 numbers including letters!"), delegate: nil, cancelButtonTitle: i18n("Sure"))
            alertView.show()
            return
        }
        
        if count(password) < 5 || count(rePassword) < 5{
            let alertView = UIAlertView(title: nil, message: i18n("Password lengh must be greater than or equal to 5 numbers including letters!"), delegate: nil, cancelButtonTitle: i18n("Sure"))
            alertView.show()
            return
        }
        
        if password != rePassword{
            let alertView = UIAlertView(title: nil, message: i18n("The two input password does not match!"), delegate: nil, cancelButtonTitle: i18n("Sure"))
            alertView.show()
            return
        }
        
        let params = ["username": account, "userpassword": password, "usertype": usertype]
        progressHUD?.mode = MBProgressHUDMode.Indeterminate
        progressHUD?.labelText = ""
        progressHUD?.detailsLabelText = ""
        progressHUD?.show(true)
        AFNetworkingFactory.networkingManager().POST(APP_URL_REGISTER, parameters: params, success: {[unowned self] (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            let dic = responseObj as? NSDictionary
            let code = dic?["code"] as? NSInteger
            if code != nil && code == 1{
                let loginProof = NSMutableDictionary()
                loginProof.setValue(account, forKey: APP_PATH_LOGIN_PROOF_USERNAME)
                loginProof.setValue(password, forKey: APP_PATH_LOGIN_PROOF_PASSWORD)
                loginProof.setValue(usertype, forKey: APP_PATH_LOGIN_PROOF_USERTYPE)
                loginProof.setValue(false, forKey: APP_PATH_LOGIN_PROOF_REMEMBER)
                loginProof.setValue(false, forKey: APP_PATH_LOGIN_PROOF_AUTOLOGIN)
                LocalStroge.sharedInstance().addObject(loginProof, fileName: APP_PATH_LOGIN_PROOF, searchPathDirectory: NSSearchPathDirectory.DocumentDirectory)
                self.progressHUD?.hide(true)
                
                self.navigationController?.popViewControllerAnimated(true)
                
            }else{
                self.progressHUD?.mode = MBProgressHUDMode.Text
                self.progressHUD?.detailsLabelText = (dic?["data"] ?? "") as! String
                self.progressHUD?.hide(true, afterDelay: 2)
            }
            
        }) {[unowned self] (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            self.progressHUD?.mode = MBProgressHUDMode.Text
            self.progressHUD?.detailsLabelText = error.localizedDescription
            self.progressHUD?.hide(true, afterDelay: 2)
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
