//
//  UICollectionViewExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/9.
//  Copyright © 2020 xzh. All rights reserved.
//

import UIKit

public extension XZ where Base: UICollectionView {
    
    /// Index of last section in collectionView
    var lastSection: Int {
        return base.numberOfSections > 0 ? base.numberOfSections - 1 : 0
    }
    
    /// Number of all items in all sections of collectionView
    func numberOfAllItems() -> Int {
        var section = 0
        var itemsCount = 0
        while section < base.numberOfSections {
            itemsCount += base.numberOfItems(inSection: section)
            section += 1
        }
        return itemsCount
    }
    
    var currentFocusedIndexPath: IndexPath? {
        if numberOfAllItems() == 0 {
            return nil
        }
        let p = CGPoint(x: base.center.x, y: base.center.y)
        if let pointIn = base.superview?.convert(p, to: base) {
            if let centerIndexPath = base.indexPathForItem(at: pointIn) {
                return centerIndexPath
            }
        }
        return nil
    }
    
    /// Index path of last item in collectionView
    var indexPathForLastItem: IndexPath? {
        return indexPathForLastItem(inSection: lastSection)
    }
    
    /// IndexPath for last item in section
    func indexPathForLastItem(inSection section: Int) -> IndexPath? {
        guard section >= 0 else {
            return nil
        }
        guard section < base.numberOfSections else {
            return nil
        }
        guard base.numberOfItems(inSection: section) > 0 else {
            return IndexPath(item: 0, section: section)
        }
        return IndexPath(item: base.numberOfItems(inSection: section) - 1, section: section)
    }
    
    func safeScrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard let validIndexPath = isValidIndexPath(indexPath) else {
            return
        }
        base.scrollToItem(at: validIndexPath, at: scrollPosition, animated: animated)
    }
    
    /// Check whether IndexPath is valid within the CollectionView
    /// - Returns: valid IndexPath or nil
    func isValidIndexPath(_ indexPath: IndexPath?) -> IndexPath? {
        guard let idxpath = indexPath else {
            return nil
        }
        if idxpath.section >= 0 &&
            idxpath.item >= 0 &&
            idxpath.section < base.numberOfSections &&
            idxpath.item < base.numberOfItems(inSection: idxpath.section) {
            return idxpath
        }
        return nil
    }
    
    func reloadVisibleItems(animated: Bool = true) {
        let indexPaths = base.indexPathsForVisibleItems
        if indexPaths.count <= 0 {return}
        if animated {
            base.reloadItems(at: indexPaths)
        } else {
            UIView.performWithoutAnimation {
                base.reloadItems(at: indexPaths)
            }
        }
    }
    
}

extension UICollectionReusableView: Reuseable{}
public extension XZ where Base: UICollectionView{
    
    func registReuseableCell<Cell: UICollectionViewCell>(_: Cell.Type){
        base.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
    }
    
    func registReuseableNibCell<Cell: UICollectionViewCell>(_: Cell.Type){
        return base.register(UINib(nibName: Cell.reuseIdentifier, bundle: Bundle(for: Cell.self)), forCellWithReuseIdentifier: Cell.reuseIdentifier)
    }
    
    func dequeueReuseableCell<Cell: UICollectionViewCell>(indexPath: IndexPath) -> Cell{
        if let cell = base.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell{
            return cell
        }
        print("Error dequeueReusableCell for [\(Cell.reuseIdentifier)] at [\(indexPath)] ")
        return Cell()
    }
    
    func registerClassReuseView<ReuseView: UICollectionReusableView>(_: ReuseView.Type, forKind kind: String) {
        base.register(ReuseView.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: ReuseView.reuseIdentifier)
    }
    
    func registerNibReuseView<ReuseView: UICollectionReusableView>(_: ReuseView.Type, forKind kind: String) {
        base.register(UINib(nibName: ReuseView.reuseIdentifier, bundle: Bundle(for: ReuseView.self)), forSupplementaryViewOfKind: kind, withReuseIdentifier: ReuseView.reuseIdentifier)
    }
    
    func dequeueReuseView<ReuseView: UICollectionReusableView>(forIndexPath indexPath: IndexPath, forKind kind: String) -> ReuseView {
        if let reuseView = base.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ReuseView.reuseIdentifier, for: indexPath) as? ReuseView {
            return reuseView
        }
        print("Error dequeueReusableSupplementaryView for [\(ReuseView.reuseIdentifier)] at [\(indexPath)] ")
        return ReuseView()
    }
    
}
