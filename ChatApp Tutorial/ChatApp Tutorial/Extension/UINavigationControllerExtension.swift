//
//  UINavigationControllerExtension.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 29/07/2021.
//

import Foundation
import UIKit

extension UINavigationController {
    func getViewController<T: UIViewController>(of type: T.Type) -> UIViewController? {
        return self.viewControllers.first(where: { $0 is T })
    }

    func popToViewController<T: UIViewController>(of type: T.Type, animated: Bool) {
        guard let viewController = self.getViewController(of: type) else { return }
        self.popToViewController(viewController, animated: animated)
    }
}
