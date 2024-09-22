//
//  RoundedCorner.swift
//  MyTouchBar
//
//  Created by Moses Mok on 15/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import Cocoa

public struct RoundedCorners {
    var topLeft: CGFloat = 0
    var topRight: CGFloat = 0
    var bottomLeft: CGFloat = 0
    var bottomRight: CGFloat = 0
    
    init(all: CGFloat) {
        topLeft = all
        topRight = all
        bottomLeft = all
        bottomRight = all
    }
    init(tl: CGFloat, tr: CGFloat, bl: CGFloat, br: CGFloat) {
        topLeft = tl
        topRight = tr
        bottomLeft = bl
        bottomRight = br
    }
}

public extension NSBezierPath {
    convenience init(rect: CGRect, roundedCorners: RoundedCorners) {
        self.init()
        
        let maxX: CGFloat = rect.size.width
        let minX: CGFloat = 0
        let maxY: CGFloat = rect.size.height
        let minY: CGFloat =  0
        
        let tlr = roundedCorners.topLeft
        let trr = roundedCorners.topRight
        let blr = roundedCorners.bottomLeft
        let brr = roundedCorners.bottomRight
        
        /// IMPORTANT NOTICE!
        /// For some bizarre reason, the y value for the drawing functions is flipped upside down,
        /// so if maxY is inputted, minY will be drawn. SO HAPPY

        // At bottom left
        move(to: NSPoint(x: minX, y: minY))
        
        // Bottom right
        line(to: NSPoint(x: maxX - brr, y: minY))
        appendArc(withCenter: NSPoint(x: maxX - brr, y: minY + brr), radius: brr, startAngle: -90, endAngle: 0, clockwise: false)
        
        // Top right
        line(to: NSPoint(x: maxX, y: maxY - trr))
        appendArc(withCenter: NSPoint(x:maxX - trr, y: maxY - trr), radius: trr, startAngle: 0, endAngle: 90, clockwise: false)
        
        // Top left
        line(to: NSPoint(x: minX + tlr, y: maxY))
        appendArc(withCenter: NSPoint(x: minX + tlr, y: maxY - tlr), radius: tlr, startAngle: 90, endAngle: 180, clockwise: false)
        
        // Bottom left
        line(to: NSPoint(x: minX, y: minY + blr))
        appendArc(withCenter: NSPoint(x: minX + blr, y: minY + blr), radius: blr, startAngle: 180, endAngle: 270, clockwise: false)
    }
    
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)

        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            default: break
            }
        }

        return path
    }
}

class RoundedCornerView: NSView {
    var backgroundColor: NSColor {
        didSet { needsDisplay = true }
    }
    var roundedCorners: RoundedCorners {
        didSet { needsDisplay = true }
    }

    init(backgroundColor: NSColor, roundedCorners: RoundedCorners) {
        self.backgroundColor = backgroundColor
        self.roundedCorners = roundedCorners
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path = NSBezierPath(rect: bounds, roundedCorners: roundedCorners)
        backgroundColor.setFill()
        path.fill()
    }
}
