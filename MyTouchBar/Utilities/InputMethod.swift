//
//  InputMethod.swift
//  MyTouchBar
//
//  Created by Moses Mok on 22/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import Cocoa
import OSAKit

enum InputMethod: String {
    case qwerty = "com.apple.keylayout.ABC"
    case changjie = "com.apple.inputmethod.TYIM.Cangjie"
    
    static func getCurrent() -> InputMethod? {
        let source = TISCopyCurrentKeyboardInputSource().takeUnretainedValue()
        guard let valueRaw = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else {
            return nil
        }
        guard let value = Unmanaged<AnyObject>.fromOpaque(valueRaw).takeUnretainedValue() as? String else {
            return nil
        }

        return InputMethod.init(rawValue: value)
    }

    static func addObservor(_ observor: Any, selector: Selector) {
        NotificationCenter.default.addObserver(observor, selector: selector, name: NSTextInputContext.keyboardSelectionDidChangeNotification, object: nil)
    }
    static func removeObservor(_ observor: Any) {
        NotificationCenter.default.removeObserver(observor, name: NSTextInputContext.keyboardSelectionDidChangeNotification, object: nil)
    }
    
    func apply() {
        let sourcesRaw = TISCreateInputSourceList([ kTISPropertyInputSourceID: self.rawValue] as CFDictionary, false)
        guard let sources = sourcesRaw?.takeRetainedValue() as? [TISInputSource] else {
            print("Failed getting input sources")
            return
        }
        
        TISSelectInputSource(sources[0])
    }
}
