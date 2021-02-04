//
//  CGRectExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/6.
//  Copyright © 2020 xzh. All rights reserved.
//

import UIKit

public extension CGRect{
    /// Create instance with center and size
    /// - Parameters:
    ///   - center: center of the new rect
    ///   - size: size of the new rect
    init(center: CGPoint, size: CGSize) {
        let origin = CGPoint(x: center.x - size.width / 2.0, y: center.y - size.height / 2.0)
        self.init(origin: origin, size: size)
    }
}

extension CGRect: XZCompatible{}
public extension XZ where Base == CGRect {
    
    /// Return center of rect
    var center: CGPoint { CGPoint(x: base.midX, y: base.midY) }
    
    
    
    /// Create a new `CGRect` by resizing with specified anchor
    /// - Parameters:
    ///   - size: new size to be applied
    ///   - anchor: specified anchor, a point in normalized coordinates -
    ///     '(0, 0)' is the top left corner of rect，'(1, 1)' is the bottom right corner of rect,
    ///     defaults to '(0.5, 0.5)'. excample:
    ///
    ///          anchor = CGPoint(x: 0.0, y: 1.0):
    ///
    ///                       A2------B2
    ///          A----B       |        |
    ///          |    |  -->  |        |
    ///          C----D       C-------D2
    ///
    func resizing(to size: CGSize, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = CGSize(width: size.width - base.width, height: size.height - base.height)
        return CGRect(origin: CGPoint(x: base.minX - sizeDelta.width * anchor.x,
                                      y: base.minY - sizeDelta.height * anchor.y),
                      size: size)
    }
    
    func resizedWith(padding: UIEdgeInsets) -> CGRect {
        let x = base.origin.x + padding.left
        let y = base.origin.y + padding.top
        let w = base.size.width - (padding.left + padding.right)
        let h = base.size.height - (padding.top + padding.bottom)
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
