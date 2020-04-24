//
//  CGPoint+Extension.swift
//  HoneyComb
//
//  Created by Cao Phuoc Thanh on 4/24/20.
//  Copyright © 2020 Cao Phuoc Thanh. All rights reserved.
//

import UIKit

internal extension CGPoint {
    
    func center(withPoint point: CGPoint) -> CGPoint {
        let a = max(self.x, point.x) - min(self.x, point.x)
        let b = max(self.y, point.y) - min(self.y, point.y)
        let x = min(self.x, point.x) + a/2
        let y = min(self.y, point.y) + b/2
        return CGPoint(x: x,
                       y: y)
    }
    
    func disance(_ withPoint: CGPoint) -> CGFloat {
        let a = self.x - withPoint.x
        let b = self.y - withPoint.y
        return CGFloat(sqrt(pow(a,2) + pow(b,2)))
    }
    
    func angle(to comparisonPoint: CGPoint) -> CGFloat {
        let originX = comparisonPoint.x - self.x
        let originY = comparisonPoint.y - self.y
        let bearingRadians = atan2f(Float(originY), Float(originX))
        var bearingDegrees = CGFloat(bearingRadians).degrees
        while bearingDegrees < 0 {
            bearingDegrees += 360
        }
        return bearingDegrees
    }
}
