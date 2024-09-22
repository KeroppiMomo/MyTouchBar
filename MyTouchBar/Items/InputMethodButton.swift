//
//  InputMethodButton.swift
//  MyTouchBar
//
//  Created by Moses Mok on 23/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import Foundation

class InputMethodButton: BasicButton {
    override init(identifier: NSTouchBarItem.Identifier) {
        super.init(identifier: identifier)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = NSColor.white
        foregroundColor = NSColor.black
        leftPadding = 30.0
        rightPadding = 30.0
        rightMargin = 20.0
        clickSoundOnHold = true
        action = onPressed

        update()

        InputMethod.addObservor(self, selector: #selector(update))
    }

    @objc private func update() {
        let inputMethod = InputMethod.getCurrent()

        switch inputMethod {
        case .qwerty:
            title = "Ａ" // This is a full-width "A"
        case .changjie:
            title = "倉"
        default:
            title = "?"
        }
    }

    private func onPressed() {
        if InputMethod.getCurrent() == .qwerty {
            InputMethod.changjie.apply()
        } else {
            InputMethod.qwerty.apply()
        }
        update()
    }
}
