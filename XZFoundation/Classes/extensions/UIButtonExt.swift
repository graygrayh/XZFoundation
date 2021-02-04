//
//  UIButtonExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/3/25.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation
import UIKit

public extension XZ where Base: UIButton {
    ///create button with colored bg image
    class func makeWith(_ size: CGSize, normalColor: UIColor, selectedColor: UIColor?, radius: CGFloat) -> UIButton {
        let btn = UIButton(frame: CGRect(origin: .zero, size: size))
        let normalBg = UIImage.xz.resizableImage(color: normalColor, radius: radius)
        btn.setBackgroundImage(normalBg, for: .normal)
        
        if let cc = selectedColor {
            let selectedBg = UIImage.xz.resizableImage(color: cc, radius: radius)
            btn.setBackgroundImage(selectedBg, for: .selected)
        }
        return btn
    }
    
    /// Center align title text and image
    /// - Parameters:
    ///   - imageAboveText: set true to make image above title text, default is false, image on left of text
    ///   - spacing: spacing between title text and image.
    func centerTextAndImage(imageAboveText: Bool = true, spacing: CGFloat = 6.0) {
        if imageAboveText {
            // https://stackoverflow.com/questions/2451223/#7199529
            guard
                let imageSize = base.imageView?.image?.size,
                let text = base.titleLabel?.text,
                let font = base.titleLabel?.font
                else { return }
            
            let titleSize = text.size(withAttributes: [.font: font])
            
            let titleOffset = -(imageSize.height + spacing)
            base.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize.width, bottom: titleOffset, right: 0.0)
            
            let imageOffset = -(titleSize.height + spacing)
            base.imageEdgeInsets = UIEdgeInsets(top: imageOffset, left: 0.0, bottom: 0.0, right: -titleSize.width)
            
            let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0
            base.contentEdgeInsets = UIEdgeInsets(top: edgeOffset, left: 0.0, bottom: edgeOffset, right: 0.0)
        } else {
            let insetAmount = spacing / 2
            base.imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
            base.titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
            base.contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
        }
    }
}


public extension XZ where Base: UIButton {
    
    var titleForDisabled: String? {
        get {
            return base.title(for: .disabled)
        }
        set {
            base.setTitle(newValue, for: .disabled)
        }
    }
    
    var titleForHighlighted: String? {
        get {
            return base.title(for: .highlighted)
        }
        set {
            base.setTitle(newValue, for: .highlighted)
        }
    }
    
    var titleForNormal: String? {
        get {
            return base.title(for: .normal)
        }
        set {
            base.setTitle(newValue, for: .normal)
        }
    }
    
    var titleForSelected: String? {
        get {
            return base.title(for: .selected)
        }
        set {
            base.setTitle(newValue, for: .selected)
        }
    }
    
    private var states: [UIControl.State] {
        return [.normal, .selected, .highlighted, .disabled]
    }
    
    func setImageForAllStates(_ image: UIImage) {
        states.forEach { base.setImage(image, for: $0) }
    }
}
