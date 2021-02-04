//
//  XZPageStack.swift
//  XZFoundation
//
//  Created by xzh on 2020/10/21.
//

import Foundation

public class XZNode<T>{
    public var element: T
    public var next: XZNode<T>?
    
    public init(value: T, nextNode:XZNode<T>?=nil) {
        self.element = value
        self.next = nextNode
    }
}

public class XZPageStack<T>{
    public var head: XZNode<T>?
    public var deleteNode: XZNode<T>?
    public private(set) var size: Int = 0
    public init(){}
    // 是否空栈
    public var isEmpty: Bool{
        if head == nil {
            if size != 0 {
                size = 0
            }
            return true
        }
        return false
    }
    
    // 压栈
    public func push(element: T){
        deleteNode = nil
        if head == nil {
            head = XZNode(value: element)
        }else{
            let tempNode = head
            head = XZNode(value: element)
            head?.next = tempNode
        }
        size += 1
    }
    
    // 出栈
    @discardableResult
    public func pop() -> T?{
        if isEmpty {return nil}
        let element = head?.element
        deleteNode = head
        head = head?.next
        size -= 1
        if size < 0 {size = 0}
        return element
        
    }
    
    // 栈顶
    public func peer() -> T?{
        return head?.element
    }
    
}

