//
//  UITableViewCellExtension.swift
//  XZFoundation
//
//  Created by xzh on 2020/9/3.
//  Copyright © 2020 xzh. All rights reserved.
//

import UIKit

extension UITableViewCell: Reuseable{}

public extension XZ where Base: UITableView{
    
    func registReuseableCell<Cell: UITableViewCell>(_: Cell.Type){
        base.register(Cell.self, forCellReuseIdentifier: Cell.reuseIdentifier)
    }
    
    func registReuseableNibCell<Cell: UITableViewCell>(_: Cell.Type){
        return base.register(UINib(nibName: Cell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: Cell.reuseIdentifier)
    }
    
    func dequeueReuseableCell<Cell: UITableViewCell>(indexPath: IndexPath) -> Cell{
        if let cell = base.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell{
            return cell
        }
        print("Error dequeueReusableCell for [\(Cell.reuseIdentifier)] at [\(indexPath)] ")
        return Cell()
    }
    
}
