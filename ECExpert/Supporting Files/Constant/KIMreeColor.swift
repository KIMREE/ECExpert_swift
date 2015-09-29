//
//  KIMreeColor.swift
//  ECExpert
//
//  Created by Fran on 15/8/19.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import Foundation

// RGB 颜色获取快速方法
func RGBA(red red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor{
    return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
}

func RGB(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
    return RGBA(red: red, green: green, blue: blue, alpha: 1.0)
}

let KM_COLOR_MAIN = RGB(208, green: 6, blue: 51)
let KM_COLOR_LOGIN = RGB(39, green: 178, blue: 233)
let KM_COLOR_REGISTER = RGB(59, green: 88, blue: 158)

let KM_COLOR_BUTTON_MAIN = RGB(207, green: 35, blue: 73)