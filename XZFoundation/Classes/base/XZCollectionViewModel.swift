//
//  XZCollectionViewModel.swift
//  XZFoundation
//
//  Created by xzh on 2020/11/16.
//  Copyright © 2020 xiaoniangao. All rights reserved.
//

import UIKit

public typealias XZCollectionViewConfigClosure = (_ cell: UICollectionViewCell, _ cellData: Codable, _ indexPath: IndexPath)->Void
public typealias XZCollectionViewActionClosure = (_ cell: UICollectionViewCell, _ cellData: Codable, _ indexPath: IndexPath)->Void
public typealias XZCollectionViewScrolledClosure = (_ cellData: Codable?, _ indexPath: IndexPath?, _ noMore: Bool)->Void
public typealias XZCollectionViewLayoutClosure = ()->UICollectionViewLayout

public enum XZCollectionViewUpdateType{
    case insert, delete, reload
}

public struct XZCollectionViewSectionModel<M: Codable>{
    public var cellModels: [M]
    public var headerTitle: String!
    public var footerTitle: String!
    public init(cellModels: [M]) {
        self.cellModels = cellModels
    }
}

public protocol Modelable: Codable {
    // 标记唯一标识，用于删除或者其他
    var identifier: String{get}
    // 类型
    var modelType: String{get}
}

public extension Modelable{
    var identifier: String{
        return ""
    }
    var modelType: String{
        return String(describing: Self.self)
    }
}

open class XZBaseModel: Modelable{}

public protocol XZCollectionViewModelProtocol: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    associatedtype ModelType: Codable
    var cellConfigClosure: XZCollectionViewConfigClosure? {get set}
    var cellActionClosure: XZCollectionViewActionClosure? {get set}
    var cellScrolledClosure: XZCollectionViewScrolledClosure? {get set}
    var sections: [XZCollectionViewSectionModel<ModelType>]? {get set}
    var cellModels: [ModelType] {get set}
    var collectionView: UICollectionView {get set}
    var viewLayout: UICollectionViewLayout {get set}
    init(configuration: XZCollectionViewConfigClosure?, action: XZCollectionViewActionClosure?, scrolled: XZCollectionViewScrolledClosure?, layoutClosure: @escaping XZCollectionViewLayoutClosure)
}



open class XZCollectionViewModel<ModelType: Modelable>:NSObject, XZCollectionViewModelProtocol{
    
    public var cellConfigClosure: XZCollectionViewConfigClosure?
    public var cellActionClosure: XZCollectionViewActionClosure?
    public var cellScrolledClosure: XZCollectionViewScrolledClosure?
    
    public var sections: [XZCollectionViewSectionModel<ModelType>]?
    public var cellModels: [ModelType] = [ModelType]()
    public var viewLayout: UICollectionViewLayout
    
    public lazy var collectionView: UICollectionView = {
        let tempCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: viewLayout)
        tempCollectionView.delegate = self
        tempCollectionView.dataSource = self
        return tempCollectionView
    }()
    
    public required init(configuration: XZCollectionViewConfigClosure?, action: XZCollectionViewActionClosure?, scrolled: XZCollectionViewScrolledClosure?=nil, layoutClosure: @escaping XZCollectionViewLayoutClosure) {
        cellConfigClosure = configuration
        cellActionClosure = action
        cellScrolledClosure = scrolled
        viewLayout = layoutClosure()
        super.init()
    }
    
    open func configureViews(){
        
    }
    
    open func loadDataSource(loadMore: Bool=false, completion: (([ModelType]?, Error?)->Void)?){
        
    }
    
    // 追加数据源
    public func appendModels(with newValues: [ModelType], section: Int = 0, synchronousExecution: XZVoidClosure?=nil, completion: XZBoolClosure?=nil){
        if newValues.count == 0 {return}
        var indexPaths: [IndexPath] = [IndexPath]()
        for index in 0..<newValues.count{
            let newIndex = cellModels.count + index
            indexPaths.append(IndexPath(item: newIndex, section: section))
        }
        collectionView.performBatchUpdates({
            synchronousExecution?()
            cellModels.append(contentsOf: newValues)
            collectionView.insertItems(at: indexPaths)
        }, completion: completion)
    }
    
    // 删除数据源
    public func deleteModels(with deleteValues: [ModelType], section: Int = 0, synchronousExecution: ((_ indexPaths: [IndexPath])->Void)?=nil, completion: XZBoolClosure?=nil){
        if deleteValues.count <= 0 {return}
        if deleteValues[0].identifier.isEmpty{return}
        var deleteDict: [String:Any] = [String:Any]()
        var indexPaths: [IndexPath] = [IndexPath]()
        deleteValues.forEach{deleteDict[$0.identifier] = $0}
        for index in 0..<cellModels.count {
            let model = cellModels[index]
            if deleteDict[model.identifier] != nil {
                indexPaths.append(IndexPath(item: index, section: section))
            }
        }
        collectionView.performBatchUpdates({
            synchronousExecution?(indexPaths)
            cellModels = cellModels.filter{deleteDict[$0.identifier] == nil}
            collectionView.deleteItems(at: indexPaths)
        }, completion: completion)
        
    }
    
    /// - Parameter indexPaths: 插入/删除,indexPath与sections两者只有一个，或者两者都没有
    /// - Parameter secitons: 同上
    /// - Parameter updateType: 更新类型插入、删除、刷新
    /// - Parameter synchronousExecution: 闭包，包含需要同时执行的操作
    /// - Parameter animate: 是否需要动画
    /// - Parameter completion: 完成回调
    public func updateCollectionView(at indexPaths: [IndexPath]?=nil,
                                     secitons: IndexSet?=nil,
                                     updateType: XZCollectionViewUpdateType = .reload,
                                     synchronousExecution: XZVoidClosure?=nil,
                                     completion: XZBoolClosure?=nil){
        if indexPaths == nil && secitons == nil && updateType != .reload{return}
        if Thread.isMainThread {
            if indexPaths == nil && secitons == nil && updateType == .reload {
                self.updateOperation(at: indexPaths, sections: secitons, updateType: updateType, synchronousExecution: synchronousExecution)
                completion?(true)
            }else{
                self.collectionView.performBatchUpdates({
                    self.updateOperation(at: indexPaths, sections: secitons, updateType: updateType, synchronousExecution: synchronousExecution)
                }, completion: completion)
            }
        }else{
            DispatchQueue.main.async {
                if indexPaths == nil && secitons == nil && updateType == .reload {
                    self.updateOperation(at: indexPaths, sections: secitons, updateType: updateType, synchronousExecution: synchronousExecution)
                    completion?(true)
                }else{
                    self.collectionView.performBatchUpdates({
                        self.updateOperation(at: indexPaths, sections: secitons, updateType: updateType, synchronousExecution: synchronousExecution)
                    }, completion: completion)
                }
            }
        }
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections?.count ?? 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let tempSections = sections{
            return tempSections[section].cellModels.count
        }
        return cellModels.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            if let tempDatas = sections?[indexPath.section].cellModels{
                cellActionClosure?(cell, tempDatas[indexPath.row], indexPath)
            }else {
                cellActionClosure?(cell, cellModels[indexPath.row], indexPath)
            }
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    open func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        
    }
    
    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
}

extension XZCollectionViewModel{
    // 执行具体更新操作
    private func updateOperation(at indexPaths: [IndexPath]?=nil,
                                        sections: IndexSet?=nil,
                                        updateType: XZCollectionViewUpdateType = .insert,
                                        synchronousExecution: XZVoidClosure?=nil){
        synchronousExecution?()
        switch updateType {
        case .insert:
            if let tempIndexPaths = indexPaths {
                self.collectionView.insertItems(at: tempIndexPaths)
            }else if let tempSections = sections{
                self.collectionView.insertSections(tempSections)
            }
        case .delete:
            if let tempIndexPaths = indexPaths {
                self.collectionView.deleteItems(at: tempIndexPaths)
            }else if let tempSections = sections{
                self.collectionView.deleteSections(tempSections)
            }
        case .reload:
            if let tempSections = sections{
                self.collectionView.reloadSections(tempSections)
            }else if let tempIndexPaths = indexPaths{
                self.collectionView.reloadItems(at: tempIndexPaths)
            }else{
                self.collectionView.reloadData()
            }
        }
    }
    
}
