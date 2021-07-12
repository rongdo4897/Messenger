//
//  AlertUntil.swift
//  IVM
//
//  Created by an.trantuan on 7/7/20.
//  Copyright © 2020 an.trantuan. All rights reserved.
//

import Foundation
import UIKit

class AlertUtil {
    class func showAlertSave(from viewController: UIViewController, with title: String, message: String, completionYes: (@escaping (UIAlertAction) -> Void), completionNo: (@escaping (UIAlertAction) -> Void)) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "YES".localized(), style: .default, handler: completionYes)
            alert.addAction(doneAction)
            let cancelAction = UIAlertAction(title: "NO".localized(), style: .default, handler: completionNo)
            alert.addAction(cancelAction)

            viewController.present(alert, animated: true, completion: nil)
        }
    }

    class func showAlert(from viewController: UIViewController, with title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "OK".localized(), style: .cancel, handler: nil)
            alert.addAction(doneAction)
            viewController.present(alert, animated: true, completion: nil)
        }
    }

    class func showAlert(from viewController: UIViewController, with title: String, message: String,  completion : (@escaping (UIAlertAction) -> Void)) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "OK".localized(), style: .cancel, handler: completion)
            alert.addAction(doneAction)
            viewController.present(alert, animated: true, completion: nil)
        }
    }

    class func showAlertConfirm(from viewController: UIViewController, with title: String, message: String,  completion : (@escaping (UIAlertAction) -> Void)) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "YES".localized(), style: .default, handler: completion)
            alert.addAction(doneAction)
            let cancelAction = UIAlertAction(title: "NO".localized(), style: .destructive, handler: nil)
            alert.addAction(cancelAction)

            viewController.present(alert, animated: true, completion: nil)
        }
    }

    class func logout(from viewController: UIViewController, with title: String, message: String,  completion : (@escaping (UIAlertAction) -> Void)) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "OK".localized(), style: .default, handler: completion)
            alert.addAction(doneAction)
            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .destructive, handler: nil)
            alert.addAction(cancelAction)

            viewController.present(alert, animated: true, completion: nil)
        }
    }

    class func showImagePicker(from viewController: UIViewController, with title: String, message: String, completionCamera: (@escaping (UIAlertAction) -> Void), completionPicture: (@escaping (UIAlertAction) -> Void)) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            let presentCamera = UIAlertAction(title: "Take Photo".localized(), style: .default, handler: completionCamera)
            alert.addAction(presentCamera)
            let presentPicture = UIAlertAction(title: "Choose Photo".localized(), style: .default, handler: completionPicture)
            alert.addAction(presentPicture)
            let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
            alert.addAction(cancel)
            viewController.present(alert, animated: true, completion: nil)
        }
    }
}
