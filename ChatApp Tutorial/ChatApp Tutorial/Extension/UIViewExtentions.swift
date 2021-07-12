//
//  UIViewExtentions.swift
//  AITranslate
//
//  Created by Trần An on 5/30/19.
//  Copyright © 2019 MespiTech. All rights reserved.
//

import UIKit
extension UIView {
    // MARK: - Prop
    var width: CGFloat {
        get { return self.frame.size.width }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }

    var height: CGFloat {
        get { return self.frame.size.height }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }

    var size: CGSize {
        get { return self.frame.size }
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }

    var origin: CGPoint {
        get { return self.frame.origin }
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }

    var x: CGFloat {
        get { return self.frame.origin.x }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }

    var y: CGFloat {
        get { return self.frame.origin.y }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }

    var centerX: CGFloat {
        get { return self.center.x }
        set {
            self.center = CGPoint(x: newValue, y: self.center.y)
        }
    }

    var centerY: CGFloat {
        get { return self.center.y }
        set {
            self.center = CGPoint(x: self.center.x, y: newValue)
        }
    }

    var top : CGFloat {
        get { return self.frame.origin.y }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }

    var bottom : CGFloat {
        get { return frame.origin.y + frame.size.height }
        set {
            var frame = self.frame
            frame.origin.y = newValue - self.frame.size.height
            self.frame = frame
        }
    }

    var right : CGFloat {
        get { return self.frame.origin.x + self.frame.size.width }
        set {
            var frame = self.frame
            frame.origin.x = newValue - self.frame.size.width
            self.frame = frame
        }
    }

    var left : CGFloat {
        get { return self.frame.origin.x }
        set {
            var frame = self.frame
            frame.origin.x  = newValue
            self.frame = frame
        }
    }
    func addLineToView(position : LINE_POSITION, color: UIColor = UIColor.lightGray, width: Double = 0.3) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        self.addSubview(lineView)

        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))

        switch position {
        case .LINE_POSITION_TOP:
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
        case .LINE_POSITION_BOTTOM:
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
        }
    }

    func addSubViews(views: [UIView]) {
        views.forEach { (view) in
            self.addSubview(view)
        }
    }

    enum ViewSide {
        case top
        case right
        case bottom
        case left
    }

    func createBorder(side: ViewSide, thickness: CGFloat, color: UIColor, leftOffset: CGFloat = 0, rightOffset: CGFloat = 0, topOffset: CGFloat = 0, bottomOffset: CGFloat = 0) -> CALayer {

        switch side {
        case .top:
            // Bottom Offset Has No Effect
            // Subtract the bottomOffset from the height and the thickness to get our final y position.
            // Add a left offset to our x to get our x position.
            // Minus our rightOffset and negate the leftOffset from the width to get our endpoint for the border.
            return _getOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                    y: 0 + topOffset,
                                                    width: self.frame.size.width - leftOffset - rightOffset,
                                                    height: thickness), color: color)
        case .right:
            // Left Has No Effect
            // Subtract bottomOffset from the height to get our end.
            return _getOneSidedBorder(frame: CGRect(x: self.frame.size.width - thickness - rightOffset,
                                                    y: 0 + topOffset,
                                                    width: thickness,
                                                    height: self.frame.size.height), color: color)
        case .bottom:
            // Top has No Effect
            // Subtract the bottomOffset from the height and the thickness to get our final y position.
            // Add a left offset to our x to get our x position.
            // Minus our rightOffset and negate the leftOffset from the width to get our endpoint for the border.
            return _getOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                    y: self.frame.size.height-thickness-bottomOffset,
                                                    width: self.frame.size.width - leftOffset - rightOffset,
                                                    height: thickness), color: color)
        case .left:
            // Right Has No Effect
            return _getOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                    y: 0 + topOffset,
                                                    width: thickness,
                                                    height: self.frame.size.height - topOffset - bottomOffset), color: color)
        }
    }

    func createViewBackedBorder(side: ViewSide, thickness: CGFloat, color: UIColor, leftOffset: CGFloat = 0, rightOffset: CGFloat = 0, topOffset: CGFloat = 0, bottomOffset: CGFloat = 0) -> UIView {

        switch side {
        case .top:
            let border: UIView = _getViewBackedOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                                            y: 0 + topOffset,
                                                                            width: self.frame.size.width - leftOffset - rightOffset,
                                                                            height: thickness), color: color)
            border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
            return border

        case .right:
            let border: UIView = _getViewBackedOneSidedBorder(frame: CGRect(x: self.frame.size.width-thickness-rightOffset,
                                                                            y: 0 + topOffset, width: thickness,
                                                                            height: self.frame.size.height - topOffset - bottomOffset), color: color)
            border.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
            return border

        case .bottom:
            let border: UIView = _getViewBackedOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                                            y: self.frame.size.height-thickness-bottomOffset,
                                                                            width: self.frame.size.width - leftOffset - rightOffset,
                                                                            height: thickness), color: color)
            border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
            return border

        case .left:
            let border: UIView = _getViewBackedOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                                            y: 0 + topOffset,
                                                                            width: thickness,
                                                                            height: self.frame.size.height - topOffset - bottomOffset), color: color)
            border.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
            return border
        }
    }

    func addBorder(side: ViewSide, thickness: CGFloat, color: UIColor, leftOffset: CGFloat = 0, rightOffset: CGFloat = 0, topOffset: CGFloat = 0, bottomOffset: CGFloat = 0) {

        switch side {
        case .top:
            // Add leftOffset to our X to get start X position.
            // Add topOffset to Y to get start Y position
            // Subtract left offset from width to negate shifting from leftOffset.
            // Subtract rightoffset from width to set end X and Width.
            let border: CALayer = _getOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                                   y: 0 + topOffset,
                                                                   width: self.frame.size.width - leftOffset - rightOffset,
                                                                   height: thickness), color: color)
            self.layer.addSublayer(border)
        case .right:
            // Subtract the rightOffset from our width + thickness to get our final x position.
            // Add topOffset to our y to get our start y position.
            // Subtract topOffset from our height, so our border doesn't extend past teh view.
            // Subtract bottomOffset from the height to get our end.
            let border: CALayer = _getOneSidedBorder(frame: CGRect(x: self.frame.size.width-thickness-rightOffset,
                                                                   y: 0 + topOffset, width: thickness,
                                                                   height: self.frame.size.height - topOffset - bottomOffset), color: color)
            self.layer.addSublayer(border)
        case .bottom:
            // Subtract the bottomOffset from the height and the thickness to get our final y position.
            // Add a left offset to our x to get our x position.
            // Minus our rightOffset and negate the leftOffset from the width to get our endpoint for the border.
            let border: CALayer = _getOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                                   y: self.frame.size.height-thickness-bottomOffset,
                                                                   width: self.frame.size.width - leftOffset - rightOffset, height: thickness), color: color)
            self.layer.addSublayer(border)
        case .left:
            let border: CALayer = _getOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                                   y: 0 + topOffset,
                                                                   width: thickness,
                                                                   height: self.frame.size.height - topOffset - bottomOffset), color: color)
            self.layer.addSublayer(border)
        }
    }

    func addViewBackedBorder(side: ViewSide, thickness: CGFloat, color: UIColor, leftOffset: CGFloat = 0, rightOffset: CGFloat = 0, topOffset: CGFloat = 0, bottomOffset: CGFloat = 0) {

        switch side {
        case .top:
            let border: UIView = _getViewBackedOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                                            y: 0 + topOffset,
                                                                            width: self.frame.size.width - leftOffset - rightOffset,
                                                                            height: thickness), color: color)
            border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
            self.addSubview(border)

        case .right:
            let border: UIView = _getViewBackedOneSidedBorder(frame: CGRect(x: self.frame.size.width-thickness-rightOffset,
                                                                            y: 0 + topOffset, width: thickness,
                                                                            height: self.frame.size.height - topOffset - bottomOffset), color: color)
            border.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
            self.addSubview(border)

        case .bottom:
            let border: UIView = _getViewBackedOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                                            y: self.frame.size.height-thickness-bottomOffset,
                                                                            width: self.frame.size.width - leftOffset - rightOffset,
                                                                            height: thickness), color: color)
            border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
            self.addSubview(border)
        case .left:
            let border: UIView = _getViewBackedOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                                            y: 0 + topOffset,
                                                                            width: thickness,
                                                                            height: self.frame.size.height - topOffset - bottomOffset), color: color)
            border.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
            self.addSubview(border)
        }
    }

    //////////
    // Private: Our methods call these to add their borders.
    //////////

    fileprivate func _getOneSidedBorder(frame: CGRect, color: UIColor) -> CALayer {
        let border:CALayer = CALayer()
        border.frame = frame
        border.backgroundColor = color.cgColor
        return border
    }

    fileprivate func _getViewBackedOneSidedBorder(frame: CGRect, color: UIColor) -> UIView {
        let border:UIView = UIView.init(frame: frame)
        border.backgroundColor = color
        return border
    }

}
enum LINE_POSITION {
    case LINE_POSITION_TOP
    case LINE_POSITION_BOTTOM
}

extension UIImageView {
    func changeTintColor(color : UIColor) {
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
}

extension UIView {
    func addShadow() {
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 2
        self.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
    }

    func addShadow(opacity: Float, radius: CGFloat) {
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius).cgPath
        self.layer.shadowOffset = CGSize(width: 0.2, height: 0.2)
        self.layer.shadowOpacity = opacity
        self.layer.shadowColor = UIColor.gray.cgColor
        self.backgroundColor = .white
    }

    func addShadow(radius: CGFloat) {
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
    }

    func addShadow(color: UIColor) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 2.0
        self.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
    }

    func addShadowToBottom() {
        let shadowPath = UIBezierPath()
        shadowPath.move(to: CGPoint(x: self.bounds.origin.x, y: self.frame.size.height))
        shadowPath.addLine(to: CGPoint(x: self.bounds.width / 2, y: self.bounds.height + 7.0))
        shadowPath.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height))
        shadowPath.close()

        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 1
        self.layer.masksToBounds = false
        self.layer.shadowPath = shadowPath.cgPath
        self.layer.shadowRadius = 5
    }

    func addShadow(shadowRadius: CGFloat) {
        layer.cornerRadius = 20
        clipsToBounds = false

        layer.masksToBounds = false
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.14).cgColor
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = 1

        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }

    func addShadow(color: UIColor, radius: CGFloat, opacity: Float) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = .zero
        layer.shadowRadius = radius
    }

    func addPartialRadious(corners: UIRectCorner, radius: CGSize) {
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.frame
        rectShape.position = self.center
        rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: radius).cgPath
        rectShape.borderWidth = 0.3
        rectShape.borderColor = #colorLiteral(red: 0.9750739932, green: 0.9750967622, blue: 0.9750844836, alpha: 1)
        self.layer.mask = rectShape
    }

    func roundCorners(radius: CGFloat, width: CGFloat, color: UIColor) {
        layer.cornerRadius = radius
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
           let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
           let mask = CAShapeLayer()
           mask.path = path.cgPath
           layer.mask = mask
       }

    func roundCorners2(cornerRadius: Double) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
}

extension UITextField {
    func isInvalid() -> Bool {
        guard let str = self.text else {
            return false
        }

        if str.isEmpty || str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }

        return true
    }

    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }

    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
extension UIView {
    @discardableResult
    func applyGradient(colours: [UIColor], radius: CGFloat?) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil, radius: radius)
    }

    @discardableResult
    func applyGradient(colours: [UIColor], locations: [NSNumber]?, radius: CGFloat?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.cornerRadius = radius ?? 0
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
}

// gradients
extension CALayer {
    func insertGradientLayer(colours: [UIColor], locations: [NSNumber]?) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.insertSublayer(gradient, at: 0)
    }
}

extension UIImageView {
    func backgroundGradient(colours: [UIColor], locations: [NSNumber]?) {
        let myImage = UIImageView(frame: self.bounds)
        myImage.image = self.image!
        myImage.contentMode = self.contentMode
        myImage.backgroundColor = nil
        self.layer.insertGradientLayer(colours: colours, locations: locations)
        self.addSubview(myImage)
    }
}

extension UILabel {
    func backgroundGradient(colours: [UIColor], locations: [NSNumber]?) {
        let label = UILabel(frame: self.bounds)
        label.text = self.text
        self.layer.insertGradientLayer(colours: colours, locations: locations)
        self.addSubview(label)
    }
}

extension UIImage {
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!

        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!

        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)

        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
}

extension UIButton {
    func changeImageColor(image: UIImage, color: UIColor) {
        let myImage = image.withRenderingMode(.alwaysTemplate)
        self.setImage(myImage, for: .normal)
        self.tintColor = color
    }
}

private var KeyMaxLength: Int = 0

    extension UITextField {
        @IBInspectable var placeHolderColor: UIColor? {
            get {
                return self.placeHolderColor
            }
            set {
                self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
            }
        }
        @IBInspectable
            var cornerRadius: CGFloat {
                get {
                    return layer.cornerRadius
                }
                set {
                    layer.cornerRadius = newValue
                    layer.masksToBounds = newValue > 0
                }
            }

            @IBInspectable
            var borderWidth: CGFloat {
                get {
                    return layer.borderWidth
                }
                set {
                    layer.borderWidth = newValue
                }
            }

            @IBInspectable
            var borderColor: UIColor? {
                get {
                    let color = UIColor.init(cgColor: layer.borderColor!)
                    return color
                }
                set {
                    layer.borderColor = newValue?.cgColor
                }
            }

        @IBInspectable var maxLength: Int {
                get {
                    if let length = objc_getAssociatedObject(self, &KeyMaxLength) as? Int {
                        return length
                    } else {
                        return Int.max
                    }
                }
                set {
                    objc_setAssociatedObject(self, &KeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
                    addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
                }
            }

            @objc func checkMaxLength(textField: UITextField) {
                guard let prospectiveText = self.text,
                    prospectiveText.count > maxLength
                    else {
                        return
                }

                let selection = selectedTextRange
                let maxCharIndex = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
                text = prospectiveText.substring(to: maxCharIndex)
                selectedTextRange = selection
            }

        func addBottomBorder() {
                let bottomLine = CALayer()
                bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
                bottomLine.backgroundColor = UIColor.white.cgColor
                borderStyle = .none
                layer.addSublayer(bottomLine)
            }
        func addBottomBorder1() {
                let bottomLine = CALayer()
                bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
                bottomLine.backgroundColor = UIColor.black.cgColor
                borderStyle = .none
                layer.addSublayer(bottomLine)
            }

    }
