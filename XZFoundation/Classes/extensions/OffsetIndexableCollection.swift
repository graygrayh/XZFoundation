//
//  OffsetIndexableCollection.swift
//  XZFoundation
//
//  Created by xzh on 2020/8/24.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation

// MARK: - Range +
public extension Range {
    func map<T>(_ transform: (Bound) throws -> T) rethrows -> Range<T> {
        return try Range<T>(uncheckedBounds: (lower: transform(lowerBound), upper: transform(upperBound)))
    }
}

public extension Collection {
    var range: Range<Index> {
        return startIndex..<endIndex
    }
}

// MARK: - IndexProxyProtocol
public protocol IndexProxyProtocol {
    
    associatedtype Target : Collection
    associatedtype ProxyIndices : Collection = Self
    
    typealias TargetIndex = Target.Index
    typealias ProxyIndex = ProxyIndices.Index
    typealias TargetRange = Range<TargetIndex>
    typealias ProxyRange = Range<ProxyIndex>
    
    var target: Target { get }
    var proxyIndices: ProxyIndices { get }
    
    // TargetIndex -> ProxyIndex
    // ProxyIndex -> TargetIndex
    func proxyIndex(_ targetIndex: TargetIndex) -> ProxyIndex
    func targetIndex(_ proxyIndex: ProxyIndex) -> TargetIndex
    
    // TargetRange -> ProxyRange
    // ProxyRange -> TargetRange
    func proxyRange<R: RangeExpression>(_ targetRange: R) -> Range<ProxyIndex> where R.Bound == TargetIndex
    func proxyRange(_ targetRange: UnboundedRange) -> Range<ProxyIndex>
    func targetRange<R: RangeExpression>(_ proxyRange: R) -> Range<TargetIndex> where R.Bound == ProxyIndex
    func targetRange(_ proxyRange: UnboundedRange) -> Range<TargetIndex>
}

public extension IndexProxyProtocol {
    
    func proxyRange<R: RangeExpression>(_ targetRange: R) -> Range<ProxyIndex> where R.Bound == TargetIndex {
        return targetRange.relative(to: target).map(proxyIndex)
    }
    
    func proxyRange(_ targetRange: UnboundedRange) -> Range<ProxyIndex> {
        return target.range.map(proxyIndex)
    }
    
    func targetRange<R: RangeExpression>(_ proxyRange: R) -> Range<TargetIndex> where R.Bound == ProxyIndex {
        return proxyRange.relative(to: proxyIndices).map(targetIndex)
    }
    
    func targetRange(_ proxyRange: UnboundedRange) -> Range<TargetIndex> {
        return proxyIndices.range.map(targetIndex)
    }
}

public extension IndexProxyProtocol where ProxyIndices == Self {
    
    var proxyIndices: ProxyIndices {
        return self
    }
    
    var startIndex: Self.Index {
        return proxyIndex(target.startIndex)
    }
    
    var endIndex: Self.Index {
        return proxyIndex(target.endIndex)
    }
    
    func index(after i: Self.Index) -> Self.Index {
        let i = targetIndex(i)
        return proxyIndex(target.index(after: i))
    }
    
    subscript(i: Self.Index) -> Self.Index {
        return i
    }
    
    var indices: Self {
        return self
    }
}

// MARK: - OffsetIndices
public struct OffsetIndices<T: Collection> {
    
    private let _target: T
    
    public init(_ target: T) {
        _target = target
    }
    
}

extension OffsetIndices : IndexProxyProtocol, Collection {
    
    public typealias Index = Int
    public typealias Target = T
    public typealias ProxyIndices = OffsetIndices<T>
    
    public var target: Target {
        return _target
    }
    
    // TargetIndex -> ProxyIndex
    // ProxyIndex -> TargetIndex
    public func proxyIndex(_ targetIndex: TargetIndex) -> ProxyIndex {
        let offset = target.distance(from: target.startIndex, to: targetIndex)
        return offset
    }
    
    public func targetIndex(_ proxyIndex: ProxyIndex) -> TargetIndex {
        let offset = proxyIndex
        return target.index(target.startIndex, offsetBy: offset)
    }
}

// MARK: - OffsetIndexableCollection
public protocol OffsetIndexableCollection : Collection {
    typealias OffsetIndex = OffsetIndices<Self>.Index
    typealias OffsetRange = Range<OffsetIndex>
    var offsetIndices: OffsetIndices<Self> { get }
}

public extension OffsetIndexableCollection {
    
    var start: Int{
        return 0
    }
    
    var end: Int{
        var iterator = makeIterator()
        var i = 0
        while let _ = iterator.next() {
            i += 1
        }
        return i
    }
    
    func i_first(where predicate: (Element) -> Bool) -> Element? {
        var iterator = makeIterator()
        while let elem = iterator.next() {
            if predicate(elem) {
                return elem
            }
        }
        return nil
    }
    
    func i_lastIndex(where predicate: (Element) -> Bool) -> OffsetIndex?{
        var iterator = makeIterator()
        var i = 0
        var tempIndex: Int?
        while let elem = iterator.next() {
            if predicate(elem) {
                tempIndex = i
            }
            i += 1
        }
        return tempIndex
        
    }
    
    func i_first(where predicate: (Element) -> Bool) -> Int? {
        var iterator = makeIterator()
        var i = 0
        while let elem = iterator.next() {
            if predicate(elem) {
                return i
            }
            i += 1
        }
        return nil
    }
    
    var offsetIndices: OffsetIndices<Self> {
        return OffsetIndices<Self>(self)
    }
    
    func offsetIndex(_ index: Index) -> OffsetIndex {
        return offsetIndices.proxyIndex(index)
    }
    
    func index(byOffset offsetIndex: OffsetIndex) -> Index {
        return offsetIndices.targetIndex(offsetIndex)
    }
    
    func offsetRange(_ : Range<Index>) -> OffsetRange {
        return offsetIndices.proxyRange(range)
    }
    
    func range(byOffset offsetRange: OffsetRange) -> Range<Index> {
        return offsetIndices.targetRange(offsetRange)
    }
}

// OffsetIndexableCollection where Self : Collection
public extension OffsetIndexableCollection {
    
    subscript(i: OffsetIndex) -> Self.Element {
        return self[offsetIndices.targetIndex(i)]
    }
    
    subscript<R: RangeExpression>(bounds: R) -> Self.SubSequence where R.Bound == OffsetIndex {
        return self[offsetIndices.targetRange(bounds)]
    }
    
    func i_prefix(through i: OffsetIndex) -> Self.SubSequence {
        return prefix(through: offsetIndices.targetIndex(i))
    }
    
    func i_prefix(upTo i: OffsetIndex) -> Self.SubSequence {
        return prefix(upTo: offsetIndices.targetIndex(i))
    }
    
    func i_suffix(from i: OffsetIndex) -> Self.SubSequence {
        return suffix(from: offsetIndices.targetIndex(i))
    }
    
    func i_index(where predicate: (Self.Element) throws -> Bool) rethrows -> OffsetIndex? {
        return try firstIndex(where: predicate).map(offsetIndices.proxyIndex)
    }
    
}

public extension OffsetIndexableCollection where Self.Element : Equatable {
    
    func i_index(of element: Self.Element) -> OffsetIndex? {
        return firstIndex(of: element).map(offsetIndices.proxyIndex)
    }
    
    func i_lastIndex(of e: Element) -> OffsetIndex?{
        var iterator = makeIterator()
        var i = 0
        var tempIndex: Int?
        while let elem = iterator.next() {
            if elem == e {
                tempIndex = i
            }
            i += 1
        }
        return tempIndex
    }
    
}

public extension OffsetIndexableCollection where Self : MutableCollection {
    subscript(i: OffsetIndex) -> Self.Element {
        get {
            return self[offsetIndices.targetIndex(i)]
        }
        mutating set {
            self[offsetIndices.targetIndex(i)] = newValue
        }
    }
    
    subscript<R: RangeExpression>(bounds: R) -> Self.SubSequence where R.Bound == OffsetIndex {
        get {
            return self[offsetIndices.targetRange(bounds)]
        }
        mutating set {
            self[offsetIndices.targetRange(bounds)] = newValue
        }
    }
    
    mutating func swapAt(_ i: OffsetIndex, _ j: OffsetIndex) {
        swapAt(offsetIndices.targetIndex(i), offsetIndices.targetIndex(j))
    }
    
    mutating func partition(by belongsInSecondPartition: (Self.Element) throws -> Bool) rethrows -> OffsetIndex {
        return offsetIndices.proxyIndex(try partition(by: belongsInSecondPartition))
    }
}

public extension OffsetIndexableCollection where Self : RangeReplaceableCollection {
    
    mutating func replaceSubrange<C : Collection, R : RangeExpression>(_ subrange: R, with newElements: C)
        where R.Bound == OffsetIndex, C.Element == Self.Element {
            return replaceSubrange(offsetIndices.targetRange(subrange), with: newElements)
    }
    
    mutating func insert(_ newElement: Self.Element, at i: OffsetIndex) {
        return insert(newElement, at: offsetIndices.targetIndex(i))
    }
    
    mutating func insert<C: Collection>(contentsOf newElements: C, at i: OffsetIndex)
        where C.Element == Self.Element {
            return insert(contentsOf: newElements, at: offsetIndices.targetIndex(i))
    }
    
    mutating func remove(at i: OffsetIndex) -> Self.Element {
        return remove(at: offsetIndices.targetIndex(i))
    }
    
    mutating func removeSubrange<R: RangeExpression>(_ bounds: R)
        where R.Bound == OffsetIndex {
            return removeSubrange(offsetIndices.targetRange(bounds))
    }
}
