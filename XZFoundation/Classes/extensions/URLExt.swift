//
//  URLExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/10/9.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation

extension URL: XZCompatible{}
public extension XZ where Base == URL{
    
    var data: Data?{
        return try? Data(contentsOf: self.base, options: .mappedIfSafe)
    }
    
    var etag: String?{
        if let tempData = data {
            return tempData.xz.etag
        }
        return nil
    }
    
}
