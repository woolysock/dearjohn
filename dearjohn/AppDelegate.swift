//
//  AppDelegate.swift
//  dearjohn
//
//  Created by Megan Donahue on 7/23/25.
//  Copyright © 2025 meg&d design. All rights reserved.
//

// AppDelegate.swift
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
