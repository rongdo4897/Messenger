//
//  TabbarViewController.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 10/06/2021.
//

import UIKit
import RAMAnimatedTabBarController

class TabbarViewController: RAMAnimatedTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        createTabbar()
    }
    
    private func createTabbar() {
        let chat = RouterType.chat.getVc()
        let channel = RouterType.channel.getVc()
        let channelNav = UINavigationController(rootViewController: channel)
        channelNav.isNavigationBarHidden = true
        let user = RouterType.user.getVc()
        let setting = RouterType.setting.getVc()
        
        let animation = RAMBounceAnimation()
        
        let chatItem = RAMAnimatedTabBarItem(title: "Chats".localized(), image: #imageLiteral(resourceName: "ic_chat"), tag: 0)
        chatItem.animation = animation
        let channelItem = RAMAnimatedTabBarItem(title: "Channels".localized(), image: #imageLiteral(resourceName: "ic_channel"), tag: 1)
        channelItem.animation = animation
        let userItem = RAMAnimatedTabBarItem(title: "Users".localized(), image: #imageLiteral(resourceName: "ic_users"), tag: 2)
        userItem.animation = animation
        let settingItem = RAMAnimatedTabBarItem(title: "Settings".localized(), image: #imageLiteral(resourceName: "ic_settings"), tag: 3)
        settingItem.animation = RAMRotationAnimation()
        
        chat.tabBarItem = chatItem
        channel.tabBarItem = channelItem
        user.tabBarItem = userItem
        setting.tabBarItem = settingItem
        
        self.viewControllers = [chat, channelNav, user, setting]
    }
}
