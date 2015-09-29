//
//  UITabBarTransitionAnimation.swift
//  ECExpert
//
//  Created by Fran on 15/6/12.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

/**
*  UITabBarViewController 的切换动画
*/
class UITabBarTransitionAnimation:NSObject, UIViewControllerAnimatedTransitioning {
    
    // 需要传入
    var tabBarSubviewControllers: NSArray
    
    init(tabBarSubviewControllers: NSArray){
        self.tabBarSubviewControllers = tabBarSubviewControllers
        super.init()
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        let fromIndex = self.tabBarSubviewControllers.indexOfObject(fromViewController!)
        let toIndex = self.tabBarSubviewControllers.indexOfObject(toViewController!)
        
        var fromTransform: CGAffineTransform!
        var toTransform: CGAffineTransform!
        containerView!.insertSubview(toViewController!.view!, aboveSubview: fromViewController!.view!)
        if toIndex > fromIndex {
            toViewController?.view.transform = CGAffineTransformMakeTranslation(KM_FRAME_SCREEN_WIDTH, 0)
            fromTransform = CGAffineTransformMakeTranslation(-KM_FRAME_SCREEN_WIDTH,0)
            toTransform = CGAffineTransformMakeTranslation(0,0)
        }else{
            toViewController?.view.transform = CGAffineTransformMakeTranslation(-KM_FRAME_SCREEN_WIDTH, 0)
            fromTransform = CGAffineTransformMakeTranslation(KM_FRAME_SCREEN_WIDTH, 0)
            toTransform = CGAffineTransformMakeTranslation(0,0)
        }
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            fromViewController!.view.transform = fromTransform
            toViewController!.view.transform = toTransform
        }) { (completed: Bool) -> Void in
            fromViewController!.view.transform = CGAffineTransformIdentity
            transitionContext.completeTransition(true)
        }
    }
}
