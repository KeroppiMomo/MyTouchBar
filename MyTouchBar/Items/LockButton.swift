//
//  LockButton.swift
//  MyTouchBar
//
//  Created by Moses Mok on 7/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import AppKit

class LockButton: BasicButton {
    override init(identifier: NSTouchBarItem.Identifier) {
        super.init(identifier: identifier)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        images = [NSImage(named: "lock")!]
        backgroundColor = NSColor(srgbRed: 145.0/255.0, green: 15.0/255.0, blue: 8.0/255.0, alpha: 1.0)
        action = onPressed
        leftPadding = 25.0
        rightPadding = 25.0
        rightMargin = 1
        roundedCorners = RoundedCorners(tl: 8.0, tr: 0.0, bl: 8.0, br: 0.0)
    }

    private func onPressed() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(100)) {
            UserPowerControl.sleep()
        }
    }
}
