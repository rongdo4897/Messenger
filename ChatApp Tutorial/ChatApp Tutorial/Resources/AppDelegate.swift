//
//  AppDelegate.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 28/05/2021.
//

import UIKit
import Firebase
import Localize_Swift
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        initMainTab()
        initFirebase()
        initLocalize()
        initIQKeyboard()
        
        return true
    }
    
    private func initMainTab() {
        let mainView = RouterType.login.getVc()
        let nav = UINavigationController(rootViewController: mainView)
        nav.isNavigationBarHidden = true
        window?.rootViewController = nav
    }
    
    private func initFirebase() {
        FirebaseApp.configure()
    }
    
    private func initLocalize() {
        // Localize
//        let language = NSLocale.preferredLanguages[0].prefix(2)
//        if language.elementsEqual("vi") {
//            Localize.setCurrentLanguage(String(language))
//        } else {
//            Localize.setCurrentLanguage("en")
//        }
        Localize.setCurrentLanguage("vi")
    }
    
    private func initIQKeyboard() {
        // keyboard
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
    }
}

