// Poem_3_Who_View.swift

import SwiftUI

//WORKING DRAFT _ MAY 8 2025
//import CoreMotion
//
//class MotionManager: ObservableObject {
//    private var motionManager = CMMotionManager()
//    @Published var roll: Double = 0.0
//    @Published var pitch: Double = 0.0
//
//    init() {
//        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
//        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
//            guard let motion = motion else { return }
//            self.roll = motion.attitude.roll
//            self.pitch = motion.attitude.pitch
//        }
//    }
//}
//
//struct Poem_3_Who_View: View {
//    @State private var currentIndex = 0
//    @ObservedObject var motion = MotionManager()
//    @State private var lastAdvanceTime = Date()
//
//    let lines: [String] = [
//        "who?",
//        "was",
//        "i",
//        "in time",
//        "in place",
//        "who will be",
//        "me?",
//        "and now",
//        "who creates now",
//        "who?"
//    ]
//
//    var body: some View {
//        ZStack {
//            Color.black.ignoresSafeArea()
//            VStack {
//                Spacer()
//                Text(lines[currentIndex])
//                    .font(.system(size: 64, weight: .bold))
//                    .foregroundColor(.white)
//                    .offset(x: CGFloat(motion.roll) * 100, y: CGFloat(motion.pitch) * 100)
//                    .transition(getTransition(for: currentIndex))
//                    .id(currentIndex)
//                Spacer()
//            }
//        }
//        .onChange(of: currentIndex) {
//            advanceLine()
//        }
//        .onChange(of: motion.pitch) {
//            if motion.pitch > 1 && Date().timeIntervalSince(lastAdvanceTime) > 1 {
//                skipToNextLine()
//            }
//        }
//        .onAppear {
//            advanceLine()
//        }
//        .navigationBarBackButtonHidden(false)
//    }
//
//    func advanceLine() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//            skipToNextLine()
//        }
//    }
//
//    func skipToNextLine() {
//        if currentIndex < lines.count - 1 {
//            withAnimation {
//                currentIndex += 1
//                lastAdvanceTime = Date()
//            }
//        }
//    }
//
//    func getTransition(for index: Int) -> AnyTransition {
//        switch index {
//        case 0...3: return .move(edge: .top) // Phase 1: Slow Reveal
//        case 4: return .move(edge: .leading) // Phase 2: Disruption
//        case 7: return .scale // Phase 3: Whispers
//        default: return .opacity
//        }
//    }
//}


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

            VStack {
                Spacer()
                NavigationLink("Back", destination: MenuView())
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
            }
        }
        .onAppear {
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
