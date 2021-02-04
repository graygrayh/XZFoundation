//
//  UIResponseExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/11/16.
//

import UIKit

/**
 事件响应链拓展
 */
public protocol XZResponderChainEventType {}

public protocol XZResponderChainType {
    // 响应链路由
    func router<Event>(event: Event, params: [String: Any]?) where Event : XZResponderChainEventType
}

public protocol XZResponseable{
    //响应者实际调用
    func responseRouter<Event>(event: Event, params: [String: Any]?)
}
extension UIResponder: XZResponderChainType {}
extension XZResponderChainType where Self: UIResponder {
    // 响应链路由
    public func router<Event>(event: Event, params: [String: Any]?) where Event : XZResponderChainEventType {
        if let responseObj = next as? XZResponseable {
            responseObj.responseRouter(event: event, params: params)
        }else{
            next?.router(event: event, params: params)
        }
    }
}
