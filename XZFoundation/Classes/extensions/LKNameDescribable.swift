//
//  XZNameDescribable.swift
//  XZFoundation
//
//  Created by xzh on 2020/9/2.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation

public protocol XZNameDescribable {
    var typeName: String { get }
    static var typeName: String { get }
}

public extension XZNameDescribable {
    var typeName: String {
        return String(describing: type(of: self))
    }
    
    static var typeName: String {
        return String(describing: self)
    }
}
