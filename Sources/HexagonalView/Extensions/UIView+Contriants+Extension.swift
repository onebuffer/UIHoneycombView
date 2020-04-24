//
//  UIView+Contriants+Extension.swift
//  HIQ-Test-CaoPhuocThanh
//
//  Created by Cao Phuoc Thanh on 10/26/17.
//  Copyright © 2017 Cao Phuoc Thanh. All rights reserved.
//

import UIKit

import UIKit

internal enum LayoutAttributeSize: Int {
    case width
    case height
}

internal enum LayoutAttributeAlign: Int {
    case horizontal
    case vertical
}

internal enum LayoutRelation: Int {
    case left
    case right
    case center
}

internal enum LayoutRelationCenter: Int {
    case centerX
    case centerY
}

internal extension  UIView {
        
    @discardableResult func visualViews(_ visualtFomart: String, metrics: [String: Any]? = nil, views: UIView...) -> [AnyObject] {
        var _views: [String: UIView] = [:]
        for (index, view) in views.enumerated() {
            let key: String = "v" + String(index)
            _views[key] = view
        }
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: visualtFomart, options: [], metrics: metrics, views: _views)
        self.addConstraints(constraints)
        return constraints
    }
    
    @discardableResult func visual(_ format: String, metrics: [String : Any]? = nil , views: [String : Any]) -> [AnyObject] {
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: metrics, views: views)
        self.addConstraints(constraints)
        return constraints
    }
    
    @discardableResult func visualEqual(_ attribute: LayoutAttributeSize, fromView: UIView, toView: UIView ) -> AnyObject {
        switch attribute {
        case .height:
            let constraint = NSLayoutConstraint(item: fromView, attribute: .width, relatedBy: .equal, toItem: toView, attribute: .width, multiplier: 1.0, constant: 0.0)
            self.addConstraint(constraint)
            return constraint
        case .width:
            let constraint = NSLayoutConstraint(item: fromView, attribute: .width, relatedBy: .equal, toItem: toView, attribute: .width, multiplier: 1.0, constant: 0.0)
            self.addConstraint(constraint)
            return constraint
        }
    }
    
    @discardableResult func visualWidth(_ constant: CGFloat) -> AnyObject {
        let widthConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutConstraint.Attribute.width,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: nil,
            attribute: NSLayoutConstraint.Attribute.notAnAttribute,
            multiplier: 1,
            constant: constant
        )
        self.addConstraint(widthConstraint)
        return widthConstraint
    }
    
    @discardableResult func visualHeight(_ constant: CGFloat) -> AnyObject  {
        let widthConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutConstraint.Attribute.height,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: nil,
            attribute: NSLayoutConstraint.Attribute.notAnAttribute,
            multiplier: 1,
            constant: constant
        )
        self.addConstraint(widthConstraint)
        return widthConstraint
    }
    
    func visualSquare(_ attribute: LayoutAttributeSize, constant: CGFloat? = nil) {
        switch attribute {
        case .height:
            if let constant = constant {
                let widthConstraint = NSLayoutConstraint(
                    item: self,
                    attribute: NSLayoutConstraint.Attribute.height,
                    relatedBy: NSLayoutConstraint.Relation.equal,
                    toItem: nil,
                    attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                    multiplier: 1,
                    constant: constant
                )
                self.addConstraint(widthConstraint)
            }
            let constraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0.0)
            self.addConstraint(constraint)
        case .width:
            if let constant = constant {
                let widthConstraint = NSLayoutConstraint(
                    item: self,
                    attribute: NSLayoutConstraint.Attribute.width,
                    relatedBy: NSLayoutConstraint.Relation.equal,
                    toItem: nil,
                    attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                    multiplier: 1,
                    constant: constant
                )
                self.addConstraint(widthConstraint)
            }
            let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0.0)
            self.addConstraint(constraint)
        }
    }
    
    func visualCenter(_ toView: UIView) {
        toView.addConstraints([NSLayoutConstraint(
            item: self,
            attribute: .centerX, relatedBy: .equal,
            toItem: toView, attribute: .centerX,
            multiplier: 1.0, constant: 0.0)])
        toView.addConstraints([NSLayoutConstraint(
            item: self,
            attribute: .centerY, relatedBy: .equal,
            toItem: toView, attribute: .centerY,
            multiplier: 1.0, constant: 0.0)])
    }
    
    func visualCenterX(_ toView: UIView) {
        let constraints = [NSLayoutConstraint(
            item: self,
            attribute: .centerX, relatedBy: .equal,
            toItem: toView, attribute: .centerX,
            multiplier: 1.0, constant: 0.0)]
        toView.addConstraints(constraints)
    }
    
    func visualCenterY(_ toView: UIView) {
        let constraints = [NSLayoutConstraint(
            item: self,
            attribute: .centerY, relatedBy: .equal,
            toItem: toView, attribute: .centerY,
            multiplier: 1.0, constant: 0.0)]
        toView.addConstraints(constraints)
    }
    
    func visualInside(_ toView: UIView, edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
        toView.visual("H:|-(left)-[v]-(right)-|", metrics: ["left": edgeInsets.left, "right": edgeInsets.right], views: ["v": self])
        toView.visual("V:|-(top)-[v]-(bottom)-|", metrics: ["top": edgeInsets.top, "bottom": edgeInsets.bottom], views: ["v": self])
    }
    
    func visualAlignH(_ toView: UIView, constant: CGFloat = 0) {
        toView.visual("H:|-(constant)-[v]-(constant)-|", metrics: ["constant": constant], views: ["v": self])
    }
    
    func visualAlignV(_ toView: UIView, constant: CGFloat = 0) {
        toView.visual("V:|-(constant)-[v]-(constant)-|", metrics: ["constant": constant], views: ["v": self])
    }
    
    @discardableResult func visualAnchorTop(_ toView: UIView, padding: CGFloat? = 8) -> AnyObject {
        let views = ["view": self]
        let metrics = ["padding": Float(padding ?? 8)]
        let contriants = toView.visual("V:|-(padding)-[view]", metrics: metrics as [String : AnyObject]?, views: views)
        return contriants[0]
    }
    
    @discardableResult func visualAnchorRight(_ toView: UIView, padding: CGFloat? = 8) -> AnyObject {
        let views = ["view": self]
        let metrics = ["padding": Float(padding ?? 8)]
        let contriants = toView.visual("H:[view]-(padding)-|", metrics: metrics as [String : AnyObject]?, views: views)
        return contriants[0]
    }
    
    @discardableResult func visualAnchorLeft(_ toView: UIView, padding: CGFloat? = 8) -> AnyObject {
        let views = ["view": self]
        let metrics = ["padding": Float(padding ?? 8)]
        let contriants = toView.visual("H:|-(padding)-[view]", metrics: metrics as [String : AnyObject]?, views: views)
        return contriants[0]
    }
    
    @discardableResult func visualAnchorBottom(_ toView: UIView, padding: CGFloat? = 8) -> AnyObject {
        let views = ["view": self]
        let metrics = ["padding": Float(padding ?? 8)]
        let contriants = toView.visual("V:[view]-(padding)-|", metrics: metrics as [String : AnyObject]?, views: views)
        return contriants[0]
    }
}


