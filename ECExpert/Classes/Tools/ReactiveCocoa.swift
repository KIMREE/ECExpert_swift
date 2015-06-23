//
//  ReactiveCocoa.swift
//  ECExpert
//
//  Created by Fran on 15/6/23.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import Foundation



struct RAC  {
    var target : NSObject!
    var keyPath : String!
    var nilValue : AnyObject!
    
    init(_ target: NSObject!, _ keyPath: String, nilValue: AnyObject? = nil) {
        self.target = target
        self.keyPath = keyPath
        self.nilValue = nilValue
    }
    
    func assignSignal(signal : RACSignal) {
        signal.setKeyPath(self.keyPath, onObject: self.target, nilValue: self.nilValue)
    }
}

extension NSObject {
    func RACObserve(target: NSObject!,_ keyPath: String) -> RACSignal{
        return target.rac_valuesForKeyPath(keyPath, observer: self)
    }
}


infix operator <~ {}
func <~ (rac: RAC, signal: RACSignal) {
    rac.assignSignal(signal)
}

infix operator ~> {}
func ~> (signal: RACSignal, rac: RAC) {
    rac.assignSignal(signal)
}
