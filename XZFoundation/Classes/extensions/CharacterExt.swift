//
//  CharacterExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/10/5.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation

extension Character: XZCompatible{}
public extension XZ where Base == Character{
    func toInt() -> Int? {
        return Int(String(self.base))
    }
}
