//
//  CurrentAppIcon.swift
//  MyTouchBar
//
//  Created by Moses Mok on 12/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import Cocoa

class CurrentAppIcon: NSCustomTouchBarItem {
    var imageView: NSImageView!
    
    override init(identifier: NSTouchBarItem.Identifier) {
        super.init(identifier: identifier)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(activeAppChanged(notification:)), name: NSWorkspace.didActivateApplicationNotification, object: nil)
        let appIcon = NSWorkspace.shared.frontmostApplication?.icon
        imageView = NSImageView(image: appIcon!)
        let rightMargin = NSView()
        rightMargin.addConstraint(NSLayoutConstraint(item: rightMargin, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 16))
        
        view = NSStackView(views: [ imageView, rightMargin])
    }
    
    @objc private func activeAppChanged(notification: Notification) {
        let appIcon = (notification.userInfo![NSWorkspace.applicationUserInfoKey] as! NSRunningApplication).icon!
        imageView.image = appIcon
    }
}
