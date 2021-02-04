//
//  LKPermissionTool.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/14.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation
import UIKit
import Photos
import AVFoundation
import CoreLocation

public typealias LKPermisionResAction = (_ granted: Bool) -> Void

public class LKPermissionTool: NSObject {
    public static let shared = LKPermissionTool()
    private override init() { super.init() }
    
    public static let cancel = "取消"
    public static let goSetting = "去设置"
}

public extension LKPermissionTool {
    
    class func requestPhotoLibraryAccess(permissionRes: LKPermisionResAction?) {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            DispatchQueue.main.async {
                permissionRes?(true)
            }
            return
        }
        
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async {
                permissionRes?(status == .authorized)
            }
        }
    }
    
    class func requestVideoCapture(permissionRes: LKPermisionResAction?) {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            DispatchQueue.main.async {
                permissionRes?(granted)
            }
        }
    }
    
    class func requestAudioCapture(permissionRes: LKPermisionResAction?) {
        AVCaptureDevice.requestAccess(for: .audio) { (granted) in
            DispatchQueue.main.async {
                permissionRes?(granted)
            }
        }
    }
    
    class func requestNotificationAccess(permissionRes: LKPermisionResAction?) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { (granted, err) in
                DispatchQueue.main.async {
                    permissionRes?(granted)
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
}

public extension LKPermissionTool {
    class func openSetting() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                }else{
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    class func alertAudioCapture() {
        let title = "未获得麦克风权限"
        let msg = "是否去设置-隐私-麦克风中授予\(Bundle.xz.appDisplayName)该权限？"
        UIAlertController.xz.showWithSystemStyle(title: title, msg: msg, buttons: [cancel, goSetting]) { (btnTitle) in
            if btnTitle == goSetting {
                if AVCaptureDevice.authorizationStatus(for: .audio) == .notDetermined{
                    requestAudioCapture(permissionRes: nil)
                }else{
                    openSetting()
                }
            }
        }
    }
    
    class func alertCameraAccess() {
        let title = "未获得相机权限"
        let msg = "是否去设置-隐私-相机中授予\(Bundle.xz.appDisplayName)该权限？"
        UIAlertController.xz.showWithSystemStyle(title: title, msg: msg, buttons: [cancel, goSetting]) { (btnTitle) in
            if btnTitle == goSetting {
                if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined{
                    requestVideoCapture(permissionRes: nil)
                }else{
                    openSetting()
                }
            }
        }
    }
    
    class func alertPhotoLibraryAccess() {
        let title = "未获得访问相册的权限"
        let msg = "是否去设置-隐私-相册中授予\(Bundle.xz.appDisplayName)该权限？"
        UIAlertController.xz.showWithSystemStyle(title: title, msg: msg, buttons: [cancel, goSetting]) { (btnTitle) in
            if btnTitle == goSetting {
                if PHPhotoLibrary.authorizationStatus() == .notDetermined{
                    requestPhotoLibraryAccess(permissionRes: nil)
                }else{
                    openSetting()
                }
            }
        }
    }
}

public extension LKPermissionTool {
    
    class func isLocationGranted() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        var granted = false
        switch status {
        case .notDetermined, .denied, .restricted:
            granted = false
        case .authorizedAlways, .authorizedWhenInUse:
            granted = true
        default:
            granted = false
        }
        return granted
    }
    
    class func isPhotoLibraryAccessOK() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .denied || status == .notDetermined{
            return false
        }
        return true
    }
    
    class func isCaptureVideoAccessOK() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .denied || status == .restricted || status == .notDetermined {
            return false
        }
        return true
    }
    
    class func isCaptureAudioAccessOK() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .denied || status == .restricted || status == .notDetermined{
            return false
        }
        return true
    }
    
//    class func isLocationAccessOK() -> Bool {
//
//    }
}
