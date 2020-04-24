//
//  PaperView.swift
//  HoneyComb
//
//  Created by Admin on 3/28/18.
//  Copyright © 2018 Cao Phuoc Thanh. All rights reserved.
//

import UIKit
import QuartzCore

public protocol HexagonalPaperViewDelegate: class {
    func hexagonalPaperView(view: HexagonalPaperView, touchBegan touches: Set<UITouch>, with event: UIEvent?)
    func hexagonalPaperView(view: HexagonalPaperView, hexagonalView: HexagonalView, touchBegan touches: Set<UITouch>, with event: UIEvent?)
}

public class HexagonalPaperView: UIView, UIGestureRecognizerDelegate {
    
    // MARK: Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialSetup()
    }
    
    // MARK: Public
    public weak var delegate: HexagonalPaperViewDelegate?
    
    public var currentTouchHexagonalViews: [HexagonalView] = [] {
        didSet{
            print("currentTouchHexagonalViews.count:", currentTouchHexagonalViews.count)
            if oldValue.count == 1 && self.currentTouchHexagonalViews.count == 2 {
                self.distanceTwoViewTouched = self.currentTouchHexagonalViews[0].center.disance(self.currentTouchHexagonalViews[1].center)
            } else if self.currentTouchHexagonalViews.count == 2 {
                //
            } else {
                self.distanceTwoViewTouched = nil
            }
        }
    }
    
    public var distanceTwoViewTouched: CGFloat? {
        didSet{
            print("distanceTwoViewTouched:", self.distanceTwoViewTouched ?? 0)
        }
    }
    
    public typealias HexagonalViews = [HexagonalView]
    
    public var hexagonalViews: HexagonalViews {
        return self.hubHexagonalView.flatMap({ (emelent: HexagonalViews) -> HexagonalViews in
            return emelent
        })
    }
    
    var centerTwoViews = CGPoint.zero
    
    var previousLocation = CGPoint.zero

    var hubHexagonalView: [HexagonalViews] = []
    var undefineHexagonalView: [HexagonalView] = []
    
    var hexagonalRadius: CGFloat = 150
    
    var minxiMunScale: CGFloat = 0.5
    var maximumScale: CGFloat  = 1.5
    var zoomSpeed: CGFloat = 0.5
    
    var defaultColorString: String = "#83878c"
    
    fileprivate var moveCenter: CGPoint = CGPoint.zero
        
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        //self.initialSetup()
    }
    
    func initialSetup() {
        self.isUserInteractionEnabled = true
        self.backgroundColor = .clear
        
        let rotationRecognizer = UIRotationGestureRecognizer(target: self,
                                                             action: #selector(handleRotation(gesture:)))
        rotationRecognizer.delegate = self
        self.addGestureRecognizer(rotationRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self,
                                                   action: #selector(handlePan(gesture:)))
        panRecognizer.delegate = self
        self.addGestureRecognizer(panRecognizer)
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self,
                                                       action: #selector(handlePinch(gesture:)))
        pinchRecognizer.delegate = self
        self.addGestureRecognizer(pinchRecognizer)
        
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>,
                                      with event: UIEvent?) {
        previousLocation = self.center
        self.delegate?.hexagonalPaperView(view: self, touchBegan: touches, with: event)
    }
    
    // https://www.youtube.com/watch?v=S-06Lb4znFs
    @objc func handleRotation(gesture: UIRotationGestureRecognizer) {
        guard self.currentTouchHexagonalViews.count == 0 else { return }
        switch gesture.state {
        case .began:
            let location0 = gesture.location(ofTouch: 0, in: self)
            let location1 = gesture.location(ofTouch: 1, in: self)
            let centerPoint = CGPoint(x: (location0.x + location1.x)/2,
                                      y: (location0.y + location1.y)/2)
            let newAnchorPoint = CGPoint(x: centerPoint.x/self.bounds.size.width,
                                         y: centerPoint.y/self.bounds.size.height)
            let oldAnchorPoint = self.layer.anchorPoint
            let offsetFromMovingAnchorPointX = self.bounds.size.width * (newAnchorPoint.x - oldAnchorPoint.x)
            let offsetFromMovingAnchorPointY = self.bounds.size.height * (newAnchorPoint.y - oldAnchorPoint.y)
            self.layer.anchorPoint = newAnchorPoint
            self.transform = self.transform.translatedBy(x: offsetFromMovingAnchorPointX, y: offsetFromMovingAnchorPointY)
        case .changed:
            self.transform =  self.transform.rotated(by: gesture.rotation)
            gesture.rotation = 0
        default:
            break
        }
        
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        guard gesture.state == .began || gesture.state == .changed else { return }
        guard self.currentTouchHexagonalViews.count == 0 else { return }
        let translation = gesture.translation(in: self.superview!)
        let newCenter = CGPoint(x:previousLocation.x + translation.x,
                                y:previousLocation.y + translation.y)
        self.center = newCenter
    }
    
    var lastScale: CGFloat = 0
    
    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        guard gesture.state == .began || gesture.state == .changed else { return }
        guard self.currentTouchHexagonalViews.count == 0 else { return }
        let currentScale = gesture.view!.layer.value(forKeyPath: "transform.scale.x") as! CGFloat
        var deltaScale = gesture.scale
        deltaScale = ((deltaScale - 1) * self.zoomSpeed) + 1
        deltaScale = min(deltaScale, self.maximumScale / currentScale)
        deltaScale = max(deltaScale, self.minxiMunScale / currentScale)
        self.transform = self.transform.scaledBy(x: deltaScale,
                                                 y: deltaScale)
        gesture.scale = 1
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.currentTouchHexagonalViews.count == 0 || self.currentTouchHexagonalViews.count == 2 ? true : false
    }
    
}

public extension HexagonalPaperView {
    
    @discardableResult func drawHexagonalViews(_ addressString: String,
                                                      radius: CGFloat = 150,
                                                      color: UIColor = .lightGray,
                                                      origin: CGPoint = CGPoint.zero) -> (hub: Int, hexagonalViews: HexagonalViews) {
        self.hexagonalRadius = radius
        let hexagonalViews = HexagonalViews()
        self.hubHexagonalView.append(hexagonalViews)
        let hubIndex = hubHexagonalView.count - 1
        let arrayAddress = addressString.components(separatedBy: ":")
        if hexagonalViews.count == 0 {
            for (i,item) in arrayAddress.enumerated() {
                if let address = self.parseAddressString(item)?.address {
                    if i == 0 || Int(address) == 1 {
                        hubHexagonalView[hubIndex].append(self.drawMainHexagonalView(radius: radius,
                                                                                     hub: hubIndex,
                                                                                     title: address,
                                                                                     color: .lightGray,
                                                                                     origin: origin))
                    } else {
                        self.drawHexagonalView(item, hub: hubIndex)
                    }
                }
            }
        } else if hexagonalViews.count > 0 {
            for item in arrayAddress {
                self.drawHexagonalView(item, hub: hubIndex)
            }
        }
        return (hubIndex, hexagonalViews)
    }
    
    func parseAddressString(_ addressString: String) -> (address:String, hexColorString: String)? {
        let arrString = addressString.components(separatedBy: ";")
        let address = arrString[0]
        guard arrString.count > 0 else {
            print("can not parse address:", addressString)
            return nil
        }
        if arrString.count == 2 {
            let hexColorString =  arrString[1]
            return (address, hexColorString)
        } else {
            return (address, self.defaultColorString)
        }
    }
    
    @discardableResult func drawHexagonalView(_ addressString: String, hub: Int) -> HexagonalView? {
        guard self.hubHexagonalView.count > hub else {return nil}
        guard self.hubHexagonalView[hub].count > 0 else {return nil}
        guard let addressColor = self.parseAddressString(addressString) else { return nil}
        guard let address = Int(addressColor.address) else { return nil}
        let color = UIColor(hex: addressColor.hexColorString)
        if self.hubHexagonalView[hub].contains(where: { (view) -> Bool in
            return view.address == address
        }) {
            if let _view = self.hubHexagonalView[hub].filter({ (view) -> Bool in
                return view.address == address
            }).first {
                let arrString = addressString.components(separatedBy: ";")
                if arrString.count == 2 {
                    let color = UIColor.init(hex: arrString[1])
                    _view.updateColor(color)
                }
                return _view
            } else {
                return nil
            }
        }
        guard self.hubHexagonalView[hub].count > 0  else { return nil}
        guard let parrentView = self.hubHexagonalView[hub].filter({ (view) -> Bool in
            return view.address == Int(address/10)
        }).first else {
            print(" NOT EXIST PARRENT:", address, Int(address/10))
            return nil
        }
        guard let portInt = Int(String(addressColor.address.last!)) else { return nil}
        guard let port = HexagonalViewPort(rawValue: portInt)  else { return nil}
        guard let hexagonalView = self.drawHexagonalView(parentView: parrentView,
                                                         port: port,
                                                         hub: hub,
                                                         address: address,
                                                         title: addressColor.address,
                                                         color: color)  else { return nil}
        self.hubHexagonalView[hub].append(hexagonalView)
        return hexagonalView
    }
    
    func calculateAddressCenter() -> HexagonalView {
        let hexagonalViewsSortedByAddress = self.hexagonalViews.sorted { (hex1, hex2) -> Bool in
            hex1.address < hex2.address
        }
        let addressLast = hexagonalViewsSortedByAddress.last!.address
        let addressLastCharacterCount = String(addressLast).count
        let addressCenterCharacterCount = Int(addressLastCharacterCount/2)
        let addressCenter = Int(String(addressLast)[0...addressCenterCharacterCount])!
        return self.hexagonalViews.filter({ (hex) -> Bool in
            hex.address == addressCenter
        }).first!
    } 
    
    // make port
    func drawMainHexagonalView(radius: CGFloat,
                               hub: Int,
                               title: String,
                               color: UIColor = UIColor.lightGray,
                               origin: CGPoint = CGPoint.zero) -> HexagonalView {
        print("New MAIN shape HUB:", hub)
        let x = self.frame.width/2
        let y = self.frame.height/2
        var _origin = CGPoint(x: x, y: y)
        if origin != CGPoint.zero {
            _origin = origin
        }
        let _size: CGSize = CGSize(width: radius, height: radius)
        let shape: HexagonalView = HexagonalView(frame: CGRect(origin: _origin, size: _size))
        shape.hub = hub
        shape.address = 1
        shape.delegate = self
        self.addSubview(shape)
        return shape
    }
    
    func drawHexagonalView(parentView: HexagonalView,
                           port: HexagonalViewPort,
                           hub: Int,
                           address: Int,
                           title: String,
                           color: UIColor? = UIColor.lightGray) -> HexagonalView? {
        print("New shape address:", address, "axis:", parentView.axis)
        
        // calculate origin
        let origin:CGPoint = parentView.centerOf(port: port, radius: self.hexagonalRadius)
        
        // check exist origin
        if self.hubHexagonalView[hub].filter({ (view) -> Bool in
            return view.center == origin
        }).first != nil {
            return nil
        }
        
        // draw shape
        let sizeShape = CGSize(width: self.hexagonalRadius,
                               height: self.hexagonalRadius)
        
        let shape: HexagonalView = HexagonalView(frame: CGRect(origin: origin, size: sizeShape))
        shape.center = origin
        shape.hub = hub
        shape.parrentView = parentView
        shape.address = address
        shape.color = color ?? .lightGray
        shape.port = port
        shape.delegate = self
        self.addSubview(shape)
        return shape
    }
}

extension HexagonalPaperView: HexagonalViewDelegate {
    
    func hexagonalViewDistanceTwoViewsTouched() -> CGFloat? {
        return self.distanceTwoViewTouched
    }
    
    func hexagonalViewCheckValidRoateHubWith(view: HexagonalView, translation: CGPoint) {
        let view1 = self.currentTouchHexagonalViews[0]
        let view2 = self.currentTouchHexagonalViews[1]
        let distance = self.distanceTwoViewTouched!
        let r = distance/2
        let centerOf2Fingers = self.centerTwoViews
        print("2 fingers moving hub:", r , centerOf2Fingers, view1.center, view2.center)
        
        let new1Position = CGPoint(x:view1.previousLocation.x + translation.x,
                                   y:view1.previousLocation.y + translation.y)
        view1.center = new1Position
    }
    
    func hexagonalViewCheckValidRoateHub() -> Bool {
        if hexagonalViewTouchViewsInParrent().count == 2 && self.distanceTwoViewTouched != nil {
            if hexagonalViewTouchViewsInParrent()[0].hub == hexagonalViewTouchViewsInParrent()[1].hub {
                return true
            }
        }
        return false
    }
    
    func hexagonalViewHubHexagonalViews(isInclusde view: HexagonalView) -> [HexagonalView] {
        return self.hubHexagonalView[view.hub]
    }
    
    func hexagonalViewTouchViewsInParrent() -> [HexagonalView] {
        return self.currentTouchHexagonalViews
    }
    
    func hexagonalView(view: HexagonalView, touchesBegan touches: Set<UITouch>) {
        self.delegate?.hexagonalPaperView(view: self, hexagonalView: view, touchBegan: touches, with: nil)
        if self.currentTouchHexagonalViews.contains(view) == false {
            self.currentTouchHexagonalViews.append(view)
        }
        if self.currentTouchHexagonalViews.count > 0 && self.currentTouchHexagonalViews.count < 2 {
            if view.hub == -1 {
                print("Touch beggan undefine hub view", view)
            } else if view == self.hubHexagonalView[view.hub].first {
                self.touchesBeganMainHexagonalView(view: view)
            }
        } else {
            self.centerTwoViews = self.centerOf2Fingers(view1: self.currentTouchHexagonalViews[0],
                                                        view2: self.currentTouchHexagonalViews[1])
        }
    }
    
    func hexagonalView(view: HexagonalView, touchesEnded touches: Set<UITouch>) {
        self.removeTouchViews(view: view)
    }
    
    func hexagonalView(view: HexagonalView, touchesCancelled touches: Set<UITouch>) {
        print("touchesCancelled:", view.address, self.currentTouchHexagonalViews.count)
        //self.removeTouchViews(view: view)
    }
    
    
    
    func hexagonalViewMoveEnded(view: HexagonalView) {
        if self.currentTouchHexagonalViews.count < 2 && self.currentTouchHexagonalViews.count > 0 {
            if view.hub == -1 {
                self.moveEndedWithNormalHexagonalView(view: view)
                self.checkParrentOfAllHexagonalViews()
            } else if view.address == self.hubHexagonalView[view.hub].first?.address {
                self.moveEndedWithMainHexagonalView(view: view)
            } else {
                self.moveEndedWithNormalHexagonalView(view: view)
            }
            self.removeTouchViews(view: view)
        } else {
            print("2 fingers end hub")
            self.currentTouchHexagonalViews = []
        }
    }
    
    func hexagonalViewMoveing(view: HexagonalView) {
        if self.currentTouchHexagonalViews.count < 2 && self.currentTouchHexagonalViews.count > 0 {
            if view.hub == -1 {
                self.movingWithNormalHexagonalView(view: view)
            } else if view == self.hubHexagonalView[view.hub].first {
                self.movingWithMainHexagonalView(view: view)
            } else {
                self.movingWithNormalHexagonalView(view: view)
            }
        } else if self.currentTouchHexagonalViews.count == 2 {
            //
        } else {
            print("orther")
        }
    }
    
    private func centerOf2Fingers(view1: HexagonalView,
                                  view2: HexagonalView) -> CGPoint {
        let x = max(view1.center.x, view2.center.x) - min(view1.center.x, view2.center.x)
        let y = max(view1.center.y, view2.center.y) - min(view1.center.y, view2.center.y)
        return CGPoint(x: x,
                       y: y)
    }
    
    private func distance2Fingers(view1: HexagonalView,
                                  view2: HexagonalView) -> CGFloat {
        return view1.center.disance(view2.center)
    }
    
    
    
    private func removeTouchViews(view: HexagonalView) {
        for (i,e) in self.currentTouchHexagonalViews.enumerated() {
            if e == view {
                self.currentTouchHexagonalViews.remove(at: i)
            }
        }
    }
    
    private func touchesBeganMainHexagonalView(view: HexagonalView) {
        self.hubHexagonalView[view.hub].forEach { (view) in
            view.layer.zPosition = 1
        }
        for (i, e) in self.hubHexagonalView[view.hub].enumerated() {
            if i > 0 {
                let x = view.center.x - e.center.x
                let y = view.center.y - e.center.y
                e.pareMainLocation = CGPoint(x: x,
                                             y: y)
            }
        }
    }
    
    private func moveEndedWithMainHexagonalView(view: HexagonalView) {
        self.hubHexagonalView[view.hub].forEach { (view) in
            view.layer.zPosition = 0
        }
    }
    
    private func moveEndedWithNormalHexagonalView(view: HexagonalView) {
        guard self.moveCenter != CGPoint.zero else { return }
        print("change:", view.port?.rawValue ?? "null", view.parrentView?.address ?? "null")
        UIView.animate(withDuration: 0.2, animations: {
            view.center = self.moveCenter
        }, completion: { (_) in
            self.checkParrentOfAllHexagonalViews()
            self.undefineHexagonalView = []
        })
    }
    
    private func movingWithMainHexagonalView(view: HexagonalView) {
        for (i, e) in self.hubHexagonalView[view.hub].enumerated() {
            if i > 0 {
                let x = view.center.x - e.pareMainLocation.x
                let y = view.center.y - e.pareMainLocation.y
                e.center = CGPoint(x: x,
                                   y: y)
            }
        }
    }
    
    private func movingWithNormalHexagonalView(view: HexagonalView) {
        let nearBy = self.nearOrigin(view: view)
        guard nearBy.center != self.moveCenter else { return }
        guard let nearParrent = nearBy.parrentView else { return }
        view.parrentView = nearBy.parrentView
        view.port = nearBy.port
        view.address = Int("\(nearParrent.address)\(nearBy.port.rawValue)")!
        self.changeHub(view: view, toHub: nearBy.hub)
        self.moveCenter = nearBy.center
        UIView.animate(withDuration: 0.3, animations: {
            view.rotateAxisWith(center: self.moveCenter)
        })
    }
    
    private func changeHub(view: HexagonalView, toHub: Int) {
        self.hubHexagonalView[toHub].append(view)
        if view.hub != -1 {
            for (i, e) in self.hubHexagonalView[view.hub].enumerated() {
                if e == view {
                    hubHexagonalView[view.hub].remove(at: i)
                    break
                }
            }
        } else {
            for (i, e) in self.undefineHexagonalView.enumerated() {
                if e == view {
                    self.undefineHexagonalView.remove(at: i)
                    break
                }
            }
        }
        view.hub = toHub
    }
}

extension HexagonalPaperView {
    
    func nearOrigin(view: HexagonalView) -> (center:CGPoint, parrentView: HexagonalView?, port: HexagonalViewPort, hub: Int) {
        var near: (center:CGPoint, parrentView: HexagonalView?, port: HexagonalViewPort, hub: Int) = (CGPoint.zero, view.parrentView, view.port ?? .port1, view.hub)
        
        var lastDistance: CGFloat = 0
        let hexagonalViews: [HexagonalView] = self.hexagonalViews
        
        hexagonalViews.forEach { (parrent) in
            
            if parrent != view && parrent.address != -1 {
                
                // port 1
                if let checkPort = self.checkValidCenter(inviews: hexagonalViews, parrentView: parrent, view: view, port: .port1, lasDistance: lastDistance, radius: self.hexagonalRadius) {
                    near = checkPort.near
                    lastDistance = checkPort.distance
                }
                
                // port 2
                if let checkPort = self.checkValidCenter(inviews: hexagonalViews, parrentView: parrent, view: view, port: .port2, lasDistance: lastDistance, radius: self.hexagonalRadius) {
                    near = checkPort.near
                    lastDistance = checkPort.distance
                }
                
                // port 3
                if let checkPort = self.checkValidCenter(inviews: hexagonalViews, parrentView: parrent, view: view, port: .port3, lasDistance: lastDistance, radius: self.hexagonalRadius) {
                    near = checkPort.near
                    lastDistance = checkPort.distance
                }
            }
        }
        return near
    }
    
    private func checkValidCenter(inviews: [HexagonalView], parrentView: HexagonalView, view: HexagonalView, port: HexagonalViewPort, lasDistance: CGFloat, radius: CGFloat) -> (near: (center:CGPoint, parrentView: HexagonalView?, port: HexagonalViewPort, hub: Int), distance: CGFloat)? {
        let origin = parrentView.centerOf(port: port, radius: radius)
        guard self.checkExistCenter(inViews: inviews, with: origin)  == false  else {  return nil }
        guard self.checkExitAddress(inViews: inviews, parrent: parrentView, port: port) == false else { return nil }
        guard self.checkExistDistanceCenter(inViews: inviews, with: origin) == false else { return nil }
        let distance = origin.disance(view.center)
        guard lasDistance >= distance || lasDistance == 0 else { return nil }
        return ((origin, parrentView, port, parrentView.hub), distance)
    }
    
    private func checkExitAddress(inViews views: [HexagonalView], parrent: HexagonalView, port: HexagonalViewPort) -> Bool {
        if let nextAddress = Int("\(parrent.address)\(port.rawValue)") {
            return views.contains(where: { (_view) -> Bool in
                return _view.address == nextAddress
            })
        }
        return false
    }
    
    private func checkExistCenter(inViews views: [HexagonalView], with center: CGPoint) -> Bool {
        return views.contains(where: { (_view) -> Bool in
            return _view.center == center
        })
    }
    
    private func checkExistDistanceCenter(inViews views: [HexagonalView], with center: CGPoint) -> Bool {
        return views.contains(where: { (_view) -> Bool in
            return _view.center.disance(center) < _view.r/2
        })
    }
}

extension HexagonalPaperView {
    
    func checkParrentOfAllHexagonalViews() {
        for view in self.hexagonalViews {
            if self.checkExistParrent(withView: view) == false {
                self.changeUndefineHub(view: view)
                //view.explode(duration: 3)
                //view.removeFromSuperview()
            }
        }
    }
    
    private func changeUndefineHub(view: HexagonalView) {
        self.undefineHexagonalView.append(view)
        for (i, e) in self.hubHexagonalView[view.hub].enumerated() {
            if e == view {
                hubHexagonalView[view.hub].remove(at: i)
                break
            }
        }
        view.parrentView = nil
        view.address = -1
        view.port = nil
        view.hub = -1
    }
    
    func checkExistParrent(withView view: HexagonalView) -> Bool {
        if view.parrentView == nil && view.address != 1 { return false }
        if view.parrentView == nil { return true }
        var removeLast:[Character] = Array(String(view.address))
        removeLast.removeLast()
        let string = removeLast.compactMap { String($0) }.joined()
        let address = Int(string)!
        return address == view.parrentView!.address
    }
    
}

extension HexagonalPaperView {
    public func randomColor() {
        for _ in 0...4 {
            let random: Int = Int(arc4random_uniform(UInt32(self.hexagonalViews.count - 1)))
            let _view = self.hexagonalViews[random]
            if _view.address != -1 && _view.address != -1 {
                self.hexagonalViews[random].updateColor(UIColor.random)
            }
        }
    }
}



