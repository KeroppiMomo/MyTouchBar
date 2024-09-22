//
//  SpaceControl.swift
//  MyTouchBar
//
//  Created by Moses Mok on 6/6/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//


class SpaceControl {
    static let shared = SpaceControl()

    private init() {}

    func setIndex(_ index: Int) {
        DistributedNotificationCenter.default().post(name: NSNotification.Name("com.apple.switchSpaces"), object: "2")
    }
}
