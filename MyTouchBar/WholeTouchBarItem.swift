//
//  WholeTouchBarItem.swift
//  MyTouchBar
//
//  Created by Moses Mok on 4/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import Cocoa

class WholeTouchBarItem : NSCustomTouchBarItem {
    override init(identifier: NSTouchBarItem.Identifier) {
        super.init(identifier: identifier)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        viewController = WholeTouchBarItemController()
    }
}

class WholeTouchBarItemController : NSViewController {
    static var shared: WholeTouchBarItemController!
    
    var leftItems: [NSTouchBarItem] = []
    var scrollItems: [NSTouchBarItem] = []
    var rightItems: [NSTouchBarItem] = []
    
    var singlePanGesture: NSPanGestureRecognizer!
    var doublePanGesture: NSPanGestureRecognizer!
    var triplePanGesture: NSPanGestureRecognizer!
    
    var singlePanLastPos: CGFloat?
    var singlePanSucceeded: Bool?
    
    var triplePanOrigin: CGFloat?
    var triplePanOriBrightness: CGFloat?
    var triplePanView: NSView?
    
    var doublePanOrigin: CGFloat?
    var doublePanOriVolume: CGFloat?
    var doublePanView: NSView?
    
    let VOLUME_BG_COLOR = NSColor(srgbRed: 0.0/255.0, green: 33.0/255.0, blue: 66.0/255.0, alpha: 1.0)
    let VOLUME_FG_COLOR = NSColor(srgbRed: 10.0/255.0, green: 132.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    let BRIGHTNESS_FG_COLOR = NSColor(srgbRed: 255.0/255.0, green: 214.0/255.0, blue: 10.0/255.0, alpha: 1.0)
    let BRIGHTNESS_BG_COLOR = NSColor(srgbRed: 51.0/255.0, green: 43.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func loadView() {
        view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WholeTouchBarItemController.shared = self
        
        leftItems.append(EscapeButton(identifier: .init("com.UnqooBB.MyTouchBar.EscapeButton")))
        leftItems.append(CurrentAppIcon(identifier: .init("com.UnqooBB.MyTouchBar.CurrentAppIcon")))
        leftItems.append(LockButton(identifier: .init("com.UnqooBB.MyTouchBar.LockButton")))
        leftItems.append(ShutdownButton(identifier: .init("com.UnqooBB.MyTouchBar.ShutdownButton")))
        
        // scrollItems.append(NowPlayingButton(identifier: .init("com.UnqooBB.MyTouchBar.NowPlayingButton")))
        
        rightItems.append(ZoomMuteButton(identifier: .init("com.UnqooBB.MyTouchBar.ZoomMuteButton")))
        rightItems.append(ZoomVideoButton(identifier: .init("com.UnqooBB.MyTouchBar.ZoomVideoButton")))
        rightItems.append(BatteryLabel(identifier: .init("com.UnqooBB.MyTouchBar.BatteryLabel")))
        rightItems.append(InputMethodButton(identifier: .init("com.UnqooBB.MyTouchBar.InputMethodButton")))
        rightItems.append(WeatherButton(identifier: .init("com.UnqooBB.MyTouchBar.WeatherLabel")))
        rightItems.append(DateTimeLabel(identifier: .init("com.UnqooBB.MyTouchBar.DateTimeLabel")))
        
        view = NSView()
        
        rebuild()
        
        if singlePanGesture == nil {
            singlePanGesture =  NSPanGestureRecognizer(target: self, action: #selector(onSinglePan(gesture:)))
            singlePanGesture.numberOfTouchesRequired = 1
            singlePanGesture.allowedTouchTypes = .direct
        }
        if doublePanGesture == nil {
            doublePanGesture =  NSPanGestureRecognizer(target: self, action: #selector(onDoublePan(gesture:)))
            doublePanGesture.numberOfTouchesRequired = 2
            doublePanGesture.allowedTouchTypes = .direct
        }
        if triplePanGesture == nil {
            triplePanGesture =  NSPanGestureRecognizer(target: self, action: #selector(onTriplePan(gesture:)))
            triplePanGesture.numberOfTouchesRequired = 3
            triplePanGesture.allowedTouchTypes = .direct
        }
        view.addGestureRecognizer(singlePanGesture)
        view.addGestureRecognizer(doublePanGesture)
        view.addGestureRecognizer(triplePanGesture)
    }
    
    func rebuild() {
        view.subviews.forEach({ v in v.removeFromSuperview() })
        
        let leftStackView = NSStackView(views: leftItems.compactMap({ item in return item.view }))
        leftStackView.spacing = 0.0
        view.addSubview(leftStackView)
        view.topAnchor.constraint(equalTo: leftStackView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: leftStackView.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: leftStackView.leftAnchor).isActive = true
        
        let rightStackView = NSStackView(views: rightItems.compactMap({ item in return item.view }))
        rightStackView.spacing = 0.0
        view.addSubview(rightStackView)
        view.topAnchor.constraint(equalTo: rightStackView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: rightStackView.bottomAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightStackView.rightAnchor).isActive = true
        
        let scrollStackView = NSStackView(views: scrollItems.compactMap({ item in return item.view }))
        scrollStackView.spacing = 0.0
        let scrollView = NSScrollView()
        scrollView.documentView = scrollStackView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        scrollView.leftAnchor.constraint(equalTo: leftStackView.rightAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: rightStackView.leftAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
        scrollStackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        scrollStackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        scrollStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        if let v = doublePanView {
            view.addSubview(v)
            view.addConstraint(NSLayoutConstraint(item: v, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
            
            view.addConstraint(NSLayoutConstraint(item: v, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        }
        if let v = triplePanView {
            view.addSubview(v)
            view.addConstraint(NSLayoutConstraint(item: v, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: v, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        }
    }
    
    
    @objc func onSinglePan(gesture: NSPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            singlePanLastPos = gesture.translation(in: view).x
            singlePanSucceeded = false
        case .changed:
            if singlePanSucceeded! { return }
            let curTranslation = gesture.translation(in: view).x
            let offset = curTranslation - singlePanLastPos!
            if abs(offset) > 20.0 {
                singlePanSucceeded = true
                
                let keyPress = KeyPress(keyCode: offset < 0 ? 0x7B : 0x7C)
                KeyPress(keyCode: 0x3B).sendKeyDown()
                usleep(10000)
                keyPress.sendKeyDown()
                usleep(10000)
                keyPress.sendKeyUp()
                usleep(10000)
                KeyPress(keyCode: 0x3B).sendKeyUp()

                // TODO: Touch bar does not register gesture when the space is changing or in App Expose or Mission Control.
            }
            singlePanLastPos = curTranslation
        case .ended, .cancelled, .failed:
            singlePanLastPos = nil
            singlePanSucceeded = nil
        default:
            break
        }
    }
    
    func buildHUDWindow(text: String, icon: NSImage, sliderValue: CGFloat) -> NSView {
        let windowView = NSView()
        let windowMiddleView = NSView()
        windowMiddleView.translatesAutoresizingMaskIntoConstraints = false
        windowView.addSubview(windowMiddleView)
        windowMiddleView.centerYAnchor.constraint(equalTo: windowView.centerYAnchor).isActive = true
        windowMiddleView.leadingAnchor.constraint(equalTo: windowView.leadingAnchor).isActive = true
        windowMiddleView.trailingAnchor.constraint(equalTo: windowView.trailingAnchor).isActive = true

        let label = NSTextField(labelWithString: text)
        label.textColor = NSColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.6)
        label.font = NSFont.systemFont(ofSize: 14.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        windowMiddleView.addSubview(label)
        windowMiddleView.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
        windowMiddleView.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true

        let icon = NSImageView(image: icon)
        icon.imageScaling = .scaleProportionallyUpOrDown
        icon.translatesAutoresizingMaskIntoConstraints = false
        windowMiddleView.addSubview(icon)
        icon.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8.0).isActive = true
        icon.addConstraint(.init(item: icon, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80.0))
        windowMiddleView.leftAnchor.constraint(equalTo: icon.leftAnchor).isActive = true
        windowMiddleView.rightAnchor.constraint(equalTo: icon.rightAnchor).isActive = true

        let sliderFilled = NSView()
        sliderFilled.translatesAutoresizingMaskIntoConstraints = false
        sliderFilled.layer = CALayer()
        sliderFilled.layer!.backgroundColor = NSColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.3).cgColor
        let sliderEmpty = NSView()
        sliderEmpty.translatesAutoresizingMaskIntoConstraints = false
        sliderEmpty.layer = CALayer()
        sliderEmpty.layer!.backgroundColor = NSColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.1).cgColor

        let slider = NSView()
        slider.addSubview(sliderFilled)
        slider.addSubview(sliderEmpty)
        slider.leadingAnchor.constraint(equalTo: sliderFilled.leadingAnchor).isActive = true
        slider.topAnchor.constraint(equalTo: sliderFilled.topAnchor).isActive = true
        slider.topAnchor.constraint(equalTo: sliderEmpty.topAnchor).isActive = true
        slider.bottomAnchor.constraint(equalTo: sliderFilled.bottomAnchor).isActive = true
        slider.bottomAnchor.constraint(equalTo: sliderEmpty.bottomAnchor).isActive = true
        slider.trailingAnchor.constraint(equalTo: sliderEmpty.trailingAnchor).isActive = true
        sliderFilled.trailingAnchor.constraint(equalTo: sliderEmpty.leadingAnchor).isActive = true
        slider.translatesAutoresizingMaskIntoConstraints = false

        windowMiddleView.addSubview(slider)

        slider.addConstraint(.init(item: sliderFilled, attribute: .width, relatedBy: .equal, toItem: slider, attribute: .width, multiplier: sliderValue, constant: 0))

        windowMiddleView.leadingAnchor.constraint(equalTo: slider.leadingAnchor, constant: -16.0).isActive = true
        windowMiddleView.trailingAnchor.constraint(equalTo: slider.trailingAnchor, constant: 16.0).isActive = true
        slider.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 16.0).isActive = true
        windowMiddleView.bottomAnchor.constraint(equalTo: slider.bottomAnchor).isActive = true
        slider.addConstraint(.init(item: slider, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 7))

        return windowView
    }
    
    @objc func onDoublePan(gesture: NSPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            
            doublePanOrigin = gesture.translation(in: view).x
            doublePanOriVolume = try! VolumeControl.shared.getVolume()
            
            let volumeLabel = NSButton(title: "Volume: \(Int(doublePanOriVolume! * 100))%", image: NSImage(named: NSImage.touchBarVolumeUpTemplateName)!, target: nil, action: nil)
            volumeLabel.bezelColor = VOLUME_BG_COLOR
            volumeLabel.addConstraint(NSLayoutConstraint(item: volumeLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200))
            
            let volumeSlider = NSSlider(value: Double(doublePanOriVolume!), minValue: 0.0, maxValue: 1.0, target: nil, action: nil)
            volumeSlider.trackFillColor = VOLUME_FG_COLOR
            volumeSlider.addConstraint(NSLayoutConstraint(item: volumeSlider, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300))
            
            doublePanView = NSStackView(views: [volumeLabel, volumeSlider, NSView()])
            let doublePanViewLayer = CALayer()
            doublePanViewLayer.backgroundColor = VOLUME_BG_COLOR.cgColor
            doublePanView!.layer = doublePanViewLayer
            view.addSubview(doublePanView!)
            
            view.addConstraint(NSLayoutConstraint(item: doublePanView!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: doublePanView!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
            
            doublePanView!.alphaValue = 0
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.1
                doublePanView?.alphaValue = 1
            })
        case .changed:
            let curTranslation = gesture.translation(in: view).x
            let offset = curTranslation - doublePanOrigin!
            let newVolume = max(min(doublePanOriVolume! + offset / 250, 1), 0)
            VolumeControl.shared.setVolume(newVolume)
            
            guard doublePanView != nil else { return }
            ((doublePanView as! NSStackView).views[0] as! NSButton).title = "Volume: \(Int(newVolume * 100))%"
            ((doublePanView as! NSStackView).views[1] as! NSSlider).doubleValue = Double(newVolume)

            TranslucentWindow.shared.size = NSSize(width: 200, height: 200)

            let windowView = buildHUDWindow(text: "Volume: \(Int(newVolume * 100))%", icon: NSImage(named: NSImage.touchBarVolumeUpTemplateName)!, sliderValue: newVolume)
            TranslucentWindow.shared.view = windowView

            TranslucentWindow.shared.show()
        case .ended, .cancelled, .failed:
            doublePanOrigin = nil
            doublePanOriVolume = nil

            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.25
                doublePanView?.alphaValue = 0
            }) {
                self.doublePanView?.removeFromSuperview()
                self.doublePanView = nil
            }

            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.25
                TranslucentWindow.shared.window?.contentView?.alphaValue = 0.0
            }) {
                TranslucentWindow.shared.window?.close()
            }
        default: break
        }
    }
    
    @objc func onTriplePan(gesture: NSPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            triplePanOrigin = gesture.translation(in: view).x
            triplePanOriBrightness = BrightnessControl.shared.getBrightness()
            
            let brightnessLabel = NSButton(title: "Brightness: \(Int(triplePanOriBrightness! * 100))%", image: NSImage(named: "brightness")!, target: nil, action: nil)
            brightnessLabel.bezelColor = BRIGHTNESS_BG_COLOR
            brightnessLabel.addConstraint(NSLayoutConstraint(item: brightnessLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200))
            
            let brightnessSlider = NSSlider(value: Double(triplePanOriBrightness!), minValue: 0.0, maxValue: 1.0, target: nil, action: nil)
            brightnessSlider.trackFillColor = BRIGHTNESS_FG_COLOR
            brightnessSlider.addConstraint(NSLayoutConstraint(item: brightnessSlider, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300))
            
            triplePanView = NSStackView(views: [brightnessLabel, brightnessSlider, NSView()])
            let triplePanViewLayer = CALayer()
            triplePanViewLayer.backgroundColor = BRIGHTNESS_BG_COLOR.cgColor
            triplePanView!.layer = triplePanViewLayer
            view.addSubview(triplePanView!)
            
            view.addConstraint(NSLayoutConstraint(item: triplePanView!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: triplePanView!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
            
            triplePanView!.alphaValue = 0
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.1
                triplePanView?.alphaValue = 1
            })
        case .changed:
            let curTranslation = gesture.translation(in: view).x
            let offset = curTranslation - triplePanOrigin!
            let newBrightness = max(min(triplePanOriBrightness! + offset / 250, 1), 0)
            BrightnessControl.shared.setBrightness(newBrightness)
            
            guard triplePanView != nil else { return }
            ((triplePanView as! NSStackView).views[0] as! NSButton).title = "Brightness: \(Int(newBrightness * 100))%"
            ((triplePanView as! NSStackView).views[1] as! NSSlider).doubleValue = Double(newBrightness)
            
            TranslucentWindow.shared.size = NSSize(width: 200, height: 200)

            let windowView = buildHUDWindow(text: "Brightness: \(Int(newBrightness * 100))%", icon: NSImage(named: "brightness")!, sliderValue: newBrightness)
            TranslucentWindow.shared.view = windowView

            TranslucentWindow.shared.show()
        case .ended, .cancelled, .failed:
            triplePanOrigin = nil
            triplePanOriBrightness = nil
            
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.25
                triplePanView?.alphaValue = 0
            }) {
                self.triplePanView?.removeFromSuperview()
                self.triplePanView = nil
            }
            
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.25
                TranslucentWindow.shared.window?.contentView?.alphaValue = 0.0
            }) {
                TranslucentWindow.shared.window?.close()
            }
        default: break
        }
    }
    
    func applyChange(to identifier: NSTouchBarItem.Identifier, change: (NSView) -> Void) {
        change((leftItems + scrollItems + rightItems).first(where: { item in return item.identifier == identifier })!.view!)
    }
}
