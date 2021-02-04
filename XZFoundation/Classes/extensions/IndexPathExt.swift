//
//  IndexPath.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/10.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation

extension IndexPath: XZCompatible{}
public extension XZ where Base == IndexPath {
    
    func nextItem() -> IndexPath {
        return IndexPath(item: base.item+1, section: base.section)
    }
    
    func preItem() -> IndexPath {
        return IndexPath(item: base.item-1, section: base.section)
    }
    
}
