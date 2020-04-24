//
//  HexagonalContentView.swift
//  HoneyComb
//
//  Created by Admin on 4/2/18.
//  Copyright © 2018 Cao Phuoc Thanh. All rights reserved.
//

import UIKit

internal class HexagonalContentView: UIView {
    
    internal var textLabel: UILabel!
    
    internal var color: UIColor? {
        didSet{
            self.setNeedsDisplay()
        }
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
    
    var r:CGFloat {
        let a = self.frame.width/2
        return a*sqrt(3)/2
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let color = self.color {
            
            let arcStep = 2 * CGFloat.pi / 360
            let isClockwise = false
            let x = rect.width / 2
            let y = rect.height / 2
            let radius = min(x, y) / 2
            let ctx = UIGraphicsGetCurrentContext()
            ctx?.setLineWidth(2 * radius)
            
            let colors: [UIColor] = [UIColor.random.alpha(0.5),
                                     UIColor.random.alpha(0.5),
                                     UIColor.random.alpha(0.5)]
            
            for z in 0..<3 {
                let _colors = self.graint(fromColor: colors[z], toColor: z == 2 ? colors[0] : colors[z+1], count: 120)
                for i in 0..<120 {
                    let color = _colors[i]
                    let startAngle = CGFloat(i+(120*z)) * arcStep
                    let endAngle = startAngle + arcStep + 0.02
                    ctx?.setStrokeColor(color.cgColor)
                    ctx?.addArc(center: CGPoint(x: x, y: y),
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: isClockwise)
                    ctx?.strokePath()
                }
            }
            
            let gradient = CGGradient(colorsSpace: UIColor.white.cgColor.colorSpace,
                                      colors: [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0).cgColor] as CFArray,
                                      locations: [0, 1])
            ctx?.drawRadialGradient(gradient!, startCenter: CGPoint(x: x, y: y), startRadius: 0, endCenter: CGPoint(x: x, y: y), endRadius: 2 * radius, options: .drawsAfterEndLocation)
            
            let polyLayer = drawPolygonLayer(x: rect.midX,y: rect.midY,radius: rect.midX, sides: 6, color: UIColor.yellow, offset: 0)
            self.layer.mask = polyLayer
            
            self.layer.shadowColor = color.withAlphaComponent(0.8).cgColor
            self.layer.shadowOpacity = 3
            self.layer.shadowOffset = CGSize.zero
            self.layer.shadowRadius = 6
        }
    }
    
    func initialSetup() {
        
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        
        self.textLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: self.frame.width, height: 10)))
        self.textLabel.center = self.center
        self.addSubview(textLabel)
        self.textLabel.textColor = UIColor.black
        self.textLabel.backgroundColor = UIColor.clear
        self.textLabel.textAlignment = .center
        self.textLabel.font = UIFont.systemFont(ofSize: 6)
        
    }
    
}


extension HexagonalContentView {
    
    func graint(fromColor:UIColor, toColor:UIColor, count:Int) -> [UIColor]{
        var fromR:CGFloat = 0.0,fromG:CGFloat = 0.0,fromB:CGFloat = 0.0,fromAlpha:CGFloat = 0.0
        fromColor.getRed(&fromR,green: &fromG,blue: &fromB,alpha: &fromAlpha)
        
        var toR:CGFloat = 0.0,toG:CGFloat = 0.0,toB:CGFloat = 0.0,toAlpha:CGFloat = 0.0
        toColor.getRed(&toR,green: &toG,blue: &toB,alpha: &toAlpha)
        
        var result : [UIColor] = []
        
        for i in 0...count {
            let oneR:CGFloat = fromR + (toR - fromR)/CGFloat(count) * CGFloat(i)
            let oneG : CGFloat = fromG + (toG - fromG)/CGFloat(count) * CGFloat(i)
            let oneB : CGFloat = fromB + (toB - fromB)/CGFloat(count) * CGFloat(i)
            let oneAlpha : CGFloat = fromAlpha + (toAlpha - fromAlpha)/CGFloat(count) * CGFloat(i)
            let oneColor = UIColor.init(red: oneR, green: oneG, blue: oneB, alpha: oneAlpha)
            result.append(oneColor)            
        }
        return result
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
        ctx.setFillColor(color.cgColor)
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
