//
//  UserPowerControl.swift
//  MyTouchBar
//
//  Created by Moses Mok on 7/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import Cocoa

class UserPowerControl {
    static func sleep() {
        let scriptStr = "tell app \"System Events\" to sleep"
        guard let script = NSAppleScript(source: scriptStr) else { return }

        var error: NSDictionary?
        script.executeAndReturnError(&error)
        if let error = error {
            print(error)
        }
    }

    static func shutdown() {
        let scriptStr = "tell app \"loginwindow\" to «event aevtrsdn»"
        guard let script = NSAppleScript(source: scriptStr) else { return }

        var error: NSDictionary?
        script.executeAndReturnError(&error)
        if let error = error {
            print(error)
        }
    }
}
