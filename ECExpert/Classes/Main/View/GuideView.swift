//
//  GuideView.swift
//  ECExpert
//
//  Created by Fran on 15/7/1.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class GuideView: UIView , UIScrollViewDelegate{

    private let imageNameArray = ["guide1", "guide2", "guide3"]
    
    private var scrollView: UIScrollView!
    private var page: UIPageControl!
    
    init(){
        super.init(frame: KM_FRAME_SCREEN_BOUNDS)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showInView(view: UIView){
        let countInt = imageNameArray.count
        let countFloat = CGFloat(countInt)
        
        let scrollFrame = self.bounds
        let w = scrollFrame.size.width
        let h = scrollFrame.size.height
        scrollView = UIScrollView(frame: scrollFrame)
        scrollView.backgroundColor = UIColor.whiteColor()
        scrollView.contentSize = CGSizeMake(w * countFloat, h)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        
        for i in 0 ..< countInt{
            var imageFrame = scrollFrame
            imageFrame.origin.x = w * CGFloat(i)
            let imageName = imageNameArray[i]
            let imageView = UIImageView(frame: imageFrame)
            imageView.image = UIImage(named: imageName)
            if i == (imageNameArray.count - 1){
                imageView.userInteractionEnabled = true
                let buttonW: CGFloat = 200
                let buttonH: CGFloat = 40
                let bottomPadding: CGFloat = 40
                let buttonFrame = CGRectMake( (w - buttonW) / 2.0, h - buttonH - bottomPadding, buttonW, buttonH)
                let button = UIButton(type: UIButtonType.Custom)
                button.frame = buttonFrame
                button.setTitle(i18n("Tap to enter"), forState: UIControlState.Normal)
                button.addTarget(self, action: "showMainPage", forControlEvents: UIControlEvents.TouchUpInside)
                
                imageView.addSubview(button)
            }
            scrollView.addSubview(imageView)
        }
        self.addSubview(scrollView)
        
        
        let pageW: CGFloat = 20 * countFloat
        let paheH: CGFloat = 20
        let topPadding: CGFloat = 30
        page = UIPageControl(frame: CGRectMake((w - pageW) / 2.0, 0 + topPadding, pageW, paheH))
        page.numberOfPages = countInt
        page.currentPage = 0
        self.addSubview(page)
        
        view.addSubview(self)
    }
    
    func showMainPage(){
        UIView.animateWithDuration(1, animations: { () -> Void in
                self.alpha = 0
            }) { (finished: Bool) -> Void in
                if finished{
                    self.removeFromSuperview()
                }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentPage = scrollView.contentOffset.x / scrollView.frame.size.width
        page.currentPage = Int(currentPage)
    }
    
}
