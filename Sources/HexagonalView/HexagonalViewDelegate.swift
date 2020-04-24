//
//  HexagonalViewDelegate.swift
//  HoneyComb
//
//  Created by Admin on 3/29/18.
//  Copyright © 2018 Cao Phuoc Thanh. All rights reserved.
//

import UIKit

internal protocol HexagonalViewDelegate: class {
    func hexagonalView(view: HexagonalView, touchesBegan touches: Set<UITouch>)
    func hexagonalView(view: HexagonalView, touchesEnded touches: Set<UITouch>)
    func hexagonalView(view: HexagonalView, touchesCancelled touches: Set<UITouch>)
    func hexagonalViewMoveEnded(view: HexagonalView)
    func hexagonalViewMoveing(view: HexagonalView)
    func hexagonalViewTouchViewsInParrent() -> [HexagonalView]
    func hexagonalViewHubHexagonalViews(isInclusde view: HexagonalView) -> [HexagonalView]
    func hexagonalViewCheckValidRoateHub() -> Bool
    func hexagonalViewCheckValidRoateHubWith(view: HexagonalView, translation: CGPoint)
    func hexagonalViewDistanceTwoViewsTouched() -> CGFloat?
}
