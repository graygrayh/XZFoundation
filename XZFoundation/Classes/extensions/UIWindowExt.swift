//
//  UIWindowExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/10/4.
//

import UIKit

public extension XZ where Base: UIWindow{
    
    static var keyWindow: UIWindow?{
        if #available(iOS 13.0, *) {
            for secen in UIApplication.shared.connectedScenes {
                if let windowSecen = secen as? UIWindowScene, windowSecen.activationState == .foregroundActive {
                    return windowSecen.windows.first{$0.isKeyWindow}
                }
            }
        }
        return UIApplication.shared.keyWindow
    }
    
    static func topController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            if nav.viewControllers.count > 0 {
                return topController(nav.visibleViewController)
            }else{
                return nav
            }
        }else if let tab = base as? UITabBarController {
            if tab.viewControllers != nil {
                return topController(tab.selectedViewController)
            }else{
                return tab
            }
        }else if let split = base as? UISplitViewController {
            if split.viewControllers.count > 0 {
                return topController(split.viewControllers.last)
            }else{
                return split
            }
        }else if let presented = base?.presentedViewController {
            return topController(presented)
        }
        return base
    }
    
    static func topNav() -> UINavigationController? {
        return Self.topController()?.navigationController
    }
    
}
