//
//  KIMreeAPI.swift
//  ECExpert
//
//  Created by Fran on 15/8/19.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

// API_URL
let APP_URL = "https://itunes.apple.com/lookup?id=948643406"
let APP_URL_ITUNES_COMMENT = "https://itunes.apple.com/app/id948643406"
let APP_URL_ITUNES = "https://itunes.apple.com/us/app/dian-zi-yan-zhuan-jia/id948643406?l=zh&ls=1&mt=8"

let APP_URL_LOGIN = "http://www.kimree.com.cn/app/?action=login" // 登录
let APP_URL_LOGOUT = "http://www.kimree.com.cn/app/?action=logout" // 登出
let APP_URL_REGISTER = "http://www.kimree.com.cn/app/?action=joinuser" // 注册
let APP_URL_LOGIN_USERINFO = "http://www.kimree.com.cn/app/?action=getuserinfo" // 获取登录用户信息

let APP_URL_CHECKVIP = "http://www.kimree.com.cn/app/?action=checkvip"  // 根据用户id和会员卡号确定用户合法性
let APP_URL_TRADE_INPUT = "http://www.kimree.com.cn/app/?action=typetrade"  // 录入交易
let APP_URL_SCAN_BAR_CODE = "http://www.kimree.com.cn/app/scancode.php?"  // 扫描条形码

let APP_URL_NEWS = "http://m.ecig100.com/" // 咨询
let APP_URL_KIMREE = "http://m.kimree.com.cn/" // 吉瑞电子烟 主页  不能使用 http://www.kimree.com.cn 这个

let APP_URL_DEALER = "http://www.ecig100.com/api/?action=getDealer" //获取经销商及烟酒商信息

let APP_URL_TRADE_RECORD = "http://www.kimree.com.cn/app/?action=selecttrade" // 查看交易记录
let APP_URL_TRADE_RECORD_DETAIL = "http://www.kimree.com.cn/app/?action=tradeinfo"  // 交易记录详情

let APP_URL_FEEDBACK = "http://www.ecigarfan.com/api/api.php?action=sendask"

let APP_URL_EDITUSERINFO = "http://www.kimree.com.cn/app/?action=moduser&modway=moduserinfo"       //修改个人信息
let APP_URL_CHANGEPASSWORD =  "http://www.kimree.com.cn/app/?action=moduser&modway=modpassword"   //更改密码
let APP_URL_UPLOADUSERHEADER = "http://www.kimree.com.cn/app/?action=moduser&modway=moduserimage"  //修改用户图片