//
//  BatteryLabel.swift
//  MyTouchBar
//
//  Created by Moses Mok on 12/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import Cocoa
import IOKit.ps

class BatteryLabel: BasicButton, BatteryInfo.ObserverProtocol {
    override init(identifier: NSTouchBarItem.Identifier) {
        super.init(identifier: identifier)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    deinit {
        BatteryInfo.shared.removeObserver(self)
    }
    
    private func setup() {
        update()
        BatteryInfo.shared.addObserver(self)
    }
    
    func batteryInfo(didChange info: BatteryInfo) {
        update()
    }
    
    private func update() {
        hapticOnHold = false
        if BatteryInfo.shared.getIsCharged() {
            title = ""
            images = nil
            leftPadding = 0
            rightPadding = 0
            leftMargin = 0
            rightMargin = 0
        } else {
            leftPadding = 20
            rightPadding = 20
            leftMargin = 0
            rightMargin = 10
            
            let batteryLevel = BatteryInfo.shared.getLevel()
            let charging = BatteryInfo.shared.getIsCharging()
            let time: Int? = {
                do {
                    if charging {
                        return try BatteryInfo.shared.getMinutesUntilFull()
                    } else {
                        return try BatteryInfo.shared.getMinutesUntilEmpty()
                    }
                } catch {
                    return nil
                }
            }()
            
            title = {
                let levelString = String(Int(batteryLevel * 100)) + "%"
                if let time = time{
                    return levelString + String(format: " (%02d:%02d)", time / 60, time % 60)
                } else {
                    return levelString
                }
            }()
            
            //        let label = NSTextField(labelWithString: labelText)
            //        label.translatesAutoresizingMaskIntoConstraints = false
            
            images = [{
                if charging {
                    return NSImage(named: "battery-charging")!
                } else {
                    switch batteryLevel {
                    case 0..<0.25:
                        return NSImage(named: "battery-dead")!
                    case 0.25..<0.75:
                        return NSImage(named: "battery-half")!
                    default:
                        return NSImage(named: "battery-full")!
                    }
                }
            }()]
            
            if charging {
                backgroundColor = NSColor(srgbRed: 54.0/255.0, green: 84.0/255.0, blue: 24.0/255.0, alpha: 1.0)
            } else {
                backgroundColor = NSColor(srgbRed: 145.0/255.0, green: 15.0/255.0, blue: 8.0/255.0, alpha: 1.0)
            }
            holdBackgroundColor = backgroundColor
        }
    }
    
}
