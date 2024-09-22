//
//  HapticFeedback.swift
//  MyTouchBar
//
//  Created by Moses Mok on 25/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import IOKit

// Copied from MTMR
class HapticFeedback {
    enum HapticStrength: Int32 {
        case veryLight = 1
        case light = 2
        case medium = 3
        case strong = 4
        case veryStrong = 5
        case strongest = 6
    }

    static var shared = HapticFeedback()
    
    private let possibleDeviceIDs: [UInt64] = [
        0x200_0000_0100_0000, // MacBook Pro 2016/2017
        0x300000080500000 // MacBook Pro 2019 (possibly 2018 as well)
    ]
    private var correctDeviceID: UInt64?
    private var actuatorRef: CFTypeRef?
    
    private init() {
        recreateDevice()
    }

    // strong is 1-6, 15 and 16 does nothing
    func tap(strength: HapticStrength) {
        guard correctDeviceID != nil, actuatorRef != nil else {
            print("guard actuatorRef == nil (no haptic device found?)")
            return
        }

        var result: IOReturn
        
        result = MTActuatorOpen(actuatorRef!)
        guard result == kIOReturnSuccess else {
            print("guard MTActuatorOpen")
            recreateDevice()
            return
        }

        result = MTActuatorActuate(actuatorRef!, strength.rawValue, 0, 0, 0)
        guard result == kIOReturnSuccess else {
            print("guard MTActuatorActuate")
            return
        }

        result = MTActuatorClose(actuatorRef!)
        guard result == kIOReturnSuccess else {
            print("guard MTActuatorClose")
            return
        }
    }
    
    private func recreateDevice() {
        if let actuatorRef = actuatorRef {
            MTActuatorClose(actuatorRef)
            self.actuatorRef = nil // just in case %)
        }
        
        if let correctDeviceID = correctDeviceID {
            actuatorRef = MTActuatorCreateFromDeviceID(correctDeviceID).takeRetainedValue()
        } else {
            // Let's find our Haptic device
            possibleDeviceIDs.forEach {(deviceID) in
                guard correctDeviceID == nil else {return}
                actuatorRef = MTActuatorCreateFromDeviceID(deviceID).takeRetainedValue()
                
                if actuatorRef != nil {
                    correctDeviceID = deviceID
                }
            }
        }
    }
}
