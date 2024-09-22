//
//  KeyPress.swift
//  MyTouchBar
//
//  Created by Moses Mok on 4/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import Foundation

struct KeyPress {
    var keyCode: CGKeyCode
    
    func sendKeyUp() {
        let src = CGEventSource(stateID: .hidSystemState)
        let keyUp = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)
        let loc: CGEventTapLocation = .cghidEventTap
        keyUp!.post(tap: loc)
    }
    func sendKeyDown() {
        let src = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
        let loc: CGEventTapLocation = .cghidEventTap
        keyDown!.post(tap: loc)
    }
    
    func send() {
        let src = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)
        
        let loc: CGEventTapLocation = .cghidEventTap
        keyDown!.post(tap: loc)
        keyUp!.post(tap: loc)
    }
}
