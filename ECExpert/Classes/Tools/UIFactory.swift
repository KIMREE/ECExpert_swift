//
//  UIFactory.swift
//  ECExpert
//
//  Created by Fran on 15/6/24.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class UIFactory: NSObject {
    
    class func labelWithFrame(frame: CGRect, text: String, textColor: UIColor, fontSize: CGFloat, numberOfLines: Int = 0, fontName: String = UILabel().font.fontName, textAlignment: NSTextAlignment = NSTextAlignment.Left) -> UILabel{
        let label = UILabel()
        label.frame = frame
        label.text = text
        label.textColor = textColor
        label.font = UIFont(name: fontName, size: fontSize)
        label.numberOfLines = numberOfLines
        label.textAlignment = textAlignment
        return label
    }
    
    
    class func imageWithColor(color: UIColor!, size: CGSize) -> UIImage{
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    class func magnetViewWithFrame(frame: CGRect, backgroundColor: UIColor, imageName: String, title: String, clickViewTag: Int, clickViewWidth: CGFloat = 100) -> MagnetView{
        let magnetView = MagnetView(frame: frame)
        magnetView.backgroundColor = backgroundColor
        
        let clickViewHeight: CGFloat = frame.size.height
        let clickViewFrame = CGRectMake((frame.size.width - clickViewWidth) / 2.0, 0, clickViewWidth, clickViewHeight)
        let clickView = UIView(frame: clickViewFrame)
        clickView.backgroundColor = backgroundColor
        clickView.tag = clickViewTag
        
        let labelWidth: CGFloat = clickViewWidth
        let labelHeight: CGFloat = 21.0
        let imageW: CGFloat = 60
        let imageH: CGFloat = 60
        let imageLabelDistance: CGFloat = 2
        let imageY: CGFloat = (clickViewHeight - (imageH + labelHeight + imageLabelDistance)) / 2.0 >= 0 ? (clickViewHeight - (imageH + labelHeight + imageLabelDistance)) / 2.0 : 0
        let labelY: CGFloat = imageY + imageH + imageLabelDistance
        
        let imageViewFrame = CGRectMake((clickViewWidth - imageW) / 2.0, imageY, imageW, imageH)
        let imageView = UIImageView(frame: imageViewFrame)
        imageView.backgroundColor = UIColor.clearColor()
        imageView.image = UIImage(named: imageName)
        
        let labelFrame = CGRectMake((clickViewWidth - labelWidth) / 2.0, labelY, labelWidth, labelHeight)
        let labelView = UIFactory.labelWithFrame(labelFrame, text: title, textColor: UIColor.whiteColor(), fontSize: 17, numberOfLines: 1, textAlignment: NSTextAlignment.Center)
        
        clickView.addSubview(imageView)
        clickView.addSubview(labelView)
        magnetView.addSubview(clickView)
        
        return magnetView
    }
       
}
