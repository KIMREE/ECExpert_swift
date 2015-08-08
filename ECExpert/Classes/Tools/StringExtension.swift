//
//  StringExtension.swift
//  ECExpert
//
//  Created by Fran on 15/7/31.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

extension String{
    func sha1() -> String{
        let data = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH),repeatedValue:0)
        CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
        
        let output = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        for byte in digest{
            output.appendFormat("%02x", byte)
        }
        return output as String
    }
}