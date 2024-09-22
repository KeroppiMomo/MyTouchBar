//
//  LockButton.swift
//  MyTouchBar
//
//  Created by Moses Mok on 7/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import AppKit

class ShutdownButton: BasicButton {
    override init(identifier: NSTouchBarItem.Identifier) {
        super.init(identifier: identifier)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        images = [NSImage(named: "power")!]
        backgroundColor = NSColor(srgbRed: 145.0/255.0, green: 15.0/255.0, blue: 8.0/255.0, alpha: 1.0)
        action = onPressed
        leftPadding = 25.0
        rightPadding = 25.0
        roundedCorners = RoundedCorners(tl: 0.0, tr: 8.0, bl: 0.0, br: 8.0)
    }
    
    private func onPressed() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(100)) {
            UserPowerControl.shutdown()
        }
        // // Ctrl-F1
        // KeyPress(keyCode: 0x3B).sendKeyDown()
        // usleep(50000)
        // KeyPress(keyCode: 0x7A).send()
        // usleep(10000)
        // KeyPress(keyCode: 0x3B).sendKeyUp()
        
        // // Up Arrow
        // for _ in 1...8 {
        //     usleep(500)
        //     KeyPress(keyCode: 0x7D).send()
        // }
        
        // // Enter
        // usleep(500)
        // KeyPress(keyCode: 0x24).send()
    }
}
