//
//  ZoomControl.swift
//  MyTouchBar
//
//  Created by Moses Mok on 10/1/2021.
//  Copyright © 2021 Moses Mok. All rights reserved.
//

import Foundation

class ZoomMuteButton: BasicButton {
    override init(identifier: NSTouchBarItem.Identifier) {
        super.init(identifier: identifier)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        ZoomControl.shared.startMonitoring()
        update()
        ZoomControl.shared.addObserver { _ in self.update() }
    }
    
    func update() {
        let isRunning = NSWorkspace.shared.runningApplications.contains { $0.localizedName == "zoom.us" }
        roundedCorners = RoundedCorners(all: 0)
        if !isRunning || !ZoomControl.shared.hasMeeting {
            title = ""
            images = nil
            leftPadding = 0
            rightPadding = 0
            leftMargin = 0
            rightMargin = 0
        } else {
            if ZoomControl.shared.audioOn {
                images = [ NSImage(named: NSImage.touchBarAudioInputTemplateName)! ]
                backgroundColor = NSColor(srgbRed: 32.0/255.0, green: 179.0/255.0, blue: 247.0/255.0, alpha: 1.0)
            } else {
                images = [ NSImage(named: NSImage.touchBarAudioInputMuteTemplateName)! ]
                backgroundColor = NSColor(srgbRed: 54.0/255.0, green: 54.0/255.0, blue: 54.0/255.0, alpha: 1.0)
            }
            title = nil
            leftPadding = 30
            rightPadding = 30
            leftMargin = 0
            rightMargin = 1
        }
    }
}

class ZoomVideoButton: BasicButton {
    override init(identifier: NSTouchBarItem.Identifier) {
        super.init(identifier: identifier)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        ZoomControl.shared.startMonitoring()
        update()
        ZoomControl.shared.addObserver { _ in self.update() }
    }
    
    func update() {
        let isRunning = NSWorkspace.shared.runningApplications.contains { $0.localizedName == "zoom.us" }
        roundedCorners = RoundedCorners(all: 0)
        if !isRunning || !ZoomControl.shared.hasMeeting {
            title = ""
            images = nil
            leftPadding = 0
            rightPadding = 0
            leftMargin = 0
            rightMargin = 0
        } else {
            if ZoomControl.shared.videoOn {
                images = [ NSImage(named: NSImage.touchBarCommunicationVideoTemplateName)! ]
                backgroundColor = NSColor(srgbRed: 32.0/255.0, green: 214.0/255.0, blue: 28.0/255.0, alpha: 1.0)
            } else {
                images = [ NSImage(named: NSImage.touchBarCommunicationVideoTemplateName)! ]
                backgroundColor = NSColor(srgbRed: 54.0/255.0, green: 54.0/255.0, blue: 54.0/255.0, alpha: 1.0)
            }
            title = nil
            leftPadding = 30
            rightPadding = 30
            leftMargin = 0
            rightMargin = 10
        }
    }
}
