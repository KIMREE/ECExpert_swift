//
//  ECExpert-Prefix.swift
//  ECExpert
//
//  Created by Fran on 15/6/11.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import Foundation
import UIKit

// RGB 颜色获取快速方法
func RGBA(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor{
    return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
}

func RGB(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
    return RGBA(red, green, blue, 1.0)
}

let KM_COLOR_TABBAR_NAVIGATION = RGB(208, 6, 51)


// 国际化
func i18n(key: String) -> String{
    return NSLocalizedString(key, comment: key)
}

// 日志
func KMLog(format: String, args: CVarArgType...){
    #if DEBUG
    NSLogv(format, getVaList(args))
    #else
    // NO LOG
    #endif
}

func KMLog(format: String){
    KMLog(format, [])
}

// AppDelegate
func currentAppDelegate() -> AppDelegate{
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    return appDelegate
}

// System
let APP_SYS_DEVICE_VERSION = (UIDevice.currentDevice().systemVersion as NSString).doubleValue


// API_URL
let APP_URL = "https://itunes.apple.com/lookup?id=948643406"
let APP_URL_ITUNES = "https://itunes.apple.com/us/app/dian-zi-yan-zhuan-jia/id948643406?l=zh&ls=1&mt=8"

let APP_URL_LOGIN = "http://www.kimree.com.cn/app/?action=login" // 登录
let APP_URL_LOGOUT = "http://www.kimree.com.cn/app/?action=logout" // 登出
let APP_URL_REGISTER = "http://www.kimree.com.cn/app/?action=joinuser" // 注册
let APP_URL_LOGIN_USERINFO = "http://www.kimree.com.cn/app/?action=getuserinfo" // 获取登录用户信息

let APP_URL_CHECKVIP = "http://www.kimree.com.cn/app/?action=checkvip"  // 根据用户id和会员卡号确定用户合法性
let APP_URL_TRADE_INPUT = "http://www.kimree.com.cn/app/?action=typetrade"  // 录入交易
let APP_URL_SCAN_BAR_CODE = "http://www.kimree.com.cn/app/scancode.php?"  // 扫描条形码

let APP_URL_NEWS = "http://m.ecig100.com/"
let APP_URL_KIMREE = "http://www.kimree.com.cn"
let APP_URL_DEALER = "http://www.ecig100.com/api/?action=getDealer" //获取经销商及烟酒商信息

let APP_URL_TRADE_RECORD = "http://www.kimree.com.cn/app/?action=selecttrade" // 查看交易记录
let APP_URL_TRADE_RECORD_DETAIL = "http://www.kimree.com.cn/app/?action=tradeinfo"  // 交易记录详情

let APP_URL_FEEDBACK = "http://www.ecigarfan.com/api/api.php?action=sendask" 

// fileName
let APP_PATH_LOGIN_PROOF = "user_login_proof"
let APP_PATH_LOGIN_PROOF_AUTOLOGIN = "autologin"
let APP_PATH_LOGIN_PROOF_REMEMBER = "remember"
let APP_PATH_LOGIN_PROOF_USERNAME = "username"
let APP_PATH_LOGIN_PROOF_PASSWORD = "userpassword"
let APP_PATH_LOGIN_PROOF_USERTYPE = "usertype"
let APP_PATH_LOGIN_PROOF_SID = "sid"

let APP_PATH_LOGINUSER_INFO = "user_information"
let APP_PATH_DEALER_INFO = "dealer_information1"

// notification
let APP_NOTIFICATION_LOGIN = "login_succes"


// frame
let KM_FRAME_SCREEN_BOUNDS = UIScreen.mainScreen().bounds
let KM_FRAME_SCREEN_WIDTH: CGFloat = KM_FRAME_SCREEN_BOUNDS.size.width
let KM_FRAME_SCREEN_HEIGHT: CGFloat = KM_FRAME_SCREEN_BOUNDS.size.height
let KM_FRAME_VIEW_NAVIGATIONBAR_HEIGHT: CGFloat = 44.0
let KM_FRAME_VIEW_TABBAR_HEIGHT: CGFloat = 49.0
let KM_FRAME_VIEW_STATUSBAR_HEIGHT: CGFloat = 20.0
let KM_FRAME_VIEW_TOOLBAR_HEIGHT: CGFloat = 49.0


