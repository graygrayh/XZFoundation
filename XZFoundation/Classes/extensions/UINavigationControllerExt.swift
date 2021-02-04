//
//  UINavigationControllerExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/7.
//  Copyright © 2020 xzh. All rights reserved.
//

import UIKit

public extension XZ where Base: UINavigationController {
    func rootViewController() -> UIViewController? {
        return base.viewControllers.first
    }
}
