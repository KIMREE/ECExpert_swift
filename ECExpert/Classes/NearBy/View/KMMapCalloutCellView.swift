//
//  KMMapCalloutCellView.swift
//  ECExpert
//
//  Created by Fran on 15/6/18.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class KMMapCalloutCellView: UIView {
    
    let leftImageView: UIImageView
    let titleLabel: UILabel
    private let rightArrow: UIImageView
    
    override init(frame: CGRect) {
        let w: CGFloat = 200
        let h: CGFloat = 40
        let cellFrame = CGRectMake(0, 0, w, h)
        
        let leftW: CGFloat = 40
        let centerW: CGFloat = 140
        let rightW = w - leftW - centerW
        let leftFrame = CGRectMake(0, 0, leftW, h)
        let centerFrame = CGRectMake(0 + leftW, 0, centerW, h)
        let rightFrame = CGRectMake(0 + leftW + centerW, 0, rightW, h)
        
        leftImageView = UIImageView(frame: leftFrame)
        
        titleLabel = UILabel(frame: centerFrame)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont.systemFontOfSize(13)
        titleLabel.textColor = RGB(26, 188, 156)
        
        rightArrow = UIImageView(frame: rightFrame)
        rightArrow.image = UIImage(named: "arrow")
        
        super.init(frame: cellFrame)
        
        self.addSubview(leftImageView)
        self.addSubview(titleLabel)
        self.addSubview(rightArrow)
    }

    required convenience init(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }

}
