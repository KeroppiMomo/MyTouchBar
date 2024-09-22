//
//  BasicButton.swift
//  MyTouchBar
//
//  Created by Moses Mok on 5/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

class BasicButton: NSCustomTouchBarItem, NSGestureRecognizerDelegate {
    enum PressEvent { case touchUp, touchDown }

    static let CLICK_SOUND_PATH = "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/ink/InkSoundBecomeMouse.aif"
    static let clickSound = NSSound(contentsOfFile: CLICK_SOUND_PATH, byReference: false)!
    
    var title: String? {
        didSet { setupButton() }
    }
    var images: [NSImage]? {
        didSet { setupButton() }
    }
    var imagesSpacing: CGFloat = 10 {
        didSet { setupButton() }
    }
    var action: (() -> Void)? {
        didSet { setupButton() }
    }
    var foregroundColor: NSColor = NSColor.white {
        didSet { setupButton() }
    }
    var backgroundColor: NSColor = NSColor(srgbRed: 54.0/255.0, green: 54.0/255.0, blue: 54.0/255.0, alpha: 1.0) {
        didSet { setupButton() }
    }
    var holdForegroundColor: NSColor? {
        didSet { setupButton() }
    }
    var holdBackgroundColor: NSColor? {
        didSet { setupButton() }
    }
    var holdGestureEnabled: Bool = true {
        didSet { setupButton() }
    }
    var leftMargin: CGFloat = 0 {
        didSet { setupButton() }
    }
    var rightMargin: CGFloat = 0 {
        didSet { setupButton() }
    }
    var leftPadding: CGFloat = 20 {
        didSet { setupButton() }
    }
    var rightPadding: CGFloat = 20 {
        didSet { setupButton() }
    }
    var labelImageSpacing: CGFloat = 10 {
        didSet { setupButton() }
    }
    var roundedCorners: RoundedCorners = RoundedCorners(all: 8) {
        didSet { setupButton() }
    }
    var clickSoundOnHold: Bool = false {
        didSet { setupButton() }
    }
    var hapticOnHold: Bool = true {
        didSet { setupButton() }
    }
    var pressEvent: PressEvent = .touchUp {
        didSet { setupButton() }
    }
    
    var buttonView: RoundedCornerView!
    private var holdGesture: NSPressGestureRecognizer!
    private var clickGesture: NSClickGestureRecognizer!
    
    override init(identifier: NSTouchBarItem.Identifier) {
        super.init(identifier: identifier)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    func setupButton() {
        view.subviews.forEach({ v in v.removeFromSuperview() })

        let label = title == nil ? nil : NSTextField(labelWithString: title!)
        label?.translatesAutoresizingMaskIntoConstraints = false
        label?.textColor = foregroundColor

        let imagesStackView = images == nil ? nil : NSStackView(views: images!.compactMap {
            let imageView = NSImageView(image: $0)
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 28))
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: $0.size.width / $0.size.height, constant: 0))
            return imageView
        })
        imagesStackView?.spacing = imagesSpacing
        imagesStackView?.translatesAutoresizingMaskIntoConstraints = false

        buttonView = RoundedCornerView(backgroundColor: backgroundColor, roundedCorners: roundedCorners)
        
        if label != nil {
            buttonView.addSubview(label!)
            buttonView.addConstraint(NSLayoutConstraint(item: label!, attribute: .centerY, relatedBy: .equal, toItem: buttonView, attribute: .centerY, multiplier: 1, constant: 0))
            buttonView.addConstraint(NSLayoutConstraint(item: label!, attribute: .trailing, relatedBy: .equal, toItem: buttonView, attribute: .trailing, multiplier: 1, constant: -rightPadding))
        }
        if imagesStackView != nil {
            buttonView.addSubview(imagesStackView!)
            buttonView.addConstraint(NSLayoutConstraint(item: imagesStackView!, attribute: .centerY, relatedBy: .equal, toItem: buttonView, attribute: .centerY, multiplier: 1, constant: 0))
            buttonView.addConstraint(NSLayoutConstraint(item: imagesStackView!, attribute: .leading, relatedBy: .equal, toItem: buttonView, attribute: .leading, multiplier: 1, constant: leftPadding))
        }
        
        if label != nil && imagesStackView != nil {
            buttonView.addConstraint(NSLayoutConstraint(item: label!, attribute: .leading, relatedBy: .equal, toItem: imagesStackView!, attribute: .trailing, multiplier: 1, constant: labelImageSpacing))
        } else if label == nil && imagesStackView != nil {
            buttonView.addConstraint(NSLayoutConstraint(item: imagesStackView!, attribute: .trailing, relatedBy: .equal, toItem: buttonView, attribute: .trailing, multiplier: 1, constant: -rightPadding))
        } else if label != nil && imagesStackView == nil {
            buttonView.addConstraint(NSLayoutConstraint(item: label!, attribute: .leading, relatedBy: .equal, toItem: buttonView, attribute: .leading, multiplier: 1, constant: leftPadding))
        }
        
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonView)
        
        view.addConstraint(NSLayoutConstraint(item: buttonView!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 1))
        view.addConstraint(NSLayoutConstraint(item: buttonView!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -1))
        view.addConstraint(NSLayoutConstraint(item: buttonView!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: leftMargin))
        view.addConstraint(NSLayoutConstraint(item: buttonView!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -rightMargin))

        if (holdGestureEnabled) {
            if (holdGesture == nil) {
                holdGesture = NSPressGestureRecognizer(target: self, action: #selector(onHold))
                holdGesture.minimumPressDuration = 0
                holdGesture.allowedTouchTypes = .direct
                holdGesture.delegate = self
                view.addGestureRecognizer(holdGesture)
            } else {
                view.addGestureRecognizer(holdGesture)
            }
        } else {
            if let holdGesture = holdGesture {
                view.removeGestureRecognizer(holdGesture)
            }
        }
        
        if (action != nil) {
            if (clickGesture == nil) {
                clickGesture = NSClickGestureRecognizer(target: self, action: #selector(onClicked))
                clickGesture.allowedTouchTypes = .direct
                clickGesture.delegate = self
                view.addGestureRecognizer(clickGesture)
            } else {
                view.addGestureRecognizer(clickGesture)
            }
        } else {
            if let clickGesture = clickGesture {
                view.removeGestureRecognizer(clickGesture)
            }
        }

    }
    
    /// For two gestures to work together
    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: NSGestureRecognizer) -> Bool {
        return true
    }

    @objc private func onClicked() { 
        guard pressEvent == .touchUp else { return }

        if hapticOnHold {
            HapticFeedback.shared.tap(strength: .strong)
        }
        action?() 
    }
    @objc private func onHold(gesture: NSGestureRecognizer) {
        if gesture.state == .began {
            if pressEvent == .touchDown {
                action?()
            }

            if clickSoundOnHold {
                BasicButton.clickSound.stop()
                BasicButton.clickSound.play()
            }
            if hapticOnHold {
                HapticFeedback.shared.tap(strength: .strongest)
            }

            buttonView.backgroundColor = (holdBackgroundColor ??
                backgroundColor.blended(withFraction: 0.5, of: NSColor.lightGray)!)
        } else if gesture.state == .ended || gesture.state == .failed || gesture.state == .cancelled {
            buttonView.backgroundColor = backgroundColor
        }
    }
}
