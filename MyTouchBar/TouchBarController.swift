//
//  TouchBarController.swift
//  MyTouchBar
//
//  Created by Moses Mok on 4/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import Cocoa

let CONTROL_STRIP_ID = NSTouchBarItem.Identifier("com.unqooBB.myTouchBar.controlStrip");
class TouchBarController : NSObject, NSTouchBarDelegate {
    static let shared = TouchBarController()
    
    var touchBar: NSTouchBar = NSTouchBar()
    
    private override init() {
        super.init()
        
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [NSTouchBarItem.Identifier("com.unqooBB.myTouchBar.test")];
        
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(activeApplicationChanged), name: NSWorkspace.didLaunchApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(activeApplicationChanged), name: NSWorkspace.didTerminateApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(activeApplicationChanged), name: NSWorkspace.didActivateApplicationNotification, object: nil)
    }
    
    @objc func activeApplicationChanged(_: Notification) {
        presentTouchBar()
    }
    
    @objc func setupControlStripPresence() {
        DFRSystemModalShowsCloseBoxWhenFrontMost(false)
        let item = NSCustomTouchBarItem(identifier: CONTROL_STRIP_ID)
        item.view = NSButton(title: "Hello World", target: self, action: #selector(presentTouchBar))
        NSTouchBarItem.addSystemTrayItem(item)
        updateControlStripPresence()
        presentTouchBar()
    }
    func updateControlStripPresence() {
        DFRElementSetControlStripPresenceForIdentifier(CONTROL_STRIP_ID, true)
    }
    
    @objc private func presentTouchBar() {
        presentSystemModal(touchBar)
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        if (identifier == NSTouchBarItem.Identifier("com.unqooBB.myTouchBar.test")) {
            let item = WholeTouchBarItem(identifier: identifier)
            return item
        } else {
            return nil
        }
    }
}

func presentSystemModal(_ touchBar: NSTouchBar!) {
    NSTouchBar.presentSystemModalTouchBar(touchBar, placement: 1, systemTrayItemIdentifier: CONTROL_STRIP_ID)
}
