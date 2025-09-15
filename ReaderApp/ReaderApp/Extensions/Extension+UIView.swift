//
//  Extension+UIView.swift
//  ReaderApp
//
//  Created by Mohanaprbhu on 12/09/25.
//

import UIKit

// MARK: - NSLayoutDimension
extension NSLayoutDimension {
    struct Dimension {
        let constraint: NSLayoutDimension
        let constant: CGFloat?
        let multiplier: CGFloat
    }
    
    @discardableResult
    static func == (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
        let constraint = lhs.constraint(equalToConstant: rhs)
        constraint.isActive = true
        (constraint.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        return constraint
    }
    
    @discardableResult
    static func <= (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
        let constraint = lhs.constraint(lessThanOrEqualToConstant: rhs)
        constraint.isActive = true
        (constraint.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        return constraint
    }
}

// MARK: - NSLayoutXAxisAnchor

extension NSLayoutXAxisAnchor {
    struct Constraint {
        let constraint: NSLayoutXAxisAnchor
        let constant: CGFloat
    }
    
    @discardableResult
    static func == (lhs: NSLayoutXAxisAnchor, rhs: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
        let constraint = lhs.constraint(equalTo: rhs)
        constraint.isActive = true
        (constraint.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        return constraint
    }
    
    @discardableResult
    static func == (lhs: NSLayoutXAxisAnchor, rhs: Constraint) -> NSLayoutConstraint {
        let constraint = lhs.constraint(equalTo: rhs.constraint, constant: rhs.constant)
        constraint.isActive = true
        (constraint.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        return constraint
    }
    
    @discardableResult
    static func + (lhs: NSLayoutXAxisAnchor, rhs: CGFloat) -> Constraint {
        return Constraint(constraint: lhs, constant: rhs)
    }
    
    @discardableResult
    static func + (lhs: NSLayoutXAxisAnchor, rhs: Double) -> Constraint {
        return lhs + CGFloat(rhs)
    }
    
    @discardableResult
    static func - (lhs: NSLayoutXAxisAnchor, rhs: CGFloat) -> Constraint {
        return Constraint(constraint: lhs, constant: -rhs)
    }
}

// MARK: - NSLayoutYAxisAnchor

extension NSLayoutYAxisAnchor {
    struct Constraint {
        let constraint: NSLayoutYAxisAnchor
        let value: CGFloat
    }
    
    @discardableResult
    static func == (lhs: NSLayoutYAxisAnchor, rhs: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
        let constraint = lhs.constraint(equalTo: rhs)
        constraint.isActive = true
        (constraint.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        return constraint
    }
    
    @discardableResult
    static func == (lhs: NSLayoutYAxisAnchor, rhs: Constraint) -> NSLayoutConstraint {
        let constraint = lhs.constraint(equalTo: rhs.constraint, constant: rhs.value)
        constraint.isActive = true
        (constraint.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        return constraint
    }
    
    @discardableResult
    static func + (lhs: NSLayoutYAxisAnchor, rhs: CGFloat) -> Constraint {
        return Constraint(constraint: lhs, value: rhs)
    }
    
    @discardableResult
    static func - (lhs: NSLayoutYAxisAnchor, rhs: CGFloat) -> Constraint {
        return Constraint(constraint: lhs, value: -rhs)
    }
}

// MARK: - LayoutCenterAnchor

struct LayoutCenterAnchor {
    let centerX: NSLayoutXAxisAnchor
    let centerY: NSLayoutYAxisAnchor
    
    @discardableResult
    static func == (lhs: LayoutCenterAnchor, rhs: LayoutCenterAnchor) -> [NSLayoutConstraint] {
        let centerX = lhs.centerX == rhs.centerX
        let centerY = lhs.centerY == rhs.centerY
        return [centerX, centerY]
    }
}

// MARK: - LayoutEdgesAnchor

struct LayoutEdgesAnchor {
    let top: NSLayoutYAxisAnchor
    let trailing: NSLayoutXAxisAnchor
    let bottom: NSLayoutYAxisAnchor
    let leading: NSLayoutXAxisAnchor
    
    struct Constraint {
        let edges: LayoutEdgesAnchor
        let insets: UIEdgeInsets
    }
    
    @discardableResult
    static func == (lhs: LayoutEdgesAnchor, rhs: LayoutEdgesAnchor) -> [NSLayoutConstraint] {
        let top = lhs.top == rhs.top
        let trailing = lhs.trailing == rhs.trailing
        let bottom = lhs.bottom == rhs.bottom
        let leading = lhs.leading == rhs.leading
        return [top, trailing, bottom, leading]
    }
}

struct LayoutEdgesAnchorWithOutBottom {
    let top: NSLayoutYAxisAnchor
    let trailing: NSLayoutXAxisAnchor
    let leading: NSLayoutXAxisAnchor

    struct Constraint {
        let edges: LayoutEdgesAnchorWithOutBottom
        let insets: UIEdgeInsets
    }

    @discardableResult
    static func == (lhs: LayoutEdgesAnchorWithOutBottom, rhs: LayoutEdgesAnchorWithOutBottom) -> [NSLayoutConstraint] {
        let top = lhs.top == rhs.top
        let trailing = lhs.trailing == rhs.trailing
        let leading = lhs.leading == rhs.leading
        return [top, trailing, leading]
    }
}

struct LayoutEdgesAnchorWithOutTop {
    let bottom: NSLayoutYAxisAnchor
    let trailing: NSLayoutXAxisAnchor
    let leading: NSLayoutXAxisAnchor

    struct Constraint {
        let edges: LayoutEdgesAnchorWithOutTop
        let insets: UIEdgeInsets
    }

    @discardableResult
    static func == (lhs: LayoutEdgesAnchorWithOutTop, rhs: LayoutEdgesAnchorWithOutTop) -> [NSLayoutConstraint] {
        let bottom = lhs.bottom == rhs.bottom
        let trailing = lhs.trailing == rhs.trailing
        let leading = lhs.leading == rhs.leading
        return [bottom, trailing, leading]
    }
}

// MARK: - UIView

extension UIView {
    
    var leading: NSLayoutXAxisAnchor {
        return leadingAnchor
    }
    
    var trailing: NSLayoutXAxisAnchor {
        return trailingAnchor
    }
    
    var top: NSLayoutYAxisAnchor {
        return topAnchor
    }
    
    var bottom: NSLayoutYAxisAnchor {
        return bottomAnchor
    }
    
    var width: NSLayoutDimension {
        return widthAnchor
    }
    
    var height: NSLayoutDimension {
        return heightAnchor
    }
    
    var centerX: NSLayoutXAxisAnchor {
        return centerXAnchor
    }
    
    var centerY: NSLayoutYAxisAnchor {
        return centerYAnchor
    }
    
    var mid: LayoutCenterAnchor {
        return LayoutCenterAnchor(centerX: centerX, centerY: centerY)
    }
    
    var edges: LayoutEdgesAnchor {
        return LayoutEdgesAnchor(top: top, trailing: trailing, bottom: bottom, leading: leading)
    }

    var exceptTop: LayoutEdgesAnchorWithOutTop {
        return LayoutEdgesAnchorWithOutTop(bottom: bottom, trailing: trailing, leading: leading)
    }

    var exceptBottom: LayoutEdgesAnchorWithOutBottom {
        return LayoutEdgesAnchorWithOutBottom(top: top, trailing: trailing, leading: leading)
    }
}


@IBDesignable
extension UIView {
    @IBInspectable var borderColor: UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var viewCornerRadius: CGFloat {
        set {
            layer.cornerRadius = isCircle ? min(bounds.size.height, bounds.size.width) / 2 : newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var isCircle: Bool {
        get {
            return min(bounds.size.height, bounds.size.width) / 2 == viewCornerRadius
        }
        set {
            viewCornerRadius = newValue ? min(bounds.size.height, bounds.size.width) / 2 : viewCornerRadius
        }
    }
    
    @IBInspectable var shadowColor: UIColor {
        set {
            layer.shadowColor = newValue.cgColor
        }
        get {
            guard let color = layer.shadowColor else {
                return .clear
            }
            return UIColor(cgColor: color)
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        set {
            layer.shadowOpacity = newValue
        }
        get {
            return layer.shadowOpacity
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        set {
            layer.shadowOffset = newValue
        }
        get {
            return layer.shadowOffset
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        set {
            layer.shadowRadius = newValue
        }
        get {
            return layer.shadowRadius
        }
    }
    
    @IBInspectable var maskBounds: Bool {
        set {
            layer.masksToBounds = newValue
        }
        get {
            return layer.masksToBounds
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func addSubviews(with views: [UIView]) {
        views.forEach { (view) in
            addSubview(view)
        }
    }

    func bringSubviewsToFront(with views: [UIView]) {
        views.forEach { (view) in
            bringSubviewToFront(view)
        }
    }
}

extension UIStackView {
    func addArrangedSubviews(_ views: [UIView]) {
        for view in views {
            addArrangedSubview(view)
        }
    }
}

extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}

extension CGFloat{
    static func ratioHeightBasedOniPhoneX(_ val: CGFloat) -> CGFloat{
        return UIScreen.main.bounds.height * (val/812)
    }
    
    static func ratioWidthBasedOniPhoneX(_ val: CGFloat) -> CGFloat{
        return UIScreen.main.bounds.width * (val/375)
    }
}
