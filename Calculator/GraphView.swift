//
//  GraphView.swift
//  Calculator
//
//  Created by Winnie on 8/10/2016.
//  Copyright © 2016 Winnie. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable
    var axesColor = UIColor.lightGrayColor()

    @IBInspectable
    var color = UIColor.blueColor()
    
    @IBInspectable
    var lineWidth = 2.0
    
    @IBInspectable
    var scale: CGFloat = 100 { didSet { setNeedsDisplay() } }
    
    var origin: CGPoint {
        get {
            return _origin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        }
        set {
            _origin = newValue
            setNeedsDisplay()
        }
    }
    
    var originWrtCenter: CGPoint {
        get {
            return CGPoint(x: origin.x - bounds.midX, y: origin.y - bounds.midY)
        }
        set {
            origin = CGPoint(x: newValue.x + bounds.midX, y: newValue.y + bounds.midY)
        }
    }
    
    var function: ((x: Double) -> Double?)? { didSet { setNeedsDisplay() } }
    
    private var _origin: CGPoint?
    
    private var drawer = AxesDrawer()
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        updateUI()
    }
    
    private func updateUI() {
        drawAxes()
        drawGraph()
    }
    
    private func drawAxes() {
        drawer.color = axesColor
        drawer.contentScaleFactor = contentScaleFactor
        drawer.drawAxesInRect(bounds, origin: origin, pointsPerUnit: scale)
    }
    
    private func drawGraph() {
        if let f = function {
            let path = UIBezierPath()
            color.set()
            path.lineWidth = CGFloat(lineWidth)
            /*
            for each point on the view x-axis
                translate x-coordinate to x-value of the drawn axes
                find out the corresponding y-value
                translate computed y-value back to y-coordindate of the view
            */
            var previous: CGPoint?
            for i in 0...Int(bounds.maxX * contentScaleFactor) {
                let xCoordinate = Double(i) / Double(contentScaleFactor)
                let xValue = (Double(xCoordinate) - Double(origin.x)) / Double(scale)
                if let yValue = f(x: xValue) {
                    let yCoordinate = -(yValue * Double(scale) - Double(origin.y))
                    let point = CGPoint(x: align(CGFloat(xCoordinate)), y: align(CGFloat(yCoordinate)))
                    if previous != nil {
                        path.addLineToPoint(point)
                    } else {
                        path.moveToPoint(point)
                    }
                    previous = yValue.isNormal && point.y > bounds.minY && point.y < bounds.maxY ? point : nil
                }
            }
            path.stroke()
        }
    }
    
    private func align(coordinate: CGFloat) -> CGFloat {
        return round(coordinate * contentScaleFactor) / contentScaleFactor
    }
    
    func changePointsPerUnit(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Changed,.Ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    func moveGraph(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Changed,.Ended:
            origin = recognizer.locationInView(self)
        default:
            break
        }
    }
    
    func moveOrigin(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .Ended:
            origin = recognizer.locationInView(self)
        default:
            break
        }
    }
}
