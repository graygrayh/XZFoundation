//
//  UIViewExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/5.
//  Copyright © 2020 xzh. All rights reserved.
//

import UIKit

// MARK: - Property
public extension UIView {
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            guard let color = newValue else {
                layer.borderColor = nil
                return
            }
            // Fix React-Native conflict issue
            guard String(describing: type(of: color)) != "__NSCFType" else { return }
            layer.borderColor = color.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.masksToBounds = true
            layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100)
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get {
            guard let color = layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
}


// MARK: - Load
public extension XZ where Base: UIView {
 
    /// Load view from nib
    /// - Returns: optional UIView (if applicable).
    class func loadFromNib<T>(bundle: Bundle? = nil) -> T {
        let name = String(describing: T.self)
        let nib = UINib(nibName: name, bundle: bundle ?? Bundle.main)
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? T else {
            fatalError("The nib \(String(describing: nib)) expected its root view to be of type \(self)")
        }
        return view
    }
    
    func loadFromNib<T: UIView>() -> T? {
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {
            // xib not loaded, or its top view is of the wrong type
            return nil
        }
        return contentView
    }
    
    var screenshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(base.layer.frame.size, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        base.layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Remove all subviews in view.
    func removeAllSubviews() {
        base.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    /// Remove all gesture recognizers from view.
    func removeAllGestureRecognizers() {
        base.gestureRecognizers?.forEach(base.removeGestureRecognizer)
    }
    
    /// Recursively find the first responder.
    func firstResponder() -> UIView? {
        var views = [UIView](arrayLiteral: base)
        var index = 0
        repeat {
            let view = views[index]
            if view.isFirstResponder {
                return view
            }
            views.append(contentsOf: view.subviews)
            index += 1
        } while index < views.count
        return nil
    }
    
    /// Add shadow to view.
    func addShadow(ofColor color: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1), radius: CGFloat = 5, offset: CGSize = .zero, opacity: Float = 0.15) {
        base.layer.shadowColor = color.cgColor
        base.layer.shadowOffset = offset
        base.layer.shadowRadius = radius
        base.layer.shadowOpacity = opacity
        base.layer.masksToBounds = false
    }
    
    var size: CGSize {
        get {
            return base.frame.size
        }
        set {
            width = newValue.width
            height = newValue.height
        }
    }
    
    var width: CGFloat {
        get {
            return base.frame.size.width
        }
        set {
            base.frame.size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            return base.frame.size.height
        }
        set {
            base.frame.size.height = newValue
        }
    }
    
    var x: CGFloat {
        get {
            return base.frame.origin.x
        }
        set {
            base.frame.origin.x = newValue
        }
    }
    
    var y: CGFloat {
        get {
            return base.frame.origin.y
        }
        set {
            base.frame.origin.y = newValue
        }
    }

}

// MARK: - Draw
public extension XZ where Base: UIView {
    /// 添加渐变蒙层
    /// - Parameters:
    ///   - colors: 颜色值
    ///   - locations: 位置
    ///   - startPoint: 开始点
    ///   - endPoint: 结束点
    func addGradientMask(colors: [CGColor],
                         locations: [NSNumber] = [0, 1],
                         startPoint: CGPoint = CGPoint(x: 0.5, y: 0),
                         endPoint: CGPoint = CGPoint(x: 1, y: 1)) {
        if colors.count < 2 {
            fatalError("colors数组至少需要两个颜色值")
        }
        let maskLayer = CAGradientLayer()
        maskLayer.colors = colors
        maskLayer.locations = locations
        maskLayer.frame = base.bounds
        maskLayer.startPoint = startPoint
        maskLayer.endPoint = endPoint
        base.layer.addSublayer(maskLayer)
    }
    
    /// Set some or all corners radiuses of view.
    ///
    /// - Parameters:
    ///   - corners: array of corners to change (example: [.bottomLeft, .topRight]).
    ///   - radius: radius for selected corners.
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(
            roundedRect: base.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        base.layer.mask = shape
    }
    
    @discardableResult
    func withLineDashBorder(lineColor: UIColor = UIColor.lightGray) -> CAShapeLayer {
        let borderLayer = CAShapeLayer()
        borderLayer.bounds = base.bounds
        borderLayer.position = CGPoint(x: base.bounds.midX , y: base.bounds.midY)
        borderLayer.path = UIBezierPath(roundedRect: borderLayer.bounds, cornerRadius: 2).cgPath
        borderLayer.lineWidth = 1///UIScreen.main.scale
        borderLayer.lineDashPattern = [6,4]
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = lineColor.cgColor
        base.layer.addSublayer(borderLayer)
        return borderLayer
    }
    
    func addGradientBackgroudColor(colors:[UIColor]?=nil) {
        let gradient = CAGradientLayer()
        gradient.frame = base.bounds
        if let tempColors = colors {
            gradient.colors = tempColors.map{$0.cgColor}
        }else{
            gradient.colors = [UIColor(hex: 0x333239).cgColor,
                               UIColor(hex: 0x2E2D35).cgColor,
                               UIColor(hex: 0x1B1B1B).cgColor]
        }
        base.layer.addSublayer(gradient)
    }
    
    func addBlurBackgroud(style: UIBlurEffect.Style) {
        let effect = UIBlurEffect(style: style)
        let blur = UIVisualEffectView(effect: effect)
        base.insertSubview(blur, at: 0)
        blur.frame = base.bounds
        blur.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
}


// MARK: - Animation
public extension XZ where Base: UIView {
    
    func fadeIn(duration: TimeInterval = 1, completion: ((Bool) -> Void)? = nil) {
        if base.isHidden {
            base.isHidden = false
        }
        UIView.animate(withDuration: duration, animations: {
            self.base.alpha = 1
        }, completion: completion)
    }
    
    func rollingForever(duration: TimeInterval = 1, animated: Bool = true) {
        let rollAnim = CABasicAnimation(keyPath: "transform.rotation.z")
        rollAnim.toValue = Float.pi * 2
        rollAnim.duration = duration
        rollAnim.isCumulative = true
        rollAnim.repeatCount = HUGE
        base.layer.add(rollAnim, forKey: "rollingForever")
    }
    
    enum ShakeDirection {
        case horizontal
        case vertical
    }
    
    enum AngleUnit {
        case degrees
        case radians
    }
    
    enum ShakeAnimationType {
        case linear
        case easeIn
        case easeOut
        case easeInOut
    }
    
    
    /// Rotate view by angle on relative axis.
    ///
    /// - Parameters:
    ///   - angle: angle to rotate view by.
    ///   - type: type of the rotation angle.
    ///   - animated: set true to animate rotation (default is true).
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func rotate(byAngle angle: CGFloat, ofType type: AngleUnit, animated: Bool = false, duration: TimeInterval = 0.3, completion: ((Bool) -> Void)? = nil) {
        let angleWithType = (type == .degrees) ? .pi * angle / 180.0 : angle
        let aDuration = animated ? duration : 0
        UIView.animate(withDuration: aDuration, delay: 0, options: .curveEaseInOut, animations: { () -> Void in
            self.base.transform = self.base.transform.rotated(by: angleWithType)
        }, completion: completion)
    }
    
    func rotateRestore(animated: Bool = false, duration: TimeInterval = 0.3) {
        let aDuration = animated ? duration : 0
        UIView.animate(withDuration: aDuration) {
            self.base.transform = CGAffineTransform.identity
        }
    }
    
    /// Rotate view to angle on fixed axis.
    ///
    /// - Parameters:
    ///   - angle: angle to rotate view to.
    ///   - type: type of the rotation angle.
    ///   - animated: set true to animate rotation (default is false).
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func rotate(toAngle angle: CGFloat, ofType type: AngleUnit, animated: Bool = false, duration: TimeInterval = 1, completion: ((Bool) -> Void)? = nil) {
        let angleWithType = (type == .degrees) ? .pi * angle / 180.0 : angle
        let aDuration = animated ? duration : 0
        UIView.animate(withDuration: aDuration, animations: {
            self.base.transform = self.base.transform.concatenating(CGAffineTransform(rotationAngle: angleWithType))
        }, completion: completion)
    }
    
    /// Scale view by offset.
    ///
    /// - Parameters:
    ///   - offset: scale offset
    ///   - animated: set true to animate scaling (default is false).
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func scale(by offset: CGPoint, animated: Bool = false, duration: TimeInterval = 1, completion: ((Bool) -> Void)? = nil) {
        if animated {
            UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: { () -> Void in
                self.base.transform = self.base.transform.scaledBy(x: offset.x, y: offset.y)
            }, completion: completion)
        } else {
            base.transform = base.transform.scaledBy(x: offset.x, y: offset.y)
            completion?(true)
        }
    }
    
    /// Shake view.
    ///
    /// - Parameters:
    ///   - direction: shake direction (horizontal or vertical), (default is .horizontal)
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - animationType: shake animation type (default is .easeOut).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func shake(direction: ShakeDirection = .horizontal, duration: TimeInterval = 1, animationType: ShakeAnimationType = .easeOut, completion:(() -> Void)? = nil) {
        CATransaction.begin()
        let animation: CAKeyframeAnimation
        switch direction {
        case .horizontal:
            animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        case .vertical:
            animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        }
        switch animationType {
        case .linear:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        case .easeIn:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        case .easeOut:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        case .easeInOut:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        }
        CATransaction.setCompletionBlock(completion)
        animation.duration = duration
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        base.layer.add(animation, forKey: "shake")
        CATransaction.commit()
    }
    
}

//
public typealias VoidClosure = ()->Void
extension UIView{
    fileprivate struct AssociateKeys{
        static var key: Character = "\0"
    }
    fileprivate func addTapGesture(){
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(clickAction(gesture:)))
        addGestureRecognizer(singleTap)
        isUserInteractionEnabled = true
    }
    
    @objc func clickAction(gesture: UITapGestureRecognizer){
        self.xz.clickClosure?()
    }
}
public extension XZ where Base: UIView{
    
    var clickClosure: VoidClosure?{
        get{
            objc_getAssociatedObject(self.base, &Base.AssociateKeys.key) as? VoidClosure
        }
        set{
            if let _ = objc_getAssociatedObject(self.base, &Base.AssociateKeys.key) as? VoidClosure{
                
            }else{
                self.base.addTapGesture()
                objc_setAssociatedObject(self.base, &Base.AssociateKeys.key, newValue, .OBJC_ASSOCIATION_COPY)
            }
        }
    }
    
}
