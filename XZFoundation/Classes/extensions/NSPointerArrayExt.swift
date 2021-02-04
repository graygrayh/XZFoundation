//
//  NSPointerArrayExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/10/6.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation

public extension XZ where Base: NSPointerArray{
    func addObject(_ obj: AnyObject?){
        guard let strongObj = obj else {return}
        let pointer = Unmanaged.passUnretained(strongObj).toOpaque()
        self.base.addPointer(pointer)
    }
    
    func insertObject(_ obj: AnyObject?, at index: Int){
        guard index < self.base.count, let strongObj = obj else {return}
        let pointer = Unmanaged.passUnretained(strongObj).toOpaque()
        self.base.insertPointer(pointer, at: index)
    }
    
    func replaceObject(at index: Int, withObj obj: AnyObject?){
        guard index < self.base.count, let strongObj = obj else {return}
        let pointer = Unmanaged.passUnretained(strongObj).toOpaque()
        self.base.replacePointer(at: index, withPointer: pointer)
    }
    
    func object(at index: Int) -> AnyObject?{
        guard index < self.base.count, let pointer = self.base.pointer(at: index) else {return nil}
        return Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue()
    }
    
    func removeObject(at index: Int){
        guard index < self.base.count else {return}
        self.base.removePointer(at: index)
    }
    
    
}
