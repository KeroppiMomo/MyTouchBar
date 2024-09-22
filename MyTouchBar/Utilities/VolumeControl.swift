//
//  VolumeControl.swift
//  MyTouchBar
//
//  Created by Moses Mok on 6/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import AudioToolbox

// This StackOverflow answer is EXTREMELY useful
// https://stackoverflow.com/a/27291862/10845353
class VolumeControl {
    struct RetrieveVolumeError: Error { }
    
    var defaultOutputDeviceID = AudioDeviceID(0)
    
    static let shared = VolumeControl()
    
    private init() {
        // Get default output device ID
        var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
        
        var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        guard AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &getDefaultOutputDevicePropertyAddress,
            0,
            nil,
            &defaultOutputDeviceIDSize,
            &defaultOutputDeviceID) == kIOReturnSuccess else {
                print("failed to get the default output device ID")
                return
        }
    }
    
    /// Set the master volume of the system.
    /// - Parameter volume: The master volume, from 0.0 to 1.0.
    func setVolume(_ volume: CGFloat) {
        var volume = Float32(volume)
        let volumeSize = UInt32(MemoryLayout.size(ofValue: volume))
        
        var volumePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMaster)
        
        guard AudioObjectSetPropertyData(
            defaultOutputDeviceID,
            &volumePropertyAddress,
            0,
            nil,
            volumeSize,
            &volume) == kIOReturnSuccess else {
                print("failed to set volume to output device")
                return
        }
    }
    
    func getVolume() throws -> CGFloat {
        var volume = Float32(0.0)
        var volumeSize = UInt32(MemoryLayout.size(ofValue: volume))

        var volumePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMaster)

        guard AudioObjectGetPropertyData(
            defaultOutputDeviceID,
            &volumePropertyAddress,
            0,
            nil,
            &volumeSize,
            &volume) == kIOReturnSuccess else {
                throw RetrieveVolumeError()
        }
        
        return CGFloat(volume)
    }
}
