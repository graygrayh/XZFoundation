//
//  NetworkUtil.swift
//  XZFoundation
//
//  Created by xzh on 2020/9/20.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation

///https://stackoverflow.com/questions/7946699/iphone-data-usage-tracking-monitoring?answertab=votes#tab-top
public struct DataUsageInfo {
    /// In bytes.
    var wifiReceived: UInt64 = 0
    var wifiSent: UInt64 = 0
    var wirelessWanDataReceived: UInt64 = 0
    var wirelessWanDataSent: UInt64 = 0
    var totalDataReceived: UInt64 {
        get {
            return self.wirelessWanDataReceived + self.wifiReceived
        }
    }
    var totalDataSent: UInt64 {
        get {
            return self.wirelessWanDataSent + self.wifiSent
        }
    }
    

    mutating func updateInfoByAdding(info: DataUsageInfo) {
        wifiSent += info.wifiSent
        wifiReceived += info.wifiReceived
        wirelessWanDataSent += info.wirelessWanDataSent
        wirelessWanDataReceived += info.wirelessWanDataReceived
    }
}

@objc public protocol NetworkSpeedMonitorDelegate: class {
    @objc optional func networkSendingSpeedUpdated(currentSpeed: UInt64)
    @objc optional func networkReceivingSpeedUpdated(currentSpeed: UInt64)
}

public class NetworkSpeedMonitor {
    private static let wwanInterfacePrefix = "pdp_ip"
    private static let wifiInterfacePrefix = "en"
    private var previousSentData: UInt64 = 0
    private var previousReceivedData: UInt64 = 0
    private lazy var observers: NSHashTable<NetworkSpeedMonitorDelegate> = {
        let observers = NSHashTable<NetworkSpeedMonitorDelegate>.weakObjects()
        return observers
    }()
    
    public func addObserver(_ observer: NetworkSpeedMonitorDelegate){
        observers.add(observer)
    }
    
    public func removeObserver(_ observer: NetworkSpeedMonitorDelegate){
        observers.remove(observer)
    }
    
    private init() {
        XZTimerUtil.shared.scheduledTimer(identifier: "NetworkSpeedKey",
                                          start: 0,
                                          interval: 1000,
                                          repeatFlag: true,
                                          increase: true, task: {
                                            for observer in self.observers.allObjects{
                                                if let networkSendingSpeedUpdated = observer.networkSendingSpeedUpdated{
                                                    let totalSent = NetworkSpeedMonitor.getDataUsage().totalDataSent
                                                    guard totalSent > self.previousSentData else { return }
                                                    let differenceSent = totalSent - self.previousSentData
                                                    let sentInKB = differenceSent / 1024
                                                    networkSendingSpeedUpdated(sentInKB)
                                                    self.previousSentData = totalSent
                                                }
                                                
                                                if let networkReceivingSpeedUpdated = observer.networkReceivingSpeedUpdated{
                                                    let totalReceived = NetworkSpeedMonitor.getDataUsage().totalDataReceived
                                                    let differenceReceived = totalReceived - self.previousReceivedData
                                                    let receivedInKB = differenceReceived / 1024
                                                    networkReceivingSpeedUpdated(receivedInKB)
                                                    self.previousReceivedData = totalReceived
                                                }
                                            }
                                          })
    }
    
    public static let shared = NetworkSpeedMonitor()

    public class func getDataUsage() -> DataUsageInfo {
        var interfaceAddresses: UnsafeMutablePointer<ifaddrs>? = nil

        var dataUsageInfo = DataUsageInfo()

        guard getifaddrs(&interfaceAddresses) == 0 else { return dataUsageInfo }

        var pointer = interfaceAddresses
        while pointer != nil {
            guard let info = getDataUsageInfo(from: pointer!) else {
                pointer = pointer!.pointee.ifa_next
                continue
            }
            dataUsageInfo.updateInfoByAdding(info: info)
            pointer = pointer!.pointee.ifa_next
        }

        freeifaddrs(interfaceAddresses)

        return dataUsageInfo
    }

    private class func getDataUsageInfo(from infoPointer: UnsafeMutablePointer<ifaddrs>) -> DataUsageInfo? {
        let pointer = infoPointer

        let name: String! = String(cString: infoPointer.pointee.ifa_name)
        let addr = pointer.pointee.ifa_addr.pointee
        guard addr.sa_family == UInt8(AF_LINK) else { return nil }

        return dataUsageInfo(from: pointer, name: name)
    }

    private class func dataUsageInfo(from pointer: UnsafeMutablePointer<ifaddrs>, name: String) -> DataUsageInfo {
        var networkData: UnsafeMutablePointer<if_data>? = nil
        var dataUsageInfo = DataUsageInfo()

        if name.hasPrefix(wifiInterfacePrefix) {
            networkData = unsafeBitCast(pointer.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)
            dataUsageInfo.wifiSent += UInt64(networkData?.pointee.ifi_obytes ?? 0)
            dataUsageInfo.wifiReceived += UInt64(networkData?.pointee.ifi_ibytes ?? 0)
        } else if name.hasPrefix(wwanInterfacePrefix) {
            networkData = unsafeBitCast(pointer.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)
            dataUsageInfo.wirelessWanDataSent += UInt64(networkData?.pointee.ifi_obytes ?? 0)
            dataUsageInfo.wirelessWanDataReceived += UInt64(networkData?.pointee.ifi_ibytes ?? 0)
        }

        return dataUsageInfo
    }
    
    public func stopMonitor(){
        XZTimerUtil.shared.stopTimer(identifier: "NetworkSpeedKey")
    }
    
}
