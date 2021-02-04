//
//  NumberExtension.swift
//  XZFoundation
//
//  Created by xzh on 2020/9/1.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation

extension Int: XZCompatible{}
public extension XZ where Base == Int{
    var char: Character?{
        if let scalar: UnicodeScalar = UnicodeScalar(self.base){
            return Character(scalar)
        }
        return nil
    }
    
    var str: String{
        if let char = self.char{
            return String(char)
        }else{
            return String(self.base)
        }
    }
    
    var hexString: String{
        return String(format: "%02x", base)
    }
    
    // 度数转弧度
    var toRadian: CGFloat{
        return CGFloat(base) * .pi / 180
    }
    
}

extension Double: XZCompatible{}
public extension XZ where Base == Double{
    
    // 度数转弧度
    var toRadian: CGFloat{
        return CGFloat(base) * .pi / 180
    }
    
}


extension CGFloat: XZCompatible{}
public extension XZ where Base == CGFloat{
    
    // 度数转弧度
    var toRadian: CGFloat{
        return base * .pi / 180
    }
    
}
