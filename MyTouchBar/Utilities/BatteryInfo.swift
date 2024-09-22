//
//  BatteryInfo.swift
//  MyTouchBar
//
//  Created by Moses Mok on 12/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import Cocoa
import IOKit

// Swift doesn't support nested protocol(?!)
protocol BatteryInfoObserverProtocol: AnyObject {
    func batteryInfo(didChange info: BatteryInfo)
}

class BatteryInfo {
    typealias ObserverProtocol = BatteryInfoObserverProtocol
    struct Observation {
        weak var observer: ObserverProtocol?
    }
    class EstimatedTimeCalculatingError: Error {}
    
    static let shared = BatteryInfo()
    private init() {}
    
    private var notificationSource: CFRunLoopSource?
    var observers = [ObjectIdentifier: Observation]()
    
    private func startNotificationSource() {
        if notificationSource != nil {
            stopNotificationSource()
        }
        notificationSource = IOPSNotificationCreateRunLoopSource({ _ in
            BatteryInfo.shared.observers.forEach { (_, value) in
                value.observer?.batteryInfo(didChange: BatteryInfo.shared)
            }
        }, nil).takeRetainedValue() as CFRunLoopSource
        CFRunLoopAddSource(CFRunLoopGetCurrent(), notificationSource, .defaultMode)
    }
    private func stopNotificationSource() {
        guard let loop = notificationSource else { return }
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), loop, .defaultMode)
    }
    
    func addObserver(_ observer: ObserverProtocol) {
        if observers.count == 0 {
            startNotificationSource()
        }
        observers[ObjectIdentifier(observer)] = Observation(observer: observer)
    }
    func removeObserver(_ observer: ObserverProtocol) {
        observers.removeValue(forKey: ObjectIdentifier(observer))
        if observers.count == 0 {
            stopNotificationSource()
        }
    }
    
    func getBatteryDescription() -> [String: AnyObject] {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        let ps = sources[0]
        let info = ps as! [String: AnyObject]

        return info
    }
    
    func getLevel() -> Double {
        let info = getBatteryDescription()
        let capacity = info[kIOPSCurrentCapacityKey] as! Double
        let max = info[kIOPSMaxCapacityKey] as! Double
        let battery = capacity / max

        return battery
    }
    func getIsCharging() -> Bool {
        let info = getBatteryDescription()
        let isCharging = info[kIOPSIsChargingKey] as! Bool
        return isCharging
    }
    func getIsCharged() -> Bool {
        let info = getBatteryDescription()
        let isCharged = info[kIOPSIsChargedKey] as? Bool ?? false
        return isCharged
    }
    func getMinutesUntilEmpty() throws -> Int {
        let info = getBatteryDescription()
        let timeRemaining = info[kIOPSTimeToEmptyKey] as! Int
        if timeRemaining == -1 {
            throw EstimatedTimeCalculatingError()
        }
        return timeRemaining
    }
    func getMinutesUntilFull() throws -> Int {
        let info = getBatteryDescription()
        let timeRemaining = info[kIOPSTimeToFullChargeKey] as! Int
        if timeRemaining == -1 {
            throw EstimatedTimeCalculatingError()
        }
        return timeRemaining
    }
    
    
}
