//
//  Dictionary.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/7.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation

public extension Dictionary {
    /// Merges the dictionary with dictionaries passed. The latter dictionaries will override
    /// values of the keys that are already set
    ///
    /// - parameter dictionaries: A comma seperated list of dictionaries
    mutating func merge<K, V>(dictionaries: Dictionary<K, V>...) {
        for dict in dictionaries {
            for (key, value) in dict {
                self.updateValue(value as! Value, forKey: key as! Key)
            }
        }
    }
    
    static func merged<K, V>(dictionaries: Dictionary<K, V>...) -> Dictionary<K, V>? {
        var resDict: Dictionary<K, V> = [:]
        for dict in dictionaries {
            for (key, value) in dict {
                resDict.updateValue(value, forKey: key)
            }
        }
        return resDict.count > 0 ? resDict : nil
    }
}

extension Dictionary: XZGenericCompatible2{
    public typealias T1 = Key
    
    public typealias T2 = Value
    
    
}
public extension XZGeneric2 where Base == Dictionary<T1, T2> {
    
    var toString: String? {
        guard let data = try? JSONSerialization.data(withJSONObject: base, options: [.fragmentsAllowed]) else {
            return nil
        }
        let str = String(data: data, encoding: String.Encoding.utf8)
        return str
    }
    
}
