//
//  XZProtocol.swift
//  XZFoundation
//
//  Created by xzh on 2020/10/10.
//  Copyright © 2020 xzh. All rights reserved.
//

import UIKit

// MARK:-ViewModel 协议
public protocol XZViewModelProtocol{
    associatedtype Input
    associatedtype Ouput:Codable
    associatedtype Hud:UIView
    associatedtype Err
    var hud: Hud?{get set}
    mutating func showHud()
    func hideHud()
    func loadData(_ input: Input, completion: @escaping (Ouput?, Err?)->Void)
}

// MARK:-重用索引协议
public protocol Reuseable: class {
    static var reuseIdentifier: String{ get }
}

public extension Reuseable{
    static var reuseIdentifier: String{
        let identifier = String(describing: self)
        return identifier
    }
}

// MARK: -枚举匹配序列化
// defaultCase未匹配，默认值
public protocol LKCodableEnum: RawRepresentable, Codable where RawValue: Codable {
    static var defaultCase: Self { get }
}

public extension LKCodableEnum {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            let decoded = try container.decode(RawValue.self)
            self = Self.init(rawValue: decoded) ?? Self.defaultCase
        } catch {
            self = Self.defaultCase
        }
    }
}

public class XZDelegate<Input, Output> {
    public init() {}
    
    private var block: ((Input) -> Output?)?
    
    public func delegate<T: AnyObject>(on target: T, block: ((T, Input) -> Output)?) {
        self.block = { [weak target] input in
            guard let target = target else { return nil }
            return block?(target, input)
        }
    }
    
    public func call(_ input: Input) -> Output? {
        return block?(input)
    }
}

public extension XZDelegate where Input == Void {
    func call() -> Output? {
        return call(())
    }
}
