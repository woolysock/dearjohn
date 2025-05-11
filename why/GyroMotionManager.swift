//
//  GyroMotionManager.swift
//  why
//
//  Created by Megan Donahue on 5/7/25.
//  Copyright © 2025 meg&d design. All rights reserved.
//


import CoreMotion
import SwiftUI
import Combine

class GyroMotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    private var timer: Timer?
    
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    
    init() {
        startMotionUpdates()
    }
    
    private func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
                guard let motion = motion else { return }
                self?.pitch = motion.attitude.pitch
                self?.roll = motion.attitude.roll
            }
        }
    }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}
