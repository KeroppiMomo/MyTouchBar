//
//  BrightnessControl.swift
//  MyTouchBar
//
//  Created by Moses Mok on 7/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import Foundation

class BrightnessControl {
    // Hope I won't plug more than 10 displays into this computer XD
    let MAX_DISPLAY = 10
    static let shared = BrightnessControl()
    
    private init() { }
    
    func setBrightness(_ brightness: CGFloat, displayIndex: Int = 0) {
        var displays = [CGDirectDisplayID](repeating: 0, count: MAX_DISPLAY)
        var numDisplays: UInt32 = 0
        
        CGGetActiveDisplayList(10, &displays, &numDisplays)
        
        CoreDisplay_Display_SetUserBrightness(displays[displayIndex], Double(brightness))
    }
    
    func getBrightness(displayIndex: Int = 0) -> CGFloat {
        var displays = [CGDirectDisplayID](repeating: 0, count: MAX_DISPLAY)
        var numDisplays: UInt32 = 0
        
        CGGetActiveDisplayList(10, &displays, &numDisplays)
        
        return CGFloat(CoreDisplay_Display_GetUserBrightness(displays[displayIndex]))
    }
}
