//
//  DateTimeLabel.swift
//  MyTouchBar
//
//  Created by Moses Mok on 9/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import Cocoa

class DateTimeLabel: BasicButton {
    var timer: Timer!
    var swipeGesture: NSPanGestureRecognizer!
    
    override init(identifier: NSTouchBarItem.Identifier) {
        super.init(identifier: identifier)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        leftPadding = 0
        rightPadding = 0
        leftMargin = 5
        backgroundColor = NSColor.black
        holdBackgroundColor = backgroundColor
        hapticOnHold = false
        setTitle()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self](_) in
            DispatchQueue.main.async {
                self?.setTitle()
            }
        })

        holdGestureEnabled = false
        action = nil

    }

    @objc private func onPan(gesture: NSPanGestureRecognizer) {
        print(gesture.state.rawValue)
    }
    
    private func setTitle() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm:ss"
        
        title = formatter.string(from: Date())

        if swipeGesture == nil {
            swipeGesture = NSPanGestureRecognizer(target: self, action: #selector(onPan(gesture:)))
            swipeGesture.numberOfTouchesRequired = 1
            swipeGesture.allowedTouchTypes = .direct
            swipeGesture.delegate = self
        }
        // buttonView.addGestureRecognizer(swipeGesture)

    }
}
