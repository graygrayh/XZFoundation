//
//  CGSizeExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/6.
//  Copyright © 2020 xzh. All rights reserved.
//

import UIKit

extension CGSize: XZCompatible{}
public extension XZ where Base == CGSize {
    
    func scaleBy(_ times: CGFloat) -> CGSize {
        return CGSize(width: base.width * times, height: base.height * times)
    }
    
    /// Returns the aspect ratio.
    var aspectRatio: CGFloat {
        return base.height == 0 ? 0 : base.width / base.height
    }
    
    /// Returns width or height, whichever is the bigger value.
    var maxDimension: CGFloat {
        return max(base.width, base.height)
    }
    
    /// Returns width or height, whichever is the smaller value.
    var minDimension: CGFloat {
        return min(base.width, base.height)
    }
    
    /// Aspect fit CGSize.
    ///
    ///     let rect = CGSize(width: 120, height: 80)
    ///     let parentRect  = CGSize(width: 100, height: 50)
    ///     let newRect = rect.aspectFit(to: parentRect)
    ///     // newRect.width = 75 , newRect.height = 50
    ///
    /// - Parameter boundingSize: bounding size to fit self to.
    /// - Returns: self fitted into given bounding size
    func aspectFit(to boundingSize: CGSize) -> CGSize {
        let minRatio = min(boundingSize.width / base.width, boundingSize.height / base.height)
        return CGSize(width: base.width * minRatio, height: base.height * minRatio)
    }
    
    /// Aspect fill CGSize.
    ///
    ///     let rect = CGSize(width: 20, height: 120)
    ///     let parentRect  = CGSize(width: 100, height: 60)
    ///     let newRect = rect.aspectFit(to: parentRect)
    ///     // newRect.width = 100 , newRect.height = 60
    ///
    /// - Parameter boundingSize: bounding size to fill self to.
    /// - Returns: self filled into given bounding size
    func aspectFill(to boundingSize: CGSize) -> CGSize {
        let minRatio = max(boundingSize.width / base.width, boundingSize.height / base.height)
        let aWidth = min(base.width * minRatio, boundingSize.width)
        let aHeight = min(base.height * minRatio, boundingSize.height)
        return CGSize(width: aWidth, height: aHeight)
    }
    
}
