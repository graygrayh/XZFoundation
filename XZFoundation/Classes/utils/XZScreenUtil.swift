//
//  XZScreenUtil.swift
//  XZFoundation
//
//  Created by xzh on 2020/9/2.
//  Copyright © 2020 xzh. All rights reserved.
//

import UIKit

public class XZScreenUtil{
    
    public static let shared = XZScreenUtil()
    private var uiWidthPx: CGFloat = 375
    private var uiHeightPx: CGFloat = 812
    private init(){}
    
    public static let kScreenWidth = UIScreen.main.bounds.width
    public static let kScreenHeight = UIScreen.main.bounds.height
    
    public static var statuBarFrame: CGRect{
        if #available(iOS 13.0, *) {
            for scene in UIApplication.shared.connectedScenes {
                if let windowScene = scene as? UIWindowScene, let statuBarFrame = windowScene.statusBarManager?.statusBarFrame{
                    return statuBarFrame
                }
            }
        }
        return UIApplication.shared.statusBarFrame
    }
    public static let keyWindow: UIWindow? = UIWindow.xz.keyWindow
    public static let statuBarHeight: CGFloat = statuBarFrame.height
    public static var kIsiPhoneX: Bool{
        if #available(iOS 11.0, *) {
            if let _ = keyWindow?.safeAreaInsets {
                return true
            }
        }
        return false
    }
    public static let navigationHeight: CGFloat = statuBarHeight + 44.0
    public static let tabbarHeight: CGFloat = statuBarHeight >= 44.0 ? 83.0 : 49.0
    public static let topSafeAreaHeight: CGFloat = statuBarHeight - 20.0
    public static let bottomSafeAreaHeight: CGFloat = tabbarHeight - 49.0
    public static let kScreenSafeHeight = kScreenHeight - navigationHeight-tabbarHeight
    
    // 屏幕像素比，宽高比
    public static let pixelRatio: CGFloat = UIScreen.main.scale
    public static let screenWHRatio: CGFloat = kScreenWidth/kScreenHeight
    public static let screenHWRatio: CGFloat = kScreenWidth/kScreenHeight
    
    public static var scaleWidth: CGFloat{
        return kScreenWidth/shared.uiWidthPx
    }
    
    public static var scaleHeight: CGFloat{
        return kScreenHeight/shared.uiHeightPx
    }
    
    public static var kScreenWidthPx: CGFloat{
        return kScreenWidth * pixelRatio
    }
    
    public static var kScreenHeightPx: CGFloat{
        return kScreenHeight * pixelRatio
    }
    
    public static func configureScreen(designWidth: CGFloat=375, designHeight: CGFloat=667) {
        shared.uiWidthPx = designWidth
        shared.uiHeightPx = designHeight
    }
    
    
}


public extension CGFloat{
    
    var wpt: CGFloat{
        return self * XZScreenUtil.scaleWidth
    }
    
    var hpt: CGFloat{
        return self * XZScreenUtil.scaleHeight
    }
    
}

public extension Int{
    var wpt: CGFloat{
        return CGFloat(self) * XZScreenUtil.scaleWidth
    }
    
    var hpt: CGFloat{
        return CGFloat(self) * XZScreenUtil.scaleHeight
    }
}

public extension Double{
    var wpt: CGFloat{
        return CGFloat(self) * XZScreenUtil.scaleWidth
    }
    
    var hpt: CGFloat{
        return CGFloat(self) * XZScreenUtil.scaleHeight
    }
}

public extension CGFloat{
    
    var wpx: CGFloat{
        return self * XZScreenUtil.pixelRatio
    }
    
    var hpx: CGFloat{
        return self * XZScreenUtil.pixelRatio
    }
    
}

public extension Int{
    var wpx: CGFloat{
        return CGFloat(self) * XZScreenUtil.pixelRatio
    }
    
    var hpx: CGFloat{
        return CGFloat(self) * XZScreenUtil.pixelRatio
    }
}

public extension Double{
    var wpx: CGFloat{
        return CGFloat(self) * XZScreenUtil.pixelRatio
    }
    
    var hpx: CGFloat{
        return CGFloat(self) * XZScreenUtil.pixelRatio
    }
}

