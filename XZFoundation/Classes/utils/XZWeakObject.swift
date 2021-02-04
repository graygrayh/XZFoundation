//
//  XZWeakObject.swift
//  XZFoundation
//
//  Created by xzh on 2020/10/6.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation

public class XZWeakObject<T: AnyObject>{
    
    private(set) weak var weakValue: T?
    init(value: T?) {
        self.weakValue = value
    }
    
}
