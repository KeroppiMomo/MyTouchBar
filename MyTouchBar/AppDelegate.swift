//
//  AppDelegate.swift
//  MyTouchBar
//
//  Created by Moses Mok on 4/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import Cocoa
import MediaPlayer
import Carbon
import HotKey

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    // Prevent deinit-ing and unregistering
    var hotkeys: [HotKey] = []
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true] as NSDictionary)
         
//        var spaceNumber: Int32 = -1
//        CGSGetWorkspace(_CGSDefaultConnection(), &spaceNumber)
//        print(spaceNumber)
//        CGSDisableUpdate(_CGSDefaultConnection())
//        DistributedNotificationCenter.default().post(name: .init("com.apple.switchSpaces"), object: "1")
        
//        CGSReenableUpdate(_CGSDefaultConnection())
       
        // SpaceControl.shared.setIndex(0)
        TouchBarController.shared.setupControlStripPresence()

        hotkeys.append(HotKey(key: .f18, modifiers: [], keyDownHandler: {
            self.switchToApp(called: "Google Chrome")
        }))
        hotkeys.append(HotKey(key: .f19, modifiers: [], keyDownHandler: {
            self.switchToApp(called: "iTerm2")
        }))
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        print("Oh no, I am terminating...")
    }

    func switchToApp(called name: String) {
        guard let app = NSWorkspace.shared.runningApplications.first(where: { $0.localizedName == name }) else { return }
        guard app.activate(options: [.activateAllWindows, .activateIgnoringOtherApps]) else {
            print("Failed to activate")
            return
        }
    }
}

