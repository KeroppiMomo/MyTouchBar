//
//  TranslucentWindow.swift
//  MyTouchBar
//
//  Created by Moses Mok on 7/11/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import Cocoa

class TranslucentWindow {
    static var shared = TranslucentWindow()

    var view: NSView!
    var size: NSSize!

    var window: NSWindow?

    init() { }

    func show() {
        let screenSize = NSScreen.main!.frame.size
        let windowFrame = NSRect(x: (screenSize.width - size.width) / 2, y: screenSize.height * 0.1, width: size.width, height: size.height)

        if let win = window {
            win.setFrame(windowFrame, display: true)
        } else {
            window = NSWindow(contentRect: windowFrame, styleMask: .borderless, backing: .buffered, defer: true)
        }

        window!.isReleasedWhenClosed = false
        window!.backgroundColor = .clear
        window!.isOpaque = false
        window!.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
        window!.collectionBehavior = [.canJoinAllSpaces, .transient]
        window!.makeKeyAndOrderFront(nil)

        let contentView = NSView()

        let layer = CALayer()
        layer.cornerRadius = 20.0
        contentView.layer = layer

        let visualEffect = NSVisualEffectView()
        visualEffect.translatesAutoresizingMaskIntoConstraints = false
        visualEffect.state = .active
        visualEffect.material = .hudWindow
        contentView.addSubview(visualEffect)

        visualEffect.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        visualEffect.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        visualEffect.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        visualEffect.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        contentView.addConstraint(.init(item: contentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size.width))
        contentView.addConstraint(.init(item: contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size.height))

        window!.contentView = contentView
    }
}
