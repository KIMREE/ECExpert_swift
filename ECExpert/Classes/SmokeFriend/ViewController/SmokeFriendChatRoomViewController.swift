//
//  SmokeFriendChatRoomViewController.swift
//  ECExpert
//
//  Created by Fran on 15/7/30.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

/**
*  烟友聊天室
*/
class SmokeFriendChatRoomViewController: RCConversationViewController {
    
    deinit{
        KMLog("SmokeFriendChatRoomViewController deinit")
    }
    
    override func viewDidLoad() {
        /**
        * 当会话为聊天室时获取的历史信息数目，默认值为10，在viewDidLoad之前设置
        * -1表示不获取，0表示系统默认数目(现在默认值为10条)，正数表示获取的具体数目，最大值为50
        */
        self.defaultHistoryMessageCountOfChatRoom = 50
        
        /**
        *  设置头像样式,请在viewDidLoad之前调用
        *
        *  @param avatarStyle avatarStyle
        */
        self.setMessageAvatarStyle(RCUserAvatarStyle._USER_AVATAR_CYCLE)
        
        super.viewDidLoad()
        
        self.enableSaveNewPhotoToLocalSystem = true
        self.displayUserNameInCell = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "goback"), style: UIBarButtonItemStyle.Plain, target: self, action: "goback")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.conversationMessageCollectionView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.conversationMessageCollectionView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func goback(){
        self.view.endEditing(true)
        self.navigationController!.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    // MARK: 点击聊天用户头像
    override func didTapCellPortrait(userId: String!) {

        // 更新点击用户信息
        KMUserInfoDataSource.shareDataSource().getNewestChatUserInfo(userId, completion: { (userInfoDic: NSDictionary, valueChanged: Bool) -> Void in
            if valueChanged{
                RCIM.sharedRCIM().refreshUserInfoCache(RCUserInfo(userId: userId, name: userInfoDic["name"] as! String, portrait: userInfoDic["portraitUri"] as! String), withUserId: userId)
            }
        })
    }
   
}
