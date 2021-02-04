//
//  XZ.swift
//  XZFoundation
//
//  Created by xzh on 2020/10/9.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation
import KeychainSwift

// MARK: - 普通类型
open class XZ<Base> {
    let base: Base
    init(_ base: Base) {
        self.base = base
    }
}
public protocol XZCompatible {}
public extension XZCompatible {
    static var xz: XZ<Self>.Type {
        get { return XZ<Self>.self }
        set {}
    }
    var xz: XZ<Self> {
        get { return XZ(self) }
        set {}
    }
}


// MARK: - 一个泛型参数类型
open class XZGeneric<Base, T> {
    let base: Base
    init(_ base: Base) {
        self.base = base
    }
}
public protocol XZGenericCompatible {
    associatedtype T
}
public extension XZGenericCompatible {
    static var XZ: XZGeneric<Self, T>.Type {
        get { return XZGeneric<Self, T>.self }
        set {}
    }
    var XZ: XZGeneric<Self, T> {
        get { return XZGeneric(self) }
        set {}
    }
}

// MARK: - 两个泛型参数类型
open class XZGeneric2<Base, T1, T2> {
    let base: Base
    init(_ base: Base) {
        self.base = base
    }
}
public protocol XZGenericCompatible2 {
    associatedtype T1
    associatedtype T2
}
public extension XZGenericCompatible2 {
    static var XZ: XZGeneric2<Self, T1, T2>.Type {
        get { return XZGeneric2<Self, T1, T2>.self }
        set {}
    }
    var XZ: XZGeneric2<Self, T1, T2> {
        get { return XZGeneric2(self) }
        set {}
    }
}

public typealias XZVoidClosure         = () -> Void
public typealias XZIntClosure          = (_ value: Int) -> Void
public typealias XZBoolClosure         = (_ finished: Bool) -> Void
public typealias XZStringClosure       = (_ str: String) -> Void
public typealias XZArrayClosure        = (_ array: Array<Any>?) -> Void
public typealias XZDictionaryClosure   = (_ dict: [String:Any]?) -> Void
public typealias XZDataClosure         = (_ data: Data?) -> Void
public typealias XZImageClosure        = (_ image: UIImage?) -> Void
public let keychain: KeychainSwift = {
    let kc = KeychainSwift()
    kc.synchronizable = false
    //kc.accessGroup = ""
    return kc
}()


extension NSObject: XZCompatible{}
public extension XZ where Base: NSObject{
    
    // ivars
    var ivars: [String] {
        var ret = [String]()
        
        var count: u_int = 0
        if let ivars = class_copyIvarList(base.classForCoder, &count) {
            for i in 0..<Int(count) {
                let ivar = ivars[i]
                if let cString = ivar_getName(ivar) {
                    ret.append(String(cString: cString as UnsafePointer<CChar>))
                }
            }
            free(ivars)
        }
        
        return ret
    }

    // 属性
    var properties: [String] {
        var ret = [String]()
        
        var count: u_int = 0
        if let properties = class_copyPropertyList(base.classForCoder, &count) {
            for i in 0..<Int(count) {
                let property = properties[i]
                let cString = property_getName(property)
                ret.append(String(cString: cString as UnsafePointer<CChar>))
            }
            free(properties)
        }
        
        return ret
    }
    
    // 方法
    var methods: [String] {
        var ret = [String]()
        
        var count: u_int = 0
        if let methods = class_copyMethodList(base.classForCoder, &count) {
            for i in 0..<Int(count) {
                let method = methods[i]
                let selector = method_getName(method)
                let cString = sel_getName(selector)
                ret.append(String(cString: cString as UnsafePointer<CChar>))
            }
            free(methods)
        }
        
        return ret
    }
    
    // 协议
    var protocols: [String] {
        var ret = [String]()
        
        var count: u_int = 0
        if let protocols = class_copyProtocolList(base.classForCoder, &count) {
            for i in 0..<Int(count) {
                let proto = protocols[i]
                let cString = protocol_getName(proto)
                ret.append(String(cString: cString as UnsafePointer<CChar>))
            }
            // No need to free protocols because it's AutoreleasingUnsafeMutablePointer<Protocol?>!
        }
        
        return ret
    }
    
    // 属性name/value
    var propertyDictinary: [String:Any]{
        var retDict: [String:Any] = [String:Any]()
        var count: u_int = 0
        if let properties = class_copyPropertyList(base.classForCoder, &count){
            for i in 0..<Int(count) {
                let property = properties[i]
                let cString = property_getName(property)
                let propertyName = String(cString: cString as UnsafePointer<CChar>)
                if let propertyValue = base.value(forKey: propertyName){
                    retDict[propertyName] = propertyValue
                }
            }
            free(properties)
        }
        
        return retDict
    }
    
}
