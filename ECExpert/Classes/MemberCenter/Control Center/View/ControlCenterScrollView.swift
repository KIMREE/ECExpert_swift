//
//  ControlCenterScrollView.swift
//  ECExpert
//
//  Created by Fran on 15/6/24.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class ControlCenterScrollView: UIScrollView {
    
    override func touchesShouldCancelInContentView(view: UIView!) -> Bool {
        return false
    }
    
    override func touchesShouldBegin(touches: Set<NSObject>!, withEvent event: UIEvent!, inContentView view: UIView!) -> Bool {
        return true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
