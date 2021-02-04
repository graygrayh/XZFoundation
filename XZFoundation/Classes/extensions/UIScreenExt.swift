//
//  UIScreenExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/6.
//  Copyright © 2020 xzh. All rights reserved.
//

import UIKit

public extension XZ where Base: UIScreen {
    
    static var width: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var height: CGFloat {
        return UIScreen.main.bounds.height
    }
    
}
