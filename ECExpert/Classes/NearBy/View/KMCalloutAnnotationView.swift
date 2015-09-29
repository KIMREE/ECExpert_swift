//
//  KMCalloutAnnotationView.swift
//  ECExpert
//
//  Created by Fran on 15/6/16.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class KMCalloutAnnotationView: MKAnnotationView {
    
    private var containerView: UIView!
    
    private let bottomArrowW: CGFloat = 20
    private let bottomArrowH: CGFloat = 10
    private let radius: CGFloat = 6
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRectZero)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addContainerView(containerView: UIView!){
        removeContainerView()
        
        var frame = containerView.frame
        frame.origin.x = 0
        frame.origin.y = 0
        containerView.frame = frame
        self.frame = frame
        
        let w = frame.size.width
        let h = frame.size.height
        
        var fillColor = containerView.backgroundColor
        if fillColor == nil{
            fillColor = RGB(0, green: 0, blue: 0)
            containerView.backgroundColor = fillColor
        }
        
        // 向下的箭头略微上移，将containerView压住
        let bottomArrowImageViewFrame = CGRectMake((w - bottomArrowW)/2.0 - 2.0, h - 2.0, bottomArrowW, bottomArrowH + 2.0)
        let bottomArrowImageView = UIImageView(frame: bottomArrowImageViewFrame)
        bottomArrowImageView.image = UIFactory.bottomTriangleImage(bottomArrowW, height: bottomArrowH, fillColor: fillColor!)
        bottomArrowImageView.backgroundColor = UIColor.clearColor()
        
        self.addSubview(bottomArrowImageView)
        
        self.containerView = containerView
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = radius
        
        self.addSubview(containerView)
        self.centerOffset = CGPointMake(0, -(h + bottomArrowH - 5))
        self.canShowCallout = false
        self.userInteractionEnabled = true
        
        self.setNeedsDisplay()
    }
    
    func removeContainerView(){
        for view in self.subviews{
            view.removeFromSuperview()
        }
    }
    
    func getContainerView() -> UIView?{
        return self.containerView
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 2)
        
        self.drawPath(context!, rect: rect)
        CGContextFillPath(context);
        
        //yu mark
        // CGPathRef path = CGContextCopyPath(context);
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 1;
        //inser
        //self.layer.shadowPath = path;
        self.layer.shadowPath = CGContextCopyPath(context)
    }
    
    private func drawPath(context: CGContextRef, rect: CGRect){
        let rect = rect
        
        let minX = CGRectGetMinX(rect)
        let maxX = CGRectGetMaxX(rect)
//        let minY = CGRectGetMinY(rect)
        let maxY = CGRectGetMaxY(rect)
        
        let minBottomArrowX = (maxX - minX - bottomArrowW) / 2.0
        let maxBottomArrowX = (maxX - minX + bottomArrowW) / 2.0
        let midBottomArrowX = (maxX - minX) / 2.0
        let minBottomArrowY = maxY
        let maxBottomArrowY = maxY + bottomArrowH
        
        CGContextMoveToPoint(context, maxBottomArrowX, minBottomArrowY)
        CGContextAddLineToPoint(context, midBottomArrowX, maxBottomArrowY)
        CGContextAddLineToPoint(context, minBottomArrowX, minBottomArrowY)
        
        CGContextClosePath(context)
    }
}
