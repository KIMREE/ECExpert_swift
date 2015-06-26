//
//  MagnetView.swift
//  ECExpert
//
//  Created by Fran on 15/6/24.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class MagnetView: UIView {
    
    var originFrame: CGRect!
    var startPoint: CGPoint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        if originFrame == nil{
            originFrame = self.frame
        }
        
        let touch = touches.first as! UITouch
        startPoint = touch.locationInView(self.window)
        
        let superView = self.superview
        superview?.bringSubviewToFront(self)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        let touch = touches.first as! UITouch
        let currentPoint = touch.locationInView(self.window)
        
        var moveToFrame = CGRectMake(originFrame.origin.x + (currentPoint.x - startPoint.x), originFrame.origin.y + (currentPoint.y - startPoint.y), originFrame.size.width, originFrame.size.height)
        self.frame = moveToFrame
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        resetView()
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        resetView()
    }
    
    func resetView(){
        if originFrame == nil{
            originFrame = self.frame
        }
        UIView.beginAnimations("resetView", context: nil)
        UIView.setAnimationDelay(0)
        self.frame = originFrame
        UIView.commitAnimations()
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
