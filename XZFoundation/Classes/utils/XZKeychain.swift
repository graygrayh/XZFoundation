//
//  XZKeyChain.swift
//  XZFoundation
//
//  Created by xzh on 2020/11/1.
//

import Foundation
import Security

open class XZKeychain {
  
  var lastQueryParameters: [String: Any]?
  
  
  open var lastResultCode: OSStatus = noErr

  // 密钥前缀
  var keyPrefix = ""
  
  //应用程序共享密钥链访问组
  open var accessGroup: String?
  // 是否可以通过iCloud与其他设备同步，默认false
  open var synchronizable: Bool = false

  private let lock = NSLock()

  public init() { }
  
  public init(keyPrefix: String) {
    self.keyPrefix = keyPrefix
  }
  
  // 将文本值存储在给定键下的keychain中, true 成功，false 失败
  @discardableResult
  open func set(_ value: String, forKey key: String,
                  withAccess access: XZKeychainAccessOptions? = nil) -> Bool {
    
    if let value = value.data(using: String.Encoding.utf8) {
      return set(value, forKey: key, withAccess: access)
    }
    
    return false
  }

  // 将二进制数据存储在给定键下的keychain中, true 成功，false 失败
  @discardableResult
  open func set(_ value: Data, forKey key: String,
    withAccess access: XZKeychainAccessOptions? = nil) -> Bool {
    lock.lock();defer { lock.unlock() }
    
    deleteNoLock(key) // Delete any existing key before saving it
    let accessible = access?.value ?? XZKeychainAccessOptions.defaultOption.value
      
    let prefixedKey = keyWithPrefix(key)
      
    var query: [String : Any] = [
        XZKeychainConstants.klass       : kSecClassGenericPassword,
        XZKeychainConstants.attrAccount : prefixedKey,
        XZKeychainConstants.valueData   : value,
        XZKeychainConstants.accessible  : accessible
    ]
      
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: true)
    lastQueryParameters = query
    
    lastResultCode = SecItemAdd(query as CFDictionary, nil)
    
    return lastResultCode == noErr
  }

  // 将布尔值数据存储在给定键下的keychain中, true 成功，false 失败
  @discardableResult
  open func set(_ value: Bool, forKey key: String,
    withAccess access: XZKeychainAccessOptions? = nil) -> Bool {
  
    let bytes: [UInt8] = value ? [1] : [0]
    let data = Data(bytes)

    return set(data, forKey: key, withAccess: access)
  }

  // 从给定的键对应的键链中获取文本
  open func get(_ key: String) -> String? {
    if let data = getData(key) {
      
      if let currentString = String(data: data, encoding: .utf8) {
        return currentString
      }
      
      lastResultCode = -67853 // errSecInvalidEncoding
    }

    return nil
  }

  // 从给定的键对应的键链中获取Data数据
  open func getData(_ key: String, asReference: Bool = false) -> Data? {
    
    lock.lock();defer { lock.unlock() }
    
    let prefixedKey = keyWithPrefix(key)
    
    var query: [String: Any] = [
        XZKeychainConstants.klass       : kSecClassGenericPassword,
        XZKeychainConstants.attrAccount : prefixedKey,
        XZKeychainConstants.matchLimit  : kSecMatchLimitOne
    ]
    
    if asReference {
        query[XZKeychainConstants.returnReference] = kCFBooleanTrue
    } else {
        query[XZKeychainConstants.returnData] =  kCFBooleanTrue
    }
    
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: false)
    lastQueryParameters = query
    
    var result: AnyObject?
    
    lastResultCode = withUnsafeMutablePointer(to: &result) {
      SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
    }
    
    if lastResultCode == noErr {
      return result as? Data
    }
    
    return nil
  }

  // 从给定的键对应的键链中获取布尔值
  open func getBool(_ key: String) -> Bool? {
    guard let data = getData(key) else { return nil }
    guard let firstBit = data.first else { return nil }
    return firstBit == 1
  }

  // 根据指定的key从键链中删除对应数据
  @discardableResult
  open func delete(_ key: String) -> Bool {
    lock.lock();defer { lock.unlock() }
    
    return deleteNoLock(key)
  }
  
  // 获取键链中所有数据
  public var allKeys: [String] {
    var query: [String: Any] = [
        XZKeychainConstants.klass : kSecClassGenericPassword,
        XZKeychainConstants.returnData : true,
        XZKeychainConstants.returnAttributes: true,
        XZKeychainConstants.returnReference: true,
        XZKeychainConstants.matchLimit: XZKeychainConstants.secMatchLimitAll
    ]
  
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: false)

    var result: AnyObject?

    let lastResultCode = withUnsafeMutablePointer(to: &result) {
      SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
    }
    
    if lastResultCode == noErr {
      return (result as? [[String: Any]])?.compactMap {
        $0[XZKeychainConstants.attrAccount] as? String } ?? []
    }
    
    return []
  }
    
  // 非线程安全删除
  @discardableResult
  func deleteNoLock(_ key: String) -> Bool {
    let prefixedKey = keyWithPrefix(key)
    
    var query: [String: Any] = [
        XZKeychainConstants.klass       : kSecClassGenericPassword,
        XZKeychainConstants.attrAccount : prefixedKey
    ]
    
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: false)
    lastQueryParameters = query
    
    lastResultCode = SecItemDelete(query as CFDictionary)
    
    return lastResultCode == noErr
  }

  // 从keychain清除所有数据
  @discardableResult
  open func clear() -> Bool {
    lock.lock();defer { lock.unlock() }
    
    var query: [String: Any] = [ kSecClass as String : kSecClassGenericPassword ]
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: false)
    lastQueryParameters = query
    
    lastResultCode = SecItemDelete(query as CFDictionary)
    
    return lastResultCode == noErr
  }
  
  // 返回键值前缀
  func keyWithPrefix(_ key: String) -> String {
    return "\(keyPrefix)\(key)"
  }
  
  func addAccessGroupWhenPresent(_ items: [String: Any]) -> [String: Any] {
    guard let accessGroup = accessGroup else { return items }
    
    var result: [String: Any] = items
    result[XZKeychainConstants.accessGroup] = accessGroup
    return result
  }
  
  // 当“synchronizable”属性为true时，将kSecAttrSynchronizable:ksecattrsynchronizabley`项添加到字典中。
  //否则，它将返回原始词典。
  func addSynchronizableIfRequired(_ items: [String: Any], addingItems: Bool) -> [String: Any] {
    if !synchronizable { return items }
    var result: [String: Any] = items
    result[XZKeychainConstants.attrSynchronizable] = addingItems == true ? true : kSecAttrSynchronizableAny
    return result
  }
}
