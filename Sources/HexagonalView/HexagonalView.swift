//
//  HexagonalView.swift
//  HoneyComb
//
//  Created by Admin on 3/28/18.
//  Copyright © 2018 Cao Phuoc Thanh. All rights reserved.
//

import UIKit

public class HexagonalView: UIView, UIGestureRecognizerDelegate {
    

    // MARK: Public
    public var address: Int = 0 {
        didSet{
            self.shapView?.textLabel.text = "[#\(self.hub)]:\(self.address)"
        }
    }
    
    public var isSelected: Bool = false {
        didSet{
    
        }
    }
    
    public var port: HexagonalViewPort?
    
    public var color: UIColor = .lightGray {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    // MARK: Internal
    
    var shapView: HexagonalContentView!
    
    weak var delegate: HexagonalViewDelegate?
    weak var parrentView: HexagonalView?
    
    
    var pareMainLocation: CGPoint = CGPoint.zero
    
    var hub: Int = 0
    
    var previousLocation = CGPoint.zero
    
    
    var r:CGFloat {
        let a = self.frame.width/2
        return a*sqrt(3)/2
    }

    var axis: HexagonalViewAsix {
        guard let parrentCenter = parrentView?.center else { return .topBottom }
        if parrentCenter.x == self.center.x && parrentCenter.y < self.center.y { return     .topBottom }
        if parrentCenter.x == self.center.x && parrentCenter.y > self.center.y { return     .bottomTop }
        if parrentCenter.x > self.center.x && parrentCenter.y > self.center.y { return      .rightLeftTop}
        if parrentCenter.x > self.center.x && parrentCenter.y < self.center.y {return       .rightLeftBottom}
        if parrentCenter.x < self.center.x && parrentCenter.y < self.center.y {return       .leftRightBottom}
        if parrentCenter.x < self.center.x && parrentCenter.y > self.center.y {return       .leftRightTop}
        return .topBottom
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialSetup()
    }
    
    
    var isFirstRender: Bool = true
        
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        //self.initialSetup()
        if self.isFirstRender {
            self.isFirstRender = false
            self.shapView.color = color
            //self.shapView.textLabel.text = "[#\(self.hub)]:\(self.address)"
            self.rotateAxis()
        }
    }
    
    func initialSetup() {

        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        
        self.shapView = HexagonalContentView(frame: self.bounds)
        self.addSubview(self.shapView)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        panRecognizer.delegate = self
        self.addGestureRecognizer(panRecognizer)
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("BEGEIN:")
        self.layer.zPosition = 1
        self.pop(0.5)
        self.delegate?.hexagonalView(view: self, touchesBegan: touches)
        previousLocation = self.center
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("CANCEL")
        //self.pop(0.5)
        self.delegate?.hexagonalView(view: self, touchesCancelled: touches)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("ENDED")
        self.pop(0.5)
        self.delegate?.hexagonalView(view: self, touchesEnded: touches)
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        // change center when touch view == 1
        let translation = gesture.translation(in: self.superview!)
        if self.delegate?.hexagonalViewTouchViewsInParrent().count == 1 {
            let newPosition = CGPoint(x:previousLocation.x + translation.x,
                                      y:previousLocation.y + translation.y)
            self.center = newPosition
        } else if self.delegate?.hexagonalViewTouchViewsInParrent().count == 2 {
            if delegate?.hexagonalViewCheckValidRoateHub() == true , self.delegate?.hexagonalViewDistanceTwoViewsTouched() != nil {
                //TODO: move hub
                self.delegate?.hexagonalViewCheckValidRoateHubWith(view: self, translation: translation)
            }
        }
        // delegate changed hexagonal
        if gesture.state == .changed {
            self.delegate?.hexagonalViewMoveing(view: self)
        }
        // delegate ended hexagonal
        if gesture.state == .ended {
            self.layer.zPosition = 0
            self.pop(0.5)
            self.delegate?.hexagonalViewMoveEnded(view: self)
        }
    }
    
}

extension HexagonalView {
    
    public func updateColor(_ color: UIColor) {
       self.shapView.color = color
    }
    
    static func rHexagonal(S: CGFloat) -> CGFloat {
        let a = S
        return a*sqrt(3)/2
    }
    
    func polygonPointArray(sides:Int,
                           x:CGFloat,
                           y:CGFloat,
                           radius:CGFloat,
                           offset:CGFloat)->[CGPoint] {
        let angle = (360/CGFloat(sides)).radians()
        let cx = x // x origin
        let cy = y // y origin
        let r = radius // radius of circle
        var i = 0
        var points = [CGPoint]()
        while i <= sides {
            let xpo = cx + r * cos(angle * CGFloat(i) - offset.radians())
            let ypo = cy + r * sin(angle * CGFloat(i) - offset.radians())
            points.append(CGPoint(x: xpo, y: ypo))
            i += 1
        }
        return points
    }
    
    func drawPolygon(ctx:CGContext, x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int, color:UIColor, offset:CGFloat) {
        let points = polygonPointArray(sides: sides,
                                       x: x,
                                       y: y,
                                       radius: radius,
                                       offset: offset)
        ctx.addLines(between: points)
        let cgcolor = color.cgColor
        ctx.setFillColor(cgcolor)
        ctx.fillPath()
    }
    
    func polygonPath(x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int, offset: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let points = polygonPointArray(sides: sides,
                                       x: x,
                                       y: y,
                                       radius: radius,
                                       offset: offset)
        let cpg = points[0]
        path.move(to: cpg)
        for p in points {
            path.addLine(to: p)
        }
        path.closeSubpath()
        return path
    }
    
    func drawPolygonUsingPath(ctx:CGContext, x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int, color:UIColor, offset:CGFloat) {
        let path = polygonPath(x: x,
                               y: y,
                               radius: radius,
                               sides: sides,
                               offset: offset)
        ctx.addPath(path)
        let cgcolor = color.cgColor
        ctx.setFillColor(cgcolor)
        ctx.fillPath()
    }
    
    func drawPolygonLayer(x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int, color:UIColor, offset:CGFloat) -> CAShapeLayer {
        let shape = CAShapeLayer()
        shape.path = polygonPath(x: x,
                                 y: y,
                                 radius: radius,
                                 sides: sides,
                                 offset: offset)
        shape.fillColor = color.cgColor
        return shape
    }
}

extension UIView {
    
    func pop(_ force: CGFloat = 0.1) {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [0, -0.1*force, 0.0 ,0.05*force, 0.0]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = 0.5
        animation.isAdditive = true
        animation.repeatCount = 1
        animation.isRemovedOnCompletion = true
        self.layer.add(animation, forKey: "pop")
    }
}

extension HexagonalView {
    
    func axisWith(parrentView: HexagonalView) -> HexagonalViewAsix {
        let parrentCenter = parrentView.center
        if parrentCenter.x == self.center.x && parrentCenter.y < self.center.y {
            return .topBottom
        }
        if parrentCenter.x == self.center.x && parrentCenter.y > self.center.y {
            return .bottomTop
        }
        if parrentCenter.x > self.center.x && parrentCenter.y > self.center.y {
            return .rightLeftTop
        }
        if parrentCenter.x > self.center.x && parrentCenter.y < self.center.y {
            return .rightLeftBottom
        }
        if parrentCenter.x < self.center.x && parrentCenter.y < self.center.y {
            return .leftRightBottom
        }
        if parrentCenter.x < self.center.x && parrentCenter.y > self.center.y {
            return .leftRightTop
        }
        return .topBottom
    }
    
    func axisWith(_ newCenter: CGPoint, parrentView: HexagonalView?) -> HexagonalViewAsix {
        let parrentCenter = parrentView?.center ?? self.parrentView!.center
        if parrentCenter.x == newCenter.x && parrentCenter.y < newCenter.y {
            return .topBottom
        }
        if parrentCenter.x == newCenter.x && parrentCenter.y > newCenter.y {
            return .bottomTop
        }
        if parrentCenter.x > newCenter.x && parrentCenter.y > newCenter.y {
            return .rightLeftTop
        }
        if parrentCenter.x > newCenter.x && parrentCenter.y < newCenter.y {
            return .rightLeftBottom
        }
        if parrentCenter.x < newCenter.x && parrentCenter.y < newCenter.y {
            return .leftRightBottom
        }
        if parrentCenter.x < newCenter.x && parrentCenter.y > newCenter.y {
            return .leftRightTop
        }
        return .topBottom
    }
    
    func rotateAxis() {
        switch self.axis {
        case .topBottom:
            self.shapView.transform = self.transform
         case .bottomTop:
            self.shapView.transform = self.transform.rotated(by: CGFloat(Double.pi))
        case .leftRightTop:
            self.shapView.transform = self.transform.rotated(by: CGFloat(Double.pi * 4/3))
        case .rightLeftTop:
            self.shapView.transform = self.transform.rotated(by: -CGFloat(Double.pi * 4/3))
        case .leftRightBottom:
            self.shapView.transform = self.transform.rotated(by: -CGFloat(Double.pi/3))
        case .rightLeftBottom:
            self.shapView.transform = self.transform.rotated(by: CGFloat(Double.pi/3))
        }
    }
    
    func rotateAxisWith(center: CGPoint) {
        var axis: HexagonalViewAsix {
            guard let parrentCenter = parrentView?.center else { return .topBottom }
            if parrentCenter.x == center.x && parrentCenter.y < center.y { return     .topBottom }
            if parrentCenter.x == center.x && parrentCenter.y > center.y { return     .bottomTop }
            if parrentCenter.x > center.x && parrentCenter.y > center.y { return      .rightLeftTop}
            if parrentCenter.x > center.x && parrentCenter.y < center.y {return       .rightLeftBottom}
            if parrentCenter.x < center.x && parrentCenter.y < center.y {return       .leftRightBottom}
            if parrentCenter.x < center.x && parrentCenter.y > center.y {return       .leftRightTop}
            return .topBottom
        }
        
        switch axis {
        case .topBottom:
            self.shapView.transform = self.transform
        case .bottomTop:
            self.shapView.transform = self.transform.rotated(by: CGFloat(Double.pi))
        case .leftRightTop:
            self.shapView.transform = self.transform.rotated(by: CGFloat(Double.pi * 4/3))
        case .rightLeftTop:
            self.shapView.transform = self.transform.rotated(by: -CGFloat(Double.pi * 4/3))
        case .leftRightBottom:
            self.shapView.transform = self.transform.rotated(by: -CGFloat(Double.pi/3))
        case .rightLeftBottom:
            self.shapView.transform = self.transform.rotated(by: CGFloat(Double.pi/3))
        }
    }
    
    func centerOf(port: HexagonalViewPort, radius: CGFloat) -> CGPoint {
        switch axis {
        case .topBottom:
            return self.originTopBottom(port: port,
                                        parentView: self,
                                        radius: radius)
        case .bottomTop:
            return  self.originBottomTop(port: port,
                                         parentView: self,
                                         radius: radius)
        case .leftRightTop:
            return self.originLeftRightTop(port: port,
                                           parentView: self,
                                           radius: radius)
        case .rightLeftTop:
            return self.originRightLeftTop(port: port,
                                           parentView: self,
                                           radius: radius)
        case .leftRightBottom:
            return self.originLeftRightBottom(port: port,
                                              parentView: self,
                                              radius: radius)
        case .rightLeftBottom:
            return self.originRightLeftBottom(port: port,
                                              parentView: self,
                                              radius: radius)
        }
    }
    
    private func originTopBottom(port: HexagonalViewPort,
                                 parentView: HexagonalView,
                                 radius: CGFloat) -> CGPoint {
        var origin = CGPoint.zero
        let R = parentView.r*2
        switch port {
        case .port2:
            let x = parentView.center.x
            let y = parentView.center.y + R
            origin = CGPoint(x: x,
                             y: y)
        case .port1:
            let x = parentView.center.x + radius/2 + radius/4
            let y = parentView.center.y + R/2
            origin = CGPoint(x: x,
                             y: y)
        case .port3:
            let x = parentView.center.x - radius/2 - radius/4
            let y = parentView.center.y + R/2
            origin = CGPoint(x: x,
                             y: y)
        }
        return origin
    }
    
    private func originBottomTop(port: HexagonalViewPort,
                                 parentView: HexagonalView,
                                 radius: CGFloat) -> CGPoint {
        var origin = CGPoint.zero
        let R = parentView.r*2
        switch port {
        case .port2:
            let x = parentView.center.x
            let y = parentView.center.y - R
            origin = CGPoint(x: x,
                             y: y)
        case .port3:
            let x = parentView.center.x + radius/2 + radius/4
            let y = parentView.center.y - R/2
            origin = CGPoint(x: x,
                             y: y)
        case .port1:
            let x = parentView.center.x - radius/2 - radius/4
            let y = parentView.center.y - R/2
            origin = CGPoint(x: x,
                             y: y)
        }
        return origin
    }
    
    private func originLeftRightTop(port: HexagonalViewPort,
                                    parentView: HexagonalView,
                                    radius: CGFloat) -> CGPoint {
        var origin = CGPoint.zero
        let R = parentView.r*2
        switch port {
        case .port1:
            let x = parentView.center.x
            let y = parentView.center.y - R
            origin = CGPoint(x: x,
                             y: y)
        case .port2:
            let x = parentView.center.x + radius/2 + radius/4
            let y = parentView.center.y - R/2
            origin = CGPoint(x: x,
                             y: y)
        case .port3:
            let x = parentView.center.x + radius/2 + radius/4
            let y = parentView.center.y + R/2
            origin = CGPoint(x: x,
                             y: y)
        }
        return origin
    }
    // originRightLeftTop
    private func originRightLeftTop(port: HexagonalViewPort,
                                    parentView: HexagonalView,
                                    radius: CGFloat) -> CGPoint {
        var origin = CGPoint.zero
        let R = parentView.r*2
        switch port {
        case .port3:
            let x = parentView.center.x
            let y = parentView.center.y - R
            origin = CGPoint(x: x,
                             y: y)
        case .port2:
            let x = parentView.center.x - radius/2 - radius/4
            let y = parentView.center.y - R/2
            origin = CGPoint(x: x,
                             y: y)
        case .port1:
            let x = parentView.center.x - radius/2 - radius/4
            let y = parentView.center.y + R/2
            origin = CGPoint(x: x,
                             y: y)
        }
        return origin
    }
    
    // originLeftRightBottom
    private func originLeftRightBottom(port: HexagonalViewPort,
                                       parentView: HexagonalView,
                                       radius: CGFloat) -> CGPoint {
        var origin = CGPoint.zero
        let R = parentView.r*2
        switch port {
        case .port3:
            let x = parentView.center.x
            let y = parentView.center.y + R
            origin = CGPoint(x: x,
                             y: y)
        case .port2:
            let x = parentView.center.x + radius/2 + radius/4
            let y = parentView.center.y + R/2
            origin = CGPoint(x: x,
                             y: y)
        case .port1:
            let x = parentView.center.x + radius/2 + radius/4
            let y = parentView.center.y - R/2
            origin = CGPoint(x: x,
                             y: y)
        }
        return origin
    }
    
    // originRightLeftBottom
    private func originRightLeftBottom(port: HexagonalViewPort,
                                       parentView: HexagonalView,
                                       radius: CGFloat) -> CGPoint {
        var origin = CGPoint.zero
        let R = parentView.r*2
        switch port {
        case .port1:
            let x = parentView.center.x
            let y = parentView.center.y + R
            origin = CGPoint(x: x,
                             y: y)
        case .port2:
            let x = parentView.center.x - radius/2 - radius/4
            let y = parentView.center.y + R/2
            origin = CGPoint(x: x,
                             y: y)
        case .port3:
            let x = parentView.center.x - radius/2 - radius/4
            let y = parentView.center.y - R/2
            origin = CGPoint(x: x,
                             y: y)
        }
        return origin
    }
}
