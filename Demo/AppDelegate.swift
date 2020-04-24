//
//  AppDelegate.swift
//  Demo
//
//  Created by Cao Phuoc Thanh on 4/24/20.
//  Copyright © 2020 Cao Phuoc Thanh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
         let window    = UIWindow(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            self.window?.backgroundColor = UIColor.systemBackground
        } else {
            self.window?.backgroundColor = .white
        }
         self.window = window
         let viewController = ViewController()
         self.window?.rootViewController = viewController
         self.window?.makeKeyAndVisible()
         
         return true
     }


}

