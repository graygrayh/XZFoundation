//
//  ArrayExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/12.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation

public extension Array {
    /// Move the post to the beginning of the array.
    @discardableResult
    mutating func moveToLeading(elementAt index: Int) -> Bool {
        guard index >= 0 && index < count else { return false }
        let ele = remove(at: index)
        insert(ele, at: 0)
        return true
    }
    
    @discardableResult
    mutating func moveToPre(elementAt index: Int) -> Bool {
        guard index > 0 && index < count else { return false }
        let ele = remove(at: index)
        insert(ele, at: index-1)
        return true
    }
    
    @discardableResult
    mutating func moveToNext(elementAt index: Int) -> Bool {
        guard index >= 0 && index < count-1 else { return false }
        let ele = self.remove(at: index)
        self.insert(ele, at: index+1)
        return true
    }
    
    @discardableResult
    mutating func changeOrder(elementAt fromIndex: Int, toIndex: Int) -> Bool {
        guard fromIndex >= 0 && fromIndex < count && toIndex >= 0 && toIndex < count else {
            return false
        }
        let item = remove(at: fromIndex)
        insert(item, at: toIndex)
        return true
    }
    
//    @discardableResult
//    mutating func swapOrder(elementAt index: Int, withIndex: Int) -> Bool {
//
//    }
    
}

public extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    @discardableResult
    mutating func remove(object: Element) -> Int? {
        guard let index = firstIndex(of: object) else { return nil }
        remove(at: index)
        return index
    }
    
    var deDuplication: Array{
        return self.reduce([]) {
            $0.contains($1) ? $0 : $0 + [$1]
        }
    }
    
}

