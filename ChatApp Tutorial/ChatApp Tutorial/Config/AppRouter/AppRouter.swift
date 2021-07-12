//
//  AppRouter.swift
//  IVM
//
//  Created by an.trantuan on 7/9/20.
//  Copyright © 2020 an.trantuan. All rights reserved.
//

import UIKit

enum RouterType {
    case login
    case tabbar
    case chat
    case channel
    case user
    case setting
    case profile
    case status
    case userDetail
}

extension RouterType {
    func getVc() -> UIViewController {
        switch self {
        case .login:
            let vc = UIStoryboard(name: Constants.login, bundle: nil).instantiateViewController(ofType: LoginViewController.self)
            return vc
        case .tabbar:
            let vc = UIStoryboard(name: Constants.tabbar, bundle: nil).instantiateViewController(ofType: TabbarViewController.self)
            return vc
        case .chat:
            let vc = UIStoryboard(name: Constants.chat, bundle: nil).instantiateViewController(ofType: ChatViewController.self)
            return vc
        case .channel:
            let vc = UIStoryboard(name: Constants.channel, bundle: nil).instantiateViewController(ofType: ChannelViewController.self)
            return vc
        case .user:
            let vc = UIStoryboard(name: Constants.user, bundle: nil).instantiateViewController(ofType: UserViewController.self)
            return vc
        case .setting:
            let vc = UIStoryboard(name: Constants.setting, bundle: nil).instantiateViewController(ofType: SettingViewController.self)
            return vc
        case .profile:
            let vc = UIStoryboard(name: Constants.setting, bundle: nil).instantiateViewController(ofType: ProfileViewController.self)
            return vc
        case .status:
            let vc = UIStoryboard(name: Constants.setting, bundle: nil).instantiateViewController(ofType: StatusViewController.self)
            return vc
        case .userDetail:
            let vc = UIStoryboard(name: Constants.user, bundle: nil).instantiateViewController(ofType: UserDetailViewController.self)
            return vc
        }
    }
}
