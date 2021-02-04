//
//  XZKeychainHelper.swift
//  XZFoundation
//
//  Created by xzh on 2020/11/1.
//

import Foundation


public enum XZKeychainAccessOptions {
  
  // 只有当用户解锁设备时，才能访问密钥链项中的数据。
  // 对于仅当应用程序处于前台时才需要访问的项，建议使用此选项。使用加密备份时，具有此属性的项目将迁移到新设备。
  // 这是未显式设置可访问性常量而添加的keychain项的默认值。
  case accessibleWhenUnlocked
  
  // 只有当用户解锁设备时，才能访问密钥链项中的数据。
  // 对于仅当应用程序处于前台时才需要访问的项，建议使用此选项。具有此属性的项目不会迁移到新设备。
  // 因此，从不同设备的备份恢复后，这些项将不存在。
  case accessibleWhenUnlockedThisDeviceOnly
  
  // 重新启动后，在用户解锁设备之前，无法访问密钥链项中的数据。
  // 在第一次解锁后，数据在下次重新启动之前保持可访问状态。对于需要后台应用程序访问的项目，建议使用此选项。
  // 使用加密备份时，具有此属性的项目将迁移到新设备。
  case accessibleAfterFirstUnlock
  
  // 重新启动后，在用户解锁设备之前，无法访问密钥链项中的数据。
  // 在第一次解锁后，数据在下次重新启动之前保持可访问状态。对于需要后台应用程序访问的项目，建议使用此选项。
  // 具有此属性的项目不会迁移到新设备。因此，从不同设备的备份恢复后，这些项将不存在。
  case accessibleAfterFirstUnlockThisDeviceOnly

  
  // 钥匙链中的数据只能在设备解锁时访问。只有在设备上设置了密码时才可用。
  // 对于只有在应用程序处于前台时才需要访问的项，建议使用此选项。具有此属性的项目永远不会迁移到新设备。
  // 将备份还原到新设备后，这些项目将丢失。在没有密码的设备上，不能在此类中存储任何项。禁用设备密码会导致删除此类中的所有项。
  case accessibleWhenPasscodeSetThisDeviceOnly
  
  static var defaultOption: XZKeychainAccessOptions {
    return .accessibleWhenUnlocked
  }
  
  var value: String {
    switch self {
    case .accessibleWhenUnlocked:
      return toString(kSecAttrAccessibleWhenUnlocked)
      
    case .accessibleWhenUnlockedThisDeviceOnly:
      return toString(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
      
    case .accessibleAfterFirstUnlock:
      return toString(kSecAttrAccessibleAfterFirstUnlock)
      
    case .accessibleAfterFirstUnlockThisDeviceOnly:
      return toString(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
      
    case .accessibleWhenPasscodeSetThisDeviceOnly:
      return toString(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
    }
  }
  
  func toString(_ value: CFString) -> String {
    return XZKeychainConstants.toString(value)
  }
}

public struct XZKeychainConstants {
  //指定密钥链访问组，用于在APP间共享数据
  public static var accessGroup: String { return toString(kSecAttrAccessGroup) }
  
  //指示应用程序何时需要访问密钥链中的数据，默认AccessibleWhenUnlocked
  public static var accessible: String { return toString(kSecAttrAccessible) }
  
  // 用于在设置/获取Keychain值时指定字符串键
  public static var attrAccount: String { return toString(kSecAttrAccount) }

  // 用于指定设备之间密钥链项的同步
  public static var attrSynchronizable: String { return toString(kSecAttrSynchronizable) }
  
  //构造密钥搜索字典键值
  public static var klass: String { return toString(kSecClass) }
  
  //指定从键链返回值的数目，仅支持单个值
  public static var matchLimit: String { return toString(kSecMatchLimit) }
  
  //从keychain获取数据的返回类型
  public static var returnData: String { return toString(kSecReturnData) }
  
  //设置keychain指定值
  public static var valueData: String { return toString(kSecValueData) }
    
  //从用于引用的键链数据返回值
  public static var returnReference: String { return toString(kSecReturnPersistentRef) }
  
  //是否返回项属性
  public static var returnAttributes : String { return toString(kSecReturnAttributes) }
    
  //匹配无限数量项值
  public static var secMatchLimitAll : String { return toString(kSecMatchLimitAll) }
    
  static func toString(_ value: CFString) -> String {
    return value as String
  }
}
