//
//  String+Extension.swift
//  HoneyComb
//
//  Created by Cao Phuoc Thanh on 4/24/20.
//  Copyright © 2020 Cao Phuoc Thanh. All rights reserved.
//

internal extension String {
    
    subscript(_ r: CountableClosedRange<Int>) -> String {
        let lower = self.index(self.startIndex, offsetBy: r.lowerBound)
        let upper = self.index(self.startIndex, offsetBy: r.upperBound + 1)
        return self.substring(with: Range<String.Index>(uncheckedBounds: (lower: lower, upper: upper)))
    }
    
    subscript(_ r: CountableRange<Int>) -> String {
        let lower = self.index(self.startIndex, offsetBy: r.lowerBound)
        let upper = self.index(self.startIndex, offsetBy: r.upperBound)
        return self.substring(with: Range<String.Index>(uncheckedBounds: (lower: lower, upper: upper)))
    }
    
    subscript(_ r: Int) -> String {
        let index = self.index(self.startIndex, offsetBy: r)
        return String(self[index])
    }
    
}
