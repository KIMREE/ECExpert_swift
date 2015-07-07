//
//  UIFactory.swift
//  ECExpert
//
//  Created by Fran on 15/6/24.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class UIFactory: NSObject {
    
    /**
    拼装label
    
    :param: frame         frame
    :param: text          label显示文本
    :param: textColor     label文本显示颜色
    :param: fontSize      label字体大小
    :param: textAlignment label文本对其方式
    
    :returns: 组装好的label
    */
    class func labelWithFrame(frame: CGRect, text: String, textColor: UIColor, fontSize: CGFloat = UILabel().font.pointSize, numberOfLines: Int = 0, fontName: String = UILabel().font.fontName , textAlignment: NSTextAlignment = NSTextAlignment.Left) -> UILabel{
        let label = UILabel()
        label.frame = frame
        label.text = text
        label.textColor = textColor
        label.font = UIFont(name: fontName, size: fontSize)
        label.numberOfLines = numberOfLines
        label.textAlignment = textAlignment
        return label
    }
    
    /**
    生成纯色图片
    
    :param: color 图片颜色
    :param: size  图片尺寸
    
    :returns: 纯色图片
    */
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
    
    /**
    磁贴
    
    :param: frame           磁贴的frame
    :param: backgroundColor 磁贴背景色
    :param: imageName       磁贴中心图片名称
    :param: title           磁贴标题
    :param: clickViewTag    磁贴中心可点击view的tag
    :param: clickViewWidth  磁贴中心可点击view的width
    
    :returns: 组装好的磁贴
    */
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
    
    /**
    组装 tableviewcell
    
    :param: tableView            celll隶属于tableview
    :param: cellIdentifier       cell identifier
    :param: cellType             cell type
    :param: cleanTextAndImage    默认值为true, 每次获取后是否清理 textLabel, detailTextLabel, 以及 imageView 的内容
    :param: cleanCellContentView 默认值为true, 每次获取到cell后，是否清理掉contentView里面的subview
    :param: cellInitProperties   cell在初始化时，需要做的处理
    
    :returns: 根据传入参数处理后的cell
    */
    class func tableViewCellForTableView(tableView: UITableView, cellIdentifier: String, cellType: UITableViewCellStyle = UITableViewCellStyle.Subtitle, cleanTextAndImage: Bool = true, cleanCellContentView: Bool = true, cellInitProperties: (tableViewCell: UITableViewCell!) -> Void) -> UITableViewCell!{
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        if cell == nil{
            cell = UITableViewCell(style: cellType, reuseIdentifier: cellIdentifier)
            cellInitProperties(tableViewCell: cell!)
        }
        
        if cleanTextAndImage{
            cell!.textLabel?.text = ""
            cell!.detailTextLabel?.text = ""
            cell!.imageView?.image = nil
        }
        
        if cleanCellContentView{
            for view in cell!.contentView.subviews{
                view.removeFromSuperview()
            }
        }
        
        return cell!
    }
    
    /**
    缩放图片
    
    :param: image     被缩放的图片
    :param: scaleSize 缩放的尺寸
    
    :returns: 缩放后的图片
    */
    class func originImage(image: UIImage, scaleSize: CGSize) -> UIImage{
        UIGraphicsBeginImageContext(scaleSize)
        image.drawInRect(CGRectMake(0, 0, scaleSize.width, scaleSize.height))
        let scaleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaleImage
    }
    
    /**
    向下箭头
    
    :param: width     箭头宽度
    :param: height    箭头高度
    :param: fillColor 箭头颜色
    
    :returns: 组装好的向下三角形箭头图片
    */
    class func bottomTriangleImage(width: CGFloat, height: CGFloat, fillColor: UIColor) -> UIImage!{
        struct SingleImage{
            static var imageInstance: UIImage?
            static var token: dispatch_once_t = 0
        }
        //dispatch_once(&SingleImage.token, { () -> Void in
            let size = CGSizeMake(width, height)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            let path = UIBezierPath()
            path.lineWidth = 1.0
            path.moveToPoint(CGPointMake(0.0, 0.0))
            path.addLineToPoint(CGPointMake(width, 0.0))
            path.addLineToPoint(CGPointMake(width / 2.0, height))
            path.closePath()
            fillColor.setFill()
            path.fill()
            
            SingleImage.imageInstance = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        //})
        return SingleImage.imageInstance
    }
    
    /**
    向左箭头
    
    :param: width     箭头宽度
    :param: height    箭头高度
    :param: fillColor 箭头颜色
    
    :returns: 组装的向左箭头图片
    */
    class func leftTriangleImage(width: CGFloat, height: CGFloat, fillColor: UIColor) -> UIImage!{
        struct SingleImage{
            static var imageInstance: UIImage?
            static var token: dispatch_once_t = 0
        }
        //dispatch_once(&SingleImage.token, { () -> Void in
            let size = CGSizeMake(width, height)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(0.0, height / 2.0))
            path.addLineToPoint(CGPointMake(width , 0.0))
            path.addLineToPoint(CGPointMake(width, height))
            path.closePath()
            fillColor.setFill()
            path.fill()
            
            SingleImage.imageInstance = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        //})
        return SingleImage.imageInstance
    }
    
    /**
    向右箭头
    
    :param: width     箭头宽度
    :param: height    箭头高度
    :param: fillColor 箭头颜色
    
    :returns: 组装的向右箭头图片
    */
    class func rightTriangleImage(width: CGFloat, height: CGFloat, fillColor: UIColor) -> UIImage!{
        struct SingleImage{
            static var imageInstance: UIImage?
            static var token: dispatch_once_t = 0
        }
        //dispatch_once(&SingleImage.token, { () -> Void in
            let size = CGSizeMake(width, height)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(0.0, 0.0))
            path.addLineToPoint(CGPointMake(width, height / 2.0))
            path.addLineToPoint(CGPointMake(0.0, height))
            path.closePath()
            fillColor.setFill()
            path.fill()
            
            SingleImage.imageInstance = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        //})
        return SingleImage.imageInstance
    }
    
}
