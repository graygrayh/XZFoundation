//
//  UILabelExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/6.
//  Copyright © 2020 xzh. All rights reserved.
//

import UIKit

public extension XZ where Base: UILabel {
    
    /// 估计行数
    var estimateLines: Int {
        // 有误差，误差较小可忽略不计。
        return Int(estimateHeight/base.font.lineHeight)
    }
    
    /// 估计高度
    var estimateHeight: CGFloat {
        let lb = UILabel(frame: CGRect(x: 0, y: 0, width: base.frame.width, height: CGFloat.greatestFiniteMagnitude))
        lb.numberOfLines = 0
        lb.lineBreakMode = .byWordWrapping
        lb.font = base.font
        lb.text = base.text
        lb.attributedText = base.attributedText
        lb.sizeToFit()
        return lb.frame.height
    }
}
