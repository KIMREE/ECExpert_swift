//
//  VideoHtml.swift
//  ECExpert
//
//  Created by Fran on 15/9/8.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import Foundation

let KimreeBaseUrl = "http://www.kimree.com.cn/app/"
let KimreeVideo = "kimree://video//"

// 控制webView加载html的边框
let webPadding: CGFloat = 10
let css = "<style type='text/css'>body{padding: \(webPadding)px;margin: 0px;}</style>"

let YouKuClientId = "519e2ea76b2988cc"

let YouKuApi = "https://openapi.youku.com/v2/videos/show_basic.json" // params: client_id, video_url

let YouKuIdentifier = "youku.com"
let YouKuPlayerReady = "kimree://PlayerReady"
let YouKuPlayStart = "kimree://PlayStart"
let YouKuPlayEnd = "kimree://PlayEnd"

let YouKu_html = css + "<div id='youkuplayer' style='width:%f px;height:%f px'></div> <script type='text/javascript' src='http://player.youku.com/jsapi'> player = new YKU.Player('youkuplayer',{ styleid: '0', client_id: '519e2ea76b2988cc', vid: '%@', embsig: 'VERSION_TIMESTAMP_SIGNATURE', autoplay: true, show_related: true, events:{onPlayerReady: function(){ window.location.href = '\(YouKuPlayerReady)' },onPlayStart: function(){ window.location.href = '\(YouKuPlayStart)' },onPlayEnd: function(){ window.location.href = '\(YouKuPlayEnd)' }}});</script>"




let TencentGetVideoApi = "http://vv.video.qq.com/geturl" // 获取视频播放地址 params: vid, otype, platform, ran
let TencentGetInfoApi = "http://vv.video.qq.com/getinfo" //http://vv.video.qq.com/getinfo?vids=s0017ec58ml&platform=2&otype=json

let TencentThumbnail = "http://shp.qpic.cn/qqvideo_ori/0/%@_496_280/0" // 缩略图  %@ 指的是vid

let TencentIdentifier = "qq.com"

let TencentBoke = "boke"  // 最后文件名称是 vid
let TencentPage = "page"  // 同boke
let TencentCover = "cover"   // 带vid参数的取vid，  不带vid参数的，取videos[0]

let TencentPlayerBeginFullScreen = "kimree://video-beginfullscreen"
let TencentPlayerEndFullScreen = "kimree://video-endfullscreen"

let Tencent_html = css + "<video controls autoplay width='%f px' height='%f px;' style='padding: 0px; background-color: #000000; margin: 0px;' poster='%@' name='media'><source src='%@'></video>"


//            playerView.loadHTMLString("<video controls autoplay style='width: 100px; height: 100px;' name='media'><source src='http://119.147.83.14/vhot2.qqvideo.tc.qq.com/b016556e0vc.mp4?vkey=719552590653485CA69C9D198BC9D693360C72386A45E8FD867C2F6157A49EBC5FF0A5BC7C261F1D19EC4F2460AD5001ACC6E4DA949E1D6A3BD6C0171A014C3DCE5CD808486A1042A8EC1B06982C8377EAE4D4A1935A40D2&amp;br=60&amp;platform=2&amp;fmt=msd&amp;sdtfrom=v3010&amp;type=mp4' ></video>", baseURL: nil)




