//
//  ShowQRCodeViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/25.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class ShowQRCodeViewController: BasicViewController {
    
    var qrcodeString: String!
    
    private var qrcodeMD: MDQRCodeGenerator!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.needLogin = true
        
        qrcodeMD = MDQRCodeGenerator()
        
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView(){
        let visibleFrame = getVisibleFrame()
        let w: CGFloat = visibleFrame.size.width * 2.0 / 3.0
        let h: CGFloat = w
        let x: CGFloat = (visibleFrame.size.width - w) / 2.0
        let y: CGFloat = (visibleFrame.size.height - h) / 2.0 + visibleFrame.origin.y
        
        let qrcodeView = UIImageView(frame: CGRectMake(x, y, w, h))
        qrcodeView.image = qrcodeMD.createQRForString(qrcodeString)
        
        self.view.addSubview(qrcodeView)
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
