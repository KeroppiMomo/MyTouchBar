//
//  WeatherButton.swift
//  MyTouchBar
//
//  Created by Moses Mok on 17/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import Cocoa

class WeatherButton: BasicButton {
    override init(identifier: NSTouchBarItem.Identifier) {
        super.init(identifier: identifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = NSColor.black
        leftPadding = 10.0
        rightPadding = 10.0
        
        action = onClicked
        
        HKO.shared.warningNotificationEnabled = true
        request()
        update()
        
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.request()
        }
    }
    private func request() {
        // let userNotification = NSUserNotification()
        // userNotification.title = "Requesting..."
        // userNotification.subtitle = "HKO"
        // userNotification.setValue(NSImage(named: "WFIREY")!, forKey: "_identityImage")
        // NSUserNotificationCenter.default.deliver(userNotification)

        HKO.shared.requestCurrent { _ in
            DispatchQueue.main.async { self.update() }
        }
        HKO.shared.requestWarning { _ in
            DispatchQueue.main.async { self.update() }
        }
    }
    private func update() {
        let weatherIcon = HKO.shared.currentResponse == nil ? nil : HKO.shared.getIcon(of: HKO.shared.currentResponse!.icon)
        let warningImages = HKO.shared.warningResponse?.warnings.compactMap { HKO.shared.getWarningImage(code: $0.code!) } ?? []
        self.images = warningImages + [weatherIcon].compactMap { $0 }

        let temperature = HKO.shared.currentResponse?.temperature.data.first(where: { data in data.place == "沙田" })?.value
        self.title = "\(temperature == nil ? "?" : String(temperature!))ºC"
    }
    
    private func onClicked() {
        let WEATHER_URL = URL(string: "https://www.google.com/search?q=weather+shatin")!
        
        NSWorkspace.shared.open(WEATHER_URL)
    }
}
