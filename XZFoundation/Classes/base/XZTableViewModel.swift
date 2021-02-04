//
//  XZTableViewProxyProtocol.swift
//  XZFoundation
//
//  Created by xzh on 2020/11/16.
//

import UIKit

public typealias XZTableViewConfigClosure = (_ cell: UITableViewCell, _ cellData: Codable, _ indexPath: IndexPath)->Void
public typealias XZTableViewActionClosure = (_ cell: UITableViewCell, _ cellData: Codable, _ indexPath: IndexPath)->Void
public typealias XZTableViewScrolledClosure = (_ cellData: Codable?, _ indexPath: IndexPath?, _ noMore: Bool)->Void

public enum XZTableViewUpdateType{
    case insert, delete, reload
}

public struct XZTableViewSectionModel<M: Codable>{
    public var cellModels: [M]
    public var headerTitle: String!
    public var footerTitle: String!
    public init(cellModels: [M]) {
        self.cellModels = cellModels
    }
}

public protocol XZTableViewModelProtocol: UITableViewDelegate, UITableViewDataSource {
    associatedtype ModelType: Codable
    var cellConfigClosure: XZTableViewConfigClosure? {get set}
    var cellActionClosure: XZTableViewActionClosure? {get set}
    var cellScrolledClosure: XZTableViewScrolledClosure? {get set}
    var sections: [XZTableViewSectionModel<ModelType>]? {get set}
    var cellModels: [ModelType] {get set}
    var tableView: UITableView {get set}
    init(configuration: XZTableViewConfigClosure?, action: XZTableViewActionClosure?, scrolled: XZTableViewScrolledClosure?)
}

open class XZTableViewModel<ModelType: Modelable>:NSObject, XZTableViewModelProtocol{
    
    public var cellConfigClosure: XZTableViewConfigClosure?
    
    public var cellActionClosure: XZTableViewActionClosure?
    
    public var cellScrolledClosure: XZTableViewScrolledClosure?
    
    public var sections: [XZTableViewSectionModel<ModelType>]?
    public var cellModels: [ModelType] = [ModelType]()
    
    public lazy var tableView: UITableView = {
        let tempTableView = UITableView(frame: CGRect.zero, style: .plain)
        tempTableView.separatorStyle = .none
        tempTableView.delegate = self
        tempTableView.dataSource = self
        return tempTableView
    }()
    
    public required init(configuration: XZTableViewConfigClosure?, action: XZTableViewActionClosure?=nil, scrolled: XZTableViewScrolledClosure?=nil) {
        cellConfigClosure = configuration
        cellActionClosure = action
        cellScrolledClosure = scrolled
        super.init()
    }
    
    open func configureViews(){
        
    }
    
    open func loadDataSource(loadMore: Bool=false ,completion: (([ModelType]?, Error?)->Void)?){
        
    }
    
    // 追加数据源
    public func appendModels(with newValues: [ModelType], section: Int = 0){
        if newValues.count == 0 {return}
        var indexPaths: [IndexPath] = [IndexPath]()
        for index in 0..<newValues.count{
            let newIndex = cellModels.count + index
            indexPaths.append(IndexPath(row: newIndex, section: section))
        }
        cellModels.append(contentsOf: newValues)
        updateTableView(at: indexPaths, updateType: .insert, animate: .none)
    }
    
    /// - Parameter indexPaths: 插入/删除,indexPath与sections两者只有一个，或者两者都没有
    /// - Parameter secitons: 同上
    /// - Parameter updateType: 更新类型插入、删除、刷新
    /// - Parameter synchronousExecution: 闭包，包含需要同时执行的操作
    /// - Parameter animate: 是否需要动画
    /// - Parameter completion: 完成回调
    public func updateTableView(at indexPaths: [IndexPath]?=nil,
                                sections: IndexSet?=nil,
                                updateType: XZTableViewUpdateType = .reload,
                                animate: UITableView.RowAnimation = .none,
                                synchronousExecution: XZVoidClosure?=nil){
        if indexPaths == nil && sections == nil && updateType != .reload{return}
        synchronousExecution?()
        if Thread.isMainThread {
            if indexPaths == nil && sections == nil && updateType == .reload{
                self.tableView.reloadData()
            }else{
                self.updateTableViewUI(at: indexPaths, sections: sections, updateType: updateType, with: animate)
            }
        }else{
            DispatchQueue.main.async {
                if indexPaths == nil && sections == nil && updateType == .reload{
                    self.tableView.reloadData()
                }else{
                    self.updateTableViewUI(at: indexPaths, sections: sections, updateType: updateType, with: animate)
                }
            }
        }
    }
    
    private func updateTableViewUI(at indexPaths: [IndexPath]?=nil,
                                   sections: IndexSet?=nil,
                                   updateType: XZTableViewUpdateType = .insert,
                                   with animation: UITableView.RowAnimation,
                                   synchronousExecution: XZVoidClosure?=nil){
        self.tableView.beginUpdates()
        switch updateType {
        case .insert:
            if let tempIndexPaths = indexPaths {
                self.tableView.insertRows(at: tempIndexPaths, with: animation)
            }else if let tempSections = sections{
                self.tableView.insertSections(tempSections, with: animation)
            }
        case .delete:
            if let tempIndexPaths = indexPaths{
                self.tableView.deleteRows(at: tempIndexPaths, with: animation)
            }else if let tempSections = sections{
                self.tableView.deleteSections(tempSections, with: animation)
            }
        case .reload:
            if let tempIndexPaths = indexPaths {
                self.tableView.reloadRows(at: tempIndexPaths, with: animation)
            }else if let tempSections = sections{
                self.tableView.reloadSections(tempSections, with: animation)
            }
        }
        self.tableView.endUpdates()
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return sections?.count ?? 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tempSections = sections{
            return tempSections[section].cellModels.count
        }
        return cellModels.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            if let tempDatas = sections?[indexPath.section].cellModels{
                cellActionClosure?(cell, tempDatas[indexPath.row], indexPath)
            }else {
                cellActionClosure?(cell, cellModels[indexPath.row], indexPath)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 10
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        
    }
    
    open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        
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



