//
//  UIAlertView+Block.swift
//  ECExpert
//
//  Created by Fran on 15/6/11.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import Foundation

/**
*
*   objc_setAssociatedObject 无法将 Function 传递过去
*
*   在这里使用 class CompleteAlertViewFuncClass 做了一层包装
*
*/

typealias CompleteAlertViewFunc  = (buttonIndex: Int) -> Void

class CompleteAlertViewFuncClass: NSObject {
    var completeAlertViewFunc: CompleteAlertViewFunc?
    
    init(completeAlertViewFunc: CompleteAlertViewFunc?){
        self.completeAlertViewFunc = completeAlertViewFunc
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return CompleteAlertViewFuncClass(completeAlertViewFunc: self.completeAlertViewFunc)
    }
}

extension UIAlertView: UIAlertViewDelegate{
    
    private static var key = "AlertViewComplete"
    
    func showAlertViewWithCompleteBlock(alertViewComplete: CompleteAlertViewFunc! ){
        if alertViewComplete != nil{
            objc_removeAssociatedObjects(self)
            objc_setAssociatedObject(self, &UIAlertView.key, CompleteAlertViewFuncClass(completeAlertViewFunc: alertViewComplete) as AnyObject, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
            self.delegate = self
        }
        self.show()
    }
    
    public func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        let completeAlertViewFuncObj: CompleteAlertViewFuncClass? = objc_getAssociatedObject(self, &UIAlertView.key) as? CompleteAlertViewFuncClass
        
        if completeAlertViewFuncObj != nil && completeAlertViewFuncObj?.completeAlertViewFunc != nil{
            completeAlertViewFuncObj!.completeAlertViewFunc!(buttonIndex: buttonIndex)
        }
    }
}