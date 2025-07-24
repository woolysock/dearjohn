// Poem_3_Who_View.swift
// dearjohn

//WORKING DRAFT _ MAY 10 2025

import SwiftUI

import CoreMotion

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    @Published var roll: Double = 0.0
    @Published var pitch: Double = 0.0
    @Published var acceleration: CMAcceleration = .init(x: 0, y: 0, z: 0)
    @Published var accelerationMagnitude: Double = 0.0
    
    init() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard let motion = motion else { return }
            self.roll = motion.attitude.roll
            self.pitch = motion.attitude.pitch
            self.acceleration = motion.userAcceleration
            self.accelerationMagnitude = sqrt(pow(self.acceleration.x, 2) +
                                              pow(self.acceleration.y, 2) +
                                              pow(self.acceleration.z, 2))
        }
    }
}

struct Poem_3_Who_View: View {
    @ObservedObject var motion = MotionManager()
    @State private var scatteredLines: [ScatteredLine] = []
    @State private var allGone = false
    
    let lines: [String] = [
        "who",
        "writes",
        "this",
        "code",
        
        "me?",
        
        "who",
        "dreams",
        "in",
        "pixels",
        
        "you?",
        
        "who",
        "draws",
        "the",
        "line",
        "between",
        "what is",
        "and what is generated",
        
        "who",
        "creates",
        "now",
        
        "who",
        "is",
        "creator",
        
        "who",
        "was?",
        "who",
        "will be?",
        
        "who?"
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ForEach(scatteredLines) { line in
                Text(line.text)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.white)
                    .opacity(line.isVisible ? 1 : 0)
                    .scaleEffect(line.scale)
                    .position(x: line.position.width + CGFloat(motion.roll * 50),
                              y: line.position.height + CGFloat(motion.pitch * 50))
                    .rotationEffect(line.rotation)
                    .animation(.easeInOut(duration: 0.5), value: motion.roll)
            }
            
//            VStack {
//                Spacer()
//                NavigationLink("Back", destination: MenuView())
//                    .padding()
//                    .background(Color.white.opacity(0.2))
//                    .foregroundColor(.white)
//                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                    .padding()
//            }
        }
        .onAppear {
            // Start presenting lines one by one
            Task {
                for (i, line) in lines.enumerated() {
                    let initialScale: CGFloat = 5.0
                    let targetScale: CGFloat = 1.0
                    
                    let randomX = CGFloat.random(in: 50...UIScreen.main.bounds.width - 50)
                    let randomY = CGFloat.random(in: 50...UIScreen.main.bounds.height - 150)
                    
                    let scatter = ScatteredLine(
                        id: UUID(),
                        text: line,
                        position: CGSize(width: randomX, height: randomY),
                        scale: initialScale,
                        rotation: .zero,
                        isVisible: false
                    )
                    
                    scatteredLines.append(scatter)
                    
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    
                    withAnimation(.easeOut(duration: 1.0)) {
                        scatteredLines[i].isVisible = true
                        scatteredLines[i].scale = targetScale
                    }
                }
            }
            
            // Start drift timer with dynamic speed
            Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
                let screenWidth = UIScreen.main.bounds.width
                let screenHeight = UIScreen.main.bounds.height-100

                let horizontalPadding: CGFloat = 100 // to keep text fully on screen
                let verticalPadding: CGFloat = 200

                let normalizedRoll = max(min(motion.roll, .pi/4), -.pi/4) / (.pi/4)
                let normalizedPitch = max(min(motion.pitch, .pi/4), -.pi/4) / (.pi/4)

                let baseSpeed: CGFloat = 0.4
                let maxBoost: CGFloat = 2.0

                let rollSpeed = CGFloat(normalizedRoll) * baseSpeed * (1 + abs(CGFloat(normalizedRoll)) * maxBoost)
                let pitchSpeed = CGFloat(normalizedPitch) * baseSpeed * (1 + abs(CGFloat(normalizedPitch)) * maxBoost)

                for i in scatteredLines.indices {
                    guard scatteredLines[i].isVisible else { continue }

                    // Update positions
                    scatteredLines[i].position.width += rollSpeed
                    scatteredLines[i].position.height += pitchSpeed

                    // Clamp to keep inside screen bounds
                    scatteredLines[i].position.width = min(max(scatteredLines[i].position.width, horizontalPadding),
                                                           screenWidth - horizontalPadding)
                    scatteredLines[i].position.height = min(max(scatteredLines[i].position.height, verticalPadding),
                                                            screenHeight - verticalPadding)
                }
            }

        }
        
        .onChange(of: motion.accelerationMagnitude) {
            if motion.accelerationMagnitude > 2.0 && !allGone {
                allGone = true
                
                for i in scatteredLines.indices {
                    withAnimation(.easeInOut(duration: 0.1).repeatCount(5, autoreverses: true)) {
                        scatteredLines[i].position.width += CGFloat.random(in: -30...30)
                        scatteredLines[i].position.height += CGFloat.random(in: -30...30)
                        scatteredLines[i].rotation = Angle(degrees: Double.random(in: -15...15))
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 2.0)) {
                        scatteredLines.removeAll()
                    }
                }
            }
        }
    }
}

struct ScatteredLine: Identifiable {
    let id: UUID
    let text: String
    var position: CGSize
    var scale: CGFloat
    var rotation: Angle = .zero
    var isVisible: Bool
}
