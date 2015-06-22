//
//  LoginViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/22.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class LoginViewController: BasicViewController {
    
    private var containerView: UIView!
    
    private var segmented: UISegmentedControl!
    
    private var accountField: UITextField!
    private var passwordField: UITextField!
    
    private var rememberImageView: UIImageView!
    private var rememberLabel: UILabel!

    private var forgotLabel: UILabel!
    
    private var loginButton: UIButton!
    private var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpContainerView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - 初始化界面UI
    /**
    初始化界面ui
    */
    func setUpContainerView(){
        let scrollView = TPKeyboardAvoidingScrollView(frame: getVisibleFrame())
        self.view.addSubview(scrollView)
        
        let visibleFrame = getVisibleFrame()
        let w = visibleFrame.size.width
        let h1: CGFloat = 100
        let h2: CGFloat = 50
        let h3: CGFloat = 50
        let h4: CGFloat = 50
        let h5: CGFloat = 50
        let h6: CGFloat = 50
        let h: CGFloat = h1 + h2 + h3 + h4 + h5 + h6
        let y: CGFloat = (visibleFrame.size.height - h) / 2.0
        let x = visibleFrame.origin.x
        
        containerView = UIView(frame: CGRectMake(x, y, w, h))
        scrollView.addSubview(containerView)
        
        var startH: CGFloat = 0
        // logo h1
        let imageViewW: CGFloat = h1
        let imageViewH: CGFloat = h1
        let imageViewX: CGFloat = (w - imageViewW) / 2.0
        let imageViewY: CGFloat = startH
        let imageView = UIImageView(frame: CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH))
        imageView.image = UIImage(named: "logoK")
        containerView.addSubview(imageView)
        
        startH += h1
        // userType h2
        let segmentedW: CGFloat = 150
        let segmentedH: CGFloat = 30
        let segmentedX: CGFloat = (w - segmentedW) / 2.0
        let segmentedY: CGFloat = startH + (h2 - segmentedH) / 2.0
        segmented = UISegmentedControl(frame: CGRectMake(segmentedX, segmentedY, segmentedW, segmentedH))
        segmented.insertSegmentWithTitle(i18n("Customer"), atIndex: 0, animated: true)
        segmented.insertSegmentWithTitle(i18n("Dealer"), atIndex: 1, animated: true)
        segmented.tintColor = RGB(26,188,156)
        segmented.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Selected)
        containerView.addSubview(segmented)
        
        startH += h2
        let leftRightPadding: CGFloat = 20
        // account h3
        let accountW: CGFloat = 30
        let accountH: CGFloat = 30
        let accountX = leftRightPadding
        let accountY = startH + (h3 - accountH) / 2.0
        let accountImageView = UIImageView(frame: CGRectMake(accountX, accountY, accountW, accountH))
        accountImageView.image = UIImage(named: "account")
        accountField = UITextField(frame: CGRectMake(accountX + accountW, accountY, w - (accountX + accountW + leftRightPadding), accountH))
        accountField.textAlignment = NSTextAlignment.Left
        accountField.placeholder = i18n("Account")
        accountField.textColor = UIColor.whiteColor()
        accountField.font = UIFont.systemFontOfSize(18)
        let accountLine = UIView(frame: CGRectMake(accountX, accountY + accountH, w - 2 * leftRightPadding, 1))
        accountLine.backgroundColor = UIColor.whiteColor()
        
        containerView.addSubview(accountImageView)
        containerView.addSubview(accountField)
        containerView.addSubview(accountLine)
        
        startH += h3
        // password h4
        let passwordW: CGFloat = 30
        let passwordH: CGFloat = 30
        let passwordX = leftRightPadding
        let passwordY = startH + (h4 - passwordH) / 2.0
        let passwordImageView = UIImageView(frame: CGRectMake(passwordX, passwordY, passwordW, passwordH))
        passwordImageView.image = UIImage(named: "password")
        
        passwordField = UITextField(frame: CGRectMake(passwordX + passwordW, passwordY, w - (passwordX + passwordW + leftRightPadding), passwordH))
        passwordField.secureTextEntry = true
        passwordField.textAlignment = NSTextAlignment.Left
        passwordField.placeholder = i18n("Password")
        passwordField.textColor = UIColor.whiteColor()
        passwordField.font = UIFont.systemFontOfSize(18)
        
        let passwordLine = UIView(frame: CGRectMake(passwordX , passwordY + passwordH, w - 2 * leftRightPadding, 1))
        passwordLine.backgroundColor = UIColor.whiteColor()
        
        containerView.addSubview(passwordImageView)
        containerView.addSubview(passwordField)
        containerView.addSubview(passwordLine)
        
        startH += h4
        // label h5
        let rememberW: CGFloat = 20
        let rememberH: CGFloat = 20
        let rememberX = leftRightPadding
        let rememberY = startH + (h5 - rememberH) / 2.0
        rememberImageView = UIImageView(frame: CGRectMake(rememberX, rememberY, rememberW, rememberH))
        rememberImageView.image = UIImage(named: "unRememberAccount")
        
        rememberLabel = UILabel(frame: CGRectMake(rememberX + rememberW, rememberY, 0, 0))
        rememberLabel.numberOfLines = 1
        rememberLabel.textColor = UIColor.whiteColor()
        rememberLabel.text = i18n("Remember Password")
        let remembelSize = rememberLabel.sizeThatFits(CGSizeZero)
        rememberLabel.frame = CGRectMake(rememberX + rememberW, rememberY, remembelSize.width, rememberH)
        
        containerView.addSubview(rememberImageView)
        containerView.addSubview(rememberLabel)
        
        forgotLabel = UILabel(frame: CGRectZero)
        forgotLabel.numberOfLines = 1
        forgotLabel.textColor = UIColor.whiteColor()
        forgotLabel.text = i18n("FORGOT?")
        let forgotSize = forgotLabel.sizeThatFits(CGSizeZero)
        forgotLabel.frame = CGRectMake(w - leftRightPadding - forgotSize.width, rememberY, forgotSize.width, forgotSize.height)
        containerView.addSubview(forgotLabel)
        
        startH += h5
        // button h6
        let buttonW: CGFloat = w / 2.0 - leftRightPadding - leftRightPadding/2.0
        let buttonH: CGFloat = 30
        let radius: CGFloat = buttonH / 2.0
        let buttonY: CGFloat = startH + (h6 - buttonH) / 2.0
        registerButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        registerButton.frame = CGRectMake(leftRightPadding, buttonY, buttonW, buttonH)
        registerButton.setTitle(i18n("Register"), forState: UIControlState.Normal)
        registerButton.showsTouchWhenHighlighted = true
        registerButton.setBackgroundImage(imageWithColor(RGB(234, 47, 75), size: registerButton.frame.size), forState: UIControlState.Normal)
        registerButton.setBackgroundImage(imageWithColor(UIColor.grayColor(), size: registerButton.frame.size), forState: UIControlState.Highlighted)
        registerButton.layer.masksToBounds = true
        registerButton.layer.cornerRadius = radius
        
        loginButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        loginButton.frame = CGRectMake(w / 2.0 + leftRightPadding / 2.0, buttonY, buttonW, buttonH)
        loginButton.setTitle(i18n("Login"), forState: UIControlState.Normal)
        loginButton.showsTouchWhenHighlighted = true
        loginButton.setBackgroundImage(imageWithColor(RGB(42, 179, 233), size: loginButton.frame.size), forState: UIControlState.Normal)
        loginButton.setBackgroundImage(imageWithColor(UIColor.grayColor(), size: loginButton.frame.size), forState: UIControlState.Highlighted)
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = radius
        
        containerView.addSubview(loginButton)
        containerView.addSubview(registerButton)
        
        setUpComponentAction()
        
    }
    
    func imageWithColor(color: UIColor!, size: CGSize) -> UIImage{
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /**
    监控ui界面的各个控件
    */
    func setUpComponentAction(){
        
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
