//
//  EscapeButton.swift
//  MyTouchBar
//
//  Created by Moses Mok on 5/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import AppKit

class EscapeButton: BasicButton {
    override init(identifier: NSTouchBarItem.Identifier) {
        super.init(identifier: identifier)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        title = "esc"
        backgroundColor = NSColor(srgbRed: 219.0/255.0, green: 200.0/255.0, blue: 75.0/255.0, alpha: 1.0)
        foregroundColor = NSColor.black
        action = onPressed
        leftPadding = 20.0
        rightPadding = 70.0
        rightMargin = 40.0
        clickSoundOnHold = true
        pressEvent = .touchDown
    }
    
    private func onPressed() {
        KeyPress(keyCode: CGKeyCode(0x35)).send()
    }
}
