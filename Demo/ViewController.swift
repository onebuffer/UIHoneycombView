//
//  ViewController.swift
//  Demo
//
//  Created by Cao Phuoc Thanh on 4/24/20.
//  Copyright © 2020 Cao Phuoc Thanh. All rights reserved.
//

import UIKit
import UIHoneycombView

class ViewController: UIViewController {
    
    var paperView: HexagonalPaperView!
    var previousLocation: CGPoint = CGPoint.zero
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.white
        
        self.paperView = HexagonalPaperView(frame: CGRect(
            x: -self.view.bounds.height,
            y: -self.view.bounds.height,
            width: self.view.bounds.height*3,
            height: self.view.bounds.height*3))
        
        self.paperView.center = self.view.center
        self.paperView.delegate = self
        self.view.addSubview(paperView)
        
        let strings = "1;0072ff:12;ff0000:11;ffe100:121;ffaf20:1212;012343:12121;fe3243:121212;fe3243:1212121;fe3243:12121213;fe3243:121212132;fe3243:1212121322;fe3243:12121213221;fe3243"
        self.paperView.drawHexagonalViews(strings, radius: 60, color: .red)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            let hex = self.paperView.calculateAddressCenter()
            let _center = hex.center
            UIView.animate(withDuration: 2, animations: {
                self.paperView.center.x = _center.x/3 - self.view.bounds.width
            })
        }
        
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(randoomUpdateColor), userInfo: nil, repeats: true)
    }
    
    
    @objc func randoomUpdateColor() {
        self.paperView.randomColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController: HexagonalPaperViewDelegate {
    
    func hexagonalPaperView(view: HexagonalPaperView, touchBegan touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    func hexagonalPaperView(view: HexagonalPaperView, hexagonalView: HexagonalView, touchBegan touches: Set<UITouch>, with event: UIEvent?) {
    }
}


