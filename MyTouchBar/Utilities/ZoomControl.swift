//
//  ZoomControl.swift
//  MyTouchBar
//
//  Created by Moses Mok on 10/1/2021.
//  Copyright © 2021 Moses Mok. All rights reserved.
//

import Foundation

class ZoomControl {
    static let shared = ZoomControl()
    
    let SCRIPT_NOTIFICATION_NAME = NSNotification.Name(rawValue: "com.UnqooBB.MyTouchBar.ZoomControl")
    
    private(set) var hasMeeting = false
    private(set) var audioOn = false
    private(set) var videoOn = false
    private var observers = [(ZoomControl) -> Void]();
    
    private var audioBarWindow: NSWindow?
    
    var scriptProcess: Process?
    
    private init() {}
    
    func startMonitoring() {
        guard scriptProcess == nil || !scriptProcess!.isRunning else { return }
        
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(receiveNotification(notification:)), name: SCRIPT_NOTIFICATION_NAME, object: "AppleScript")
        
        guard let scriptURL = Bundle.main.url(forResource: "ZoomControl", withExtension: "scpt") else { return }
        scriptProcess = Process()
        scriptProcess!.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        scriptProcess!.arguments = [ scriptURL.relativePath ]
        do {
            try scriptProcess!.run()
        } catch {
            print(error)
        }
    }
    
    func stopMonitoring() {
        DistributedNotificationCenter.default().removeObserver(self, name: SCRIPT_NOTIFICATION_NAME, object: "AppleScript")
        
        if let scriptProcess = scriptProcess {
            scriptProcess.terminate()
        }
    }
    
    func addObserver(observer: @escaping (ZoomControl) -> Void) -> Int {
        observers.append(observer)
        return observers.count - 1
    }
    func removeObserver(index: Int) {
        observers.remove(at: index)
    }
    
    @objc private func receiveNotification(notification: Notification) {
        guard let result = notification.userInfo as? Dictionary<String, Bool>,
              let hasMeeting = result["meeting"],
              let audioOn = result["audio"],
              let videoOn = result["video"]
        else {
            print("Unexpected AppleScript Output")
            print(notification.userInfo as Any)
            return
        }
        
        
        self.hasMeeting = hasMeeting
        if self.audioOn != audioOn {
            self.audioOn = audioOn
            
            let windowView = NSView()
            windowView.translatesAutoresizingMaskIntoConstraints = false
            let label = NSTextField(labelWithString: audioOn ? "Audio ON" : "Audio OFF")
            label.translatesAutoresizingMaskIntoConstraints = false
            windowView.addSubview(label)
            label.centerXAnchor.constraint(equalTo: windowView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: windowView.centerYAnchor).isActive = true
            label.font = NSFont.systemFont(ofSize: 24)
            TranslucentWindow.shared.view = windowView
            TranslucentWindow.shared.size = NSSize(width: 200, height: 200)
            TranslucentWindow.shared.show()
            
//            TranslucentWindow.shared.window?.contentView?.alphaValue = 1.0
//            NSAnimationContext.runAnimationGroup { (context) in
//                context.duration = 1
//                TranslucentWindow.shared.window?.contentView?.alphaValue = 1.0
//            }
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                NSAnimationContext.runAnimationGroup({ (context) in
                    context.duration = 1
                    TranslucentWindow.shared.window?.contentView?.alphaValue = 0.0
                }) {
                    TranslucentWindow.shared.window?.close()
                }
            }
        }
        
        if self.videoOn != videoOn {
            self.videoOn = videoOn
            
            let windowView = NSView()
            windowView.translatesAutoresizingMaskIntoConstraints = false
            let label = NSTextField(labelWithString: videoOn ? "Video ON" : "Video OFF")
            label.translatesAutoresizingMaskIntoConstraints = false
            windowView.addSubview(label)
            label.centerXAnchor.constraint(equalTo: windowView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: windowView.centerYAnchor).isActive = true
            label.font = NSFont.systemFont(ofSize: 24)
            TranslucentWindow.shared.view = windowView
            TranslucentWindow.shared.size = NSSize(width: 200, height: 200)
            TranslucentWindow.shared.show()
            
//            TranslucentWindow.shared.window?.contentView?.alphaValue = 1.0
//            NSAnimationContext.runAnimationGroup { (context) in
//                context.duration = 1
//                TranslucentWindow.shared.window?.contentView?.alphaValue = 1.0
//            }
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                NSAnimationContext.runAnimationGroup({ (context) in
                    context.duration = 1
                    TranslucentWindow.shared.window?.contentView?.alphaValue = 0.0
                }) {
                    TranslucentWindow.shared.window?.close()
                }
            }
        }
        
        observers.forEach { $0(self) }
    }
    //
    //    private func updateBarWindow() {
    //        let screenSize = NSScreen.main!.frame.size
    //        let windowFrame = NSRect(x: 0, y: 0, width: 10, height: screenSize.height)
    //
    //        if let win = audioBarWindow {
    //            win.setFrame(windowFrame, display: true)
    //        } else {
    //            audioBarWindow = NSWindow(contentRect: windowFrame, styleMask: .borderless, backing: .buffered, defer: true)
    //        }
    //
    //        audioBarWindow!.isReleasedWhenClosed = false
    //        audioBarWindow!.backgroundColor = .clear
    //        audioBarWindow!.isOpaque = false
    //        audioBarWindow!.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
    //        audioBarWindow!.collectionBehavior = [.canJoinAllSpaces, .transient]
    //        audioBarWindow!.makeKeyAndOrderFront(nil)
    //
    //        let contentView = NSView()
    //        contentView.wantsLayer = true
    //        contentView.layer!.backgroundColor = NSColor(srgbRed: 32.0/255.0, green: 179.0/255.0, blue: 247.0/255.0, alpha: 1.0).cgColor
    //        audioBarWindow!.contentView = contentView
    //    }
}
