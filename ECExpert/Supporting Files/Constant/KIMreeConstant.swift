//
//  KIMreeConstant.swift
//  ECExpert
//
//  Created by Fran on 15/6/11.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

// 国际化
func i18n(key: String) -> String{
    return NSLocalizedString(key, comment: key)
}

/**
*得到本机现在用的语言
* en:英文  zh-Hans:简体中文   zh-Hant:繁体中文    ja:日本  ......
*/
func currentLanguage() -> String{
    return NSUserDefaults.standardUserDefaults().objectForKey("AppleLanguages")?.firstObject as! String
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
    KMLog(format, args: [])
}

// AppDelegate
func currentAppDelegate() -> AppDelegate{
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    return appDelegate
}

func currentLoginUserInfo() -> Dictionary<String, AnyObject>?{
    return currentAppDelegate().loginUserInfo
}

func bundleInfoDictionary() -> [NSObject : AnyObject]?{
    return NSBundle.mainBundle().infoDictionary
}

func getUserDefaults() -> NSUserDefaults{
    return NSUserDefaults.standardUserDefaults()
}

// System
let APP_SYS_DEVICE_VERSION = (UIDevice.currentDevice().systemVersion as NSString).doubleValue

let APP_KEY_FIRST_LUNCH = "app_is_first_lunch"


// fileName
let APP_PATH_LOGIN_PROOF = "user_login_proof"
let APP_PATH_LOGIN_PROOF_AUTOLOGIN = "autologin"
let APP_PATH_LOGIN_PROOF_REMEMBER = "remember"
let APP_PATH_LOGIN_PROOF_USERNAME = "username"
let APP_PATH_LOGIN_PROOF_PASSWORD = "userpassword"
let APP_PATH_LOGIN_PROOF_USERTYPE = "usertype"
let APP_PATH_LOGIN_PROOF_SID = "sid"

let APP_PATH_CHAT_USERINFO = "chat_userinfo.db"

let APP_PATH_LOGINUSER_INFO = "user_information"
let APP_PATH_DEALER_INFO = "dealer_information"

// notification
let APP_NOTIFICATION_LOGIN = "login_succes"
let APP_NOTIFICATION_CHANGE_LOGINUSERINFO = "login_user_info_changed"


// frame
let KM_FRAME_SCREEN_BOUNDS = UIScreen.mainScreen().bounds
let KM_FRAME_SCREEN_WIDTH: CGFloat = KM_FRAME_SCREEN_BOUNDS.size.width
let KM_FRAME_SCREEN_HEIGHT: CGFloat = KM_FRAME_SCREEN_BOUNDS.size.height
let KM_FRAME_VIEW_NAVIGATIONBAR_HEIGHT: CGFloat = 44.0
let KM_FRAME_VIEW_TABBAR_HEIGHT: CGFloat = 49.0
let KM_FRAME_VIEW_STATUSBAR_HEIGHT: CGFloat = 20.0
let KM_FRAME_VIEW_TOOLBAR_HEIGHT: CGFloat = 49.0
