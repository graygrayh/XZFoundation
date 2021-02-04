//
//  UIDeviceExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/10/10.
//

import UIKit
import AdSupport

public extension XZ where Base: UIDevice {
    
    ///设备唯一标识(读取并存入keychain)
    static var deviceID: String {
        if let deviceId = keychain.get("kDeviceIdentifier"), !deviceId.isEmpty {
            return deviceId
        }else{
            let deviceId = Self.idfvStr
            if keychain.set(deviceId, forKey: "kDeviceIdentifier") {
                // Keychain item is saved successfully
            } else {
                // Report error
                
                //https://developer.apple.com/documentation/security/1542001-security_framework_result_codes
                //keychain.lastResultCode
            }
            return deviceId
        }
    }
    
    static var sessionID: String {
        return UUID().uuidString
    }
    
    static var idfa: UUID? {
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            return ASIdentifierManager.shared().advertisingIdentifier
        }
        return nil
    }
    
    static var idfaStr: String? {
        return Self.idfa?.uuidString
    }
    
    ///同一开发商获得的值唯一，但有几种情况下发生变化，详情查看官方文档
    static var idfv: UUID? {
        return UIDevice.current.identifierForVendor
    }
    
    static var idfvStr: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    
    static var osVersion: String {
        return UIDevice.current.systemVersion
    }
    
    static var brand: String {
        return UIDevice.current.model
    }
    
    static var resolution: String {
        let scale = UIScreen.main.scale
        return "\(Int(UIScreen.xz.width*scale))*\(Int(UIScreen.xz.height*scale))"
    }
    
    static var deviceName: String {
        var simulator: String = ""
        #if targetEnvironment(simulator)
        let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
        simulator = "simulator "
        #else
        var systemInfo: utsname = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce(""){identifier, element in
            guard let value = element.value as? Int8, value != 0 else {return identifier}
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        #endif
        
        switch identifier {
        case "i386", "x86_64":                          return "simulator/sandbox"
        case "iPod5,1":                                 return "\(simulator)iPod Touch 5"
        case "iPod7,1":                                 return "\(simulator)iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "\(simulator)iPhone 4"
        case "iPhone4,1":                               return "\(simulator)iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "\(simulator)iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "\(simulator)iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "\(simulator)iPhone 5s"
        case "iPhone7,2":                               return "\(simulator)iPhone 6"
        case "iPhone7,1":                               return "\(simulator)iPhone 6 Plus"
        case "iPhone8,1":                               return "\(simulator)iPhone 6s"
        case "iPhone8,2":                               return "\(simulator)iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "\(simulator)iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "\(simulator)iPhone 7 Plus"
        case "iPhone8,4":                               return "\(simulator)iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "\(simulator)iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "\(simulator)iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "\(simulator)iPhone X"
        case "iPhone11,2":                              return "\(simulator)iPhone XS"
        case "iPhone11,4", "iPhone11,6":                return "\(simulator)iPhone XS Max"
        case "iPhone11,8":                              return "\(simulator)iPhone XR"
        case "iPhone12,1":                              return "\(simulator)iPhone 11"
        case "iPhone12,3":                              return "\(simulator)iPhone 11 Pro"
        case "iPhone12,5":                              return "\(simulator)iPhone 11 Pro Max"
        case "iPhone12,8":                              return "\(simulator)iPhone SE (2nd generation)"
        case "iPhone13,1":                              return "\(simulator)iPhone 12 mini"
        case "iPhone13,2":                              return "\(simulator)iPhone 12"
        case "iPhone13,3":                              return "\(simulator)iPhone 12 Pro"
        case "iPhone13,4":                              return "\(simulator)iPhone 12 Pro Max"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "\(simulator)iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "\(simulator)iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "\(simulator)iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "\(simulator)iPad Air"
        case "iPad5,3", "iPad5,4":                      return "\(simulator)iPad Air 2"
        case "iPad11,3", "iPad11,4":                    return "\(simulator)iPad Air 3"
        case "iPad13,1", "iPad12,2":                    return "\(simulator)iPad Air 4"
        case "iPad6,11", "iPad6,12":                    return "\(simulator)iPad 5"
        case "iPad7,5", "iPad7,6":                      return "\(simulator)iPad 6"
        case "iPad7,11", "iPad7,12":                    return "\(simulator)iPad 7"
        case "iPad11,6", "iPad11,7":                    return "\(simulator)iPad 8"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "\(simulator)iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "\(simulator)iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "\(simulator)iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "\(simulator)iPad Mini 4"
        case "iPad11,1", "iPad11,2":                    return "\(simulator)iPad Mini 5"
        case "iPad6,3", "iPad6,4":                      return "\(simulator)iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "\(simulator)iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "\(simulator)iPad Pro (12.9-inch) (2nd generation)"
        case "iPad7,3", "iPad7,4":                      return "\(simulator)iPad Pro (10.5-inch)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "\(simulator)iPad Pro (11-inch)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "\(simulator)iPad Pro (12.9-inch) (3rd generation)"
        case "iPad8,9", "iPad8,10":                     return "\(simulator)iPad Pro (11-inch) (2rd generation)"
        case "iPad8,11", "iPad8,12":                    return "\(simulator)iPad Pro (12.9-inch) (4rd generation)"
        case "AppleTV5,3":                              return "\(simulator)Apple TV"
        case "AppleTV6,2":                              return "\(simulator)Apple TV 4K"
        case "AudioAccessory1,1":                       return "\(simulator)HomePod"
        default:                                        return "\(simulator)\(identifier)"
        }
    }
    
}

