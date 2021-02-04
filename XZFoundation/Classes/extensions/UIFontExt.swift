//
//  UIFontExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/1.
//  Copyright © 2020 xzh. All rights reserved.
//

import UIKit

public extension XZ where Base: UIFont {
    
    func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = base.fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
    
}
