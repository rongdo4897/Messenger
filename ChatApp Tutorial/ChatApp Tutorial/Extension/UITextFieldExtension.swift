//
//  UITextFieldExtension.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 16/06/2021.
//

import Foundation
import UIKit

protocol DesignableTextFieldDelegate: UITextFieldDelegate {
    func textFieldIconClicked(btn:UIButton)
}

@IBDesignable
class DesignableTextField: UITextField {

    //Delegate when image/icon is tapped.
    private var myDelegate: DesignableTextFieldDelegate? {
        get { return delegate as? DesignableTextFieldDelegate }
    }

    @objc func buttonClicked(btn: UIButton){
        self.myDelegate?.textFieldIconClicked(btn: btn)
    }

    //Padding images on left
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += padding
        return textRect
    }

    //Padding images on Right
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.rightViewRect(forBounds: bounds)
        textRect.origin.x -= padding
        return textRect
    }

    @IBInspectable var padding: CGFloat = 0
    @IBInspectable var leadingImage: UIImage? { didSet { updateView() }}
    @IBInspectable var color: UIColor = UIColor.lightGray { didSet { updateView() }}
    @IBInspectable var imageColor: UIColor = UIColor.colorFromHexString(hex: "3EB2FF") { didSet { updateView() }}
    @IBInspectable var rtl: Bool = false { didSet { updateView() }}

    func updateView() {
        rightViewMode = .never
        rightView = nil
        leftViewMode = .never
        leftView = nil

        if let image = leadingImage {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 10, height: 10)

            let tintedImage = image.withRenderingMode(.alwaysTemplate)
            button.setImage(tintedImage, for: .normal)
            button.tintColor = imageColor

            button.setTitleColor(UIColor.clear, for: .normal)
            button.addTarget(self, action: #selector(buttonClicked(btn:)), for: .touchDown)
            button.isUserInteractionEnabled = true

            if rtl {
                rightViewMode = .always
                rightView = button
            } else {
                leftViewMode = .always
                leftView = button
            }
        }

        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[.foregroundColor: color])
    }
}
