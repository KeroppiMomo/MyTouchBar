//
//  NowPlayingButton.swift
//  MyTouchBar
//
//  Created by Moses Mok on 25/6/2021.
//  Copyright © 2021 Moses Mok. All rights reserved.
//

import Foundation

class NowPlayingButton: BasicButton {
    override init(identifier: NSTouchBarItem.Identifier) {
        super.init(identifier: identifier)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationReceived(notification:)), name: NSNotification.Name(kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification!.takeRetainedValue() as String), object: nil)
        action = onPressed
        update()
        
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func notificationReceived(notification: NSNotification) {
        print("helo")
        update()
    }
    
    @objc func update() {
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main, { (infoCFDict) in
            if infoCFDict == nil {
                self.title = ""
                self.images = nil
                self.leftPadding = 0
                self.rightPadding = 0
                self.leftMargin = 0
                self.rightMargin = 0
            } else {
                let info = infoCFDict as! [ String: Any ]
                let title = info[kMRMediaRemoteNowPlayingInfoTitle.takeRetainedValue() as String] as! String
                let artist = info[kMRMediaRemoteNowPlayingInfoArtist.takeRetainedValue() as String] as! String
                self.title = "\(title) - \(artist)"
                if let imageData = info[kMRMediaRemoteNowPlayingInfoArtworkData.takeRetainedValue() as String] as? Data {
                    self.images = [NSImage(data: imageData)!]
                }
                self.leftPadding = 10
                self.rightPadding = 10
                self.leftMargin = 0
                self.rightMargin = 0
            }
        })
    }
    
    func onPressed() {
        MRMediaRemoteSendCommand(kMRTogglePlayPause, nil)
    }
}
