//
//  FeedbackViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/25.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class FeedbackViewController: BasicViewController, UITextViewDelegate {

    private var feedbackInfoView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.needLogin = true
        self.title = i18n("Feedback")
        
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        feedbackInfoView.becomeFirstResponder()
    }
    
    func setUpView(){
        let visibelFrame = getVisibleFrame()
        let scrollView = TPKeyboardAvoidingScrollView(frame: visibelFrame)
        self.view.addSubview(scrollView)
        
        let x: CGFloat = 10
        let y: CGFloat = 20
        let w: CGFloat = scrollView.frame.size.width - 2 * x
        let h: CGFloat = 40
        
        let label = UIFactory.labelWithFrame(CGRectMake(x, y, w, h), text: i18n("Please fill in your questions and suggestions"), textColor: RGB(47,48,48), fontSize: 15, numberOfLines: 2, fontName: "Arial-BoldItalicMT", textAlignment: NSTextAlignment.Left)
        scrollView.addSubview(label)
        
        let feedbackH: CGFloat = 130
        feedbackInfoView = UITextView(frame: CGRectMake(x, y + h + 5, w, feedbackH))
        feedbackInfoView.layer.masksToBounds = true
        feedbackInfoView.layer.cornerRadius = 6
        feedbackInfoView.backgroundColor = RGB(236,240,243)
        feedbackInfoView.autocorrectionType = UITextAutocorrectionType.No
        feedbackInfoView.autocapitalizationType = UITextAutocapitalizationType.None
        feedbackInfoView.returnKeyType = UIReturnKeyType.Done
        feedbackInfoView.font = UIFont.systemFontOfSize(14)
        feedbackInfoView.delegate = self
        scrollView.addSubview(feedbackInfoView)
        
        let submitButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        submitButton.frame = CGRectMake(x, feedbackInfoView.frame.origin.y + feedbackH + 10, w, h)
        submitButton.setTitle(i18n("Submit"), forState: UIControlState.Normal)
        submitButton.backgroundColor = RGB(26,188,156)
        submitButton.layer.cornerRadius = 6
        submitButton.layer.masksToBounds = true
        submitButton.addTarget(self, action: "submit", forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(submitButton)
    }
    
    // MARK: - UITextViewDelegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if "\n" == text{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
        
    // MARK: - submit
    func submit(){
        let feedbackInfo = feedbackInfoView.text
        if feedbackInfo.isEmpty{
            let alertView = UIAlertView(title: nil, message: i18n("No content submit"), delegate: nil, cancelButtonTitle: i18n("Sure"))
            alertView.show()
            return
        }
        
        let params = ["question_content": feedbackInfo]
        AFNetworkingFactory.networkingManager().POST(APP_URL_FEEDBACK, parameters: params, success: {[unowned self] (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            let dic = responseObj as? NSDictionary
            let code = dic?["code"] as? NSInteger
            if code != nil && code == 1{
                JDStatusBarNotification.showWithStatus(i18n("Successful submission!"), dismissAfter: 1)
                self.navigationController?.popViewControllerAnimated(true)
            }else{
                if dic?["data"] != nil{
                    JDStatusBarNotification.showWithStatus(dic?["data"] as? String ?? "", dismissAfter: 1)
                }
            }
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            KMLog(error.localizedDescription)
            JDStatusBarNotification.showWithStatus(i18n("Failed to connect link to server!"), dismissAfter: 1.0)
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
