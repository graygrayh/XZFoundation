//
//  UIStackView.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/6.
//  Copyright © 2020 xzh. All rights reserved.
//

import UIKit

public extension XZ where Base: UIStackView{
    /// Remove all the items from the stack.
    func flushItems() {
        base.arrangedSubviews.forEach {
            base.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    /// Remove arranged item according to index.
    func removeItem(at index: Int) {
        guard index >= 0 && index < base.arrangedSubviews.count else { return }
        let toRemove = base.arrangedSubviews[index]
        base.removeArrangedSubview(toRemove)
        toRemove.removeFromSuperview()
    }
}
