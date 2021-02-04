//
//  FileManagerExtension.swift
//  XZFoundation
//
//  Created by xzh on 2020/9/1.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation

public extension XZ where Base: FileManager{
    
    static func homePath(pathComponent: String? = nil) -> String{
        if let component = pathComponent {
            return NSHomeDirectory() + "/\(component)"
        }
        return NSHomeDirectory()
    }
    
    static func docPath(pathComponent: String? = nil) -> String?{
        var document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        if let component = pathComponent, let tempDocument = document {
            document = "\(tempDocument)/\(component)"
        }
        return document
    }
    
    static func docPathURL(pathComponent: String, isDir: Bool = true) -> URL {
        guard let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            fatalError("docPathURL is nil")
        }
        return url.appendingPathComponent(pathComponent, isDirectory: isDir)
    }
    
    static func cachePath(componentPath: String? = nil) -> String?{
        var cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        if let component = componentPath, let cacheDir = cachePath {
            cachePath = "\(cacheDir)/\(component)"
        }
        return cachePath
    }
    
    static func cachePathURL(pathComponent: String? = nil, isDir: Bool = true) -> URL {
        guard let url = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            fatalError("docPathURL is nil")
        }
        if let component = pathComponent {
            return url.appendingPathComponent(component, isDirectory: isDir)
        }
        return url
    }
    
    static func temporaryPath(componentPath: String? = nil) -> String{
        if let component = componentPath {
            return NSTemporaryDirectory() + "/\(component)"
        }
        return NSTemporaryDirectory()
    }
    
    ///草稿目录
    static var draftHomeURL: URL{
        return docPathURL(pathComponent: "draftHome")
    }
    
    // 创建新目录
    @discardableResult
    static func createNewDirectory(dirPath: String) -> Bool{
        
        let fileMgr = FileManager.default
        var existFlag: ObjCBool = false
        
        if fileMgr.fileExists(atPath: dirPath, isDirectory: &existFlag) && existFlag.boolValue {
            return true
        }else{
            do {
                try fileMgr.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch  {
                return false
            }
        }
        
    }
    
    // 删除文件
    @discardableResult
    static func delete(file path: String) -> Bool{
        if Base.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
                return true
            } catch _ {
                
            }
        }
        return false
    }
    
}
