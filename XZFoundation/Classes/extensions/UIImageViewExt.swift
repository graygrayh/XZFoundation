//
//  UIImageView.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/5.
//  Copyright © 2020 xzh. All rights reserved.
//

import UIKit


// MARK: - Blur
public extension XZ where Base: UIImageView {
    
    /// Make image view blurry
    /// - Parameter style: UIBlurEffectStyle (default is .light)
    @discardableResult
    func blur(withStyle style: UIBlurEffect.Style = .light) -> UIImageView {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = base.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        base.addSubview(blurEffectView)
        base.clipsToBounds = true
        return base
    }
    
    func tintToColor(_ color: UIColor) {
        let templateImg = base.image?.withRenderingMode(.alwaysTemplate)
        base.image = templateImg
        base.tintColor = color
    }
}
