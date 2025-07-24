//
//  Poem_3_Who_Redo_View.swift
//  dearjohn
//
//  Created by Megan Donahue on 7/23/25.
//  Copyright © 2025 meg&d design. All rights reserved.
//

import SwiftUI
import CoreMotion

struct DriftingWord: Identifiable {
    let id = UUID()
    let text: String
    var position: CGPoint
    var velocity: CGSize = .zero
    var textSize: CGSize = .zero
}

struct Poem_3_Who_Redo_View: View {
    @State private var fullLines: [String] = [
        "who writes this code?",
        "me?",
        "",
        "who dreams in pixels?",
        "you?",
        "",
        "who draws the line",
        "between what _is",
        "and what _is generated?",
        "",
        "who creates now?",
        "who is creator?",
        "",
        "who was?",
        "who will be?",
        "",
        "who?"
    ]
    
    @State private var currentText = ""
    @State private var displayedLines: [String] = []
    @State private var currentLineIndex = 0
    @State private var isTyping = true
    
    @State private var wordPositions: [Int: CGPoint] = [:]
    @State private var driftingWords: [DriftingWord] = []
    @State private var inPhase2 = false
    @State private var hasCapturedWordPositions = false
    @State private var typingTimer: Timer?
    @State private var driftTimer: Timer?
    @State private var showBackButton = false
    
    // Motion manager for gyroscope
    private let motionManager = CMMotionManager()
    @State private var gravity = CGSize.zero
    @State private var lastShakeTime: Date = Date()

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if !inPhase2 {
                Phase1View(
                    displayedLines: displayedLines,
                    isTyping: isTyping,
                    currentText: currentText,
                    onWordPositionsCaptured: { positions in
                        wordPositions = positions
                        if !hasCapturedWordPositions && isTypingComplete() {
                            hasCapturedWordPositions = true
                            startPhase2()
                        }
                    }
                )
                .onAppear {
                    startTypingNextLine()
                }
            } else {
                GeometryReader { geometry in
                    TimelineView(.animation) { _ in
                        ZStack {
                            ForEach(driftingWords) { word in
                                Text(word.text)
                                    .font(.system(size: 20, weight: .regular, design: .monospaced))
                                    .foregroundColor(.white)
                                    .position(word.position)
                            }
                            
                            // Back button in top-left corner
                            if showBackButton {
                                VStack {
                                    HStack {
                                        Button(action: {
                                            presentationMode.wrappedValue.dismiss()
                                        }) {
                                            Image(systemName: "chevron.left")
                                                .font(.system(size: 24, weight: .medium))
                                                .foregroundColor(.white)
                                                .padding(12)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Circle())
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                .padding(.top, 50)
                                .padding(.leading, 20)
                            }
                        }
                        .onAppear {
                            startDriftLoop(in: geometry.size)
                        }
                        .onDisappear {
                            stopMotionUpdates()
                        }
                    }
                }
            }
        }
        .coordinateSpace(name: "poem3space")
        .navigationBarHidden(true)
        .statusBarHidden()
        .onAppear {
            // Lock to portrait orientation
            AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
        .onDisappear {
            // Restore all orientations when leaving
            AppDelegate.orientationLock = UIInterfaceOrientationMask.all
        }
    }

    // MARK: - Phase 1 Typing
    
    func isTypingComplete() -> Bool {
        return currentLineIndex >= fullLines.count && !isTyping
    }
    
    func startTypingNextLine() {
        guard currentLineIndex < fullLines.count else {
            isTyping = false
            return
        }
        
        isTyping = true
        currentText = ""
        let line = fullLines[currentLineIndex]
        var charIndex = 0
        
        // Cancel any existing timer
        typingTimer?.invalidate()
        
        typingTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if charIndex < line.count {
                let index = line.index(line.startIndex, offsetBy: charIndex + 1)
                currentText = String(line[..<index])
                charIndex += 1
            } else {
                timer.invalidate()
                displayedLines.append(line)
                currentLineIndex += 1
                isTyping = false
                
                // Small delay before next line
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    startTypingNextLine()
                }
            }
        }
    }

    // Helper function to calculate text size
    func calculateTextSize(for text: String) -> CGSize {
        let font = UIFont.monospacedSystemFont(ofSize: 20, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        return size
    }
    
    // MARK: - Phase 2 Setup + Drift
    
    func startPhase2() {
        inPhase2 = true
        
        // Start gyroscope updates
        startMotionUpdates()
        
        // Create drifting words from all displayed lines, filtering out empty strings
        var flatIndex = 0
        var tempDriftingWords: [DriftingWord] = []
        
        for line in displayedLines {
            if !line.isEmpty {
                let words = line.components(separatedBy: " ")
                for word in words {
                    if !word.isEmpty {
                        let pos = wordPositions[flatIndex] ?? CGPoint(x: 200, y: 200)
                        let randomVelocity = CGSize(
                            width: CGFloat.random(in: -1...1),  // Reduced from -2...2
                            height: CGFloat.random(in: -1...1)  // Reduced from -2...2
                        )
                        let textSize = calculateTextSize(for: word)
                        tempDriftingWords.append(DriftingWord(
                            text: word,
                            position: pos,
                            velocity: randomVelocity,
                            textSize: textSize
                        ))
                        flatIndex += 1
                    }
                }
            }
        }
        
        driftingWords = tempDriftingWords
        
        // Show back button after 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            withAnimation(.easeIn(duration: 0.5)) {
                showBackButton = true
            }
        }
    }

    func startDriftLoop(in size: CGSize) {
        driftTimer?.invalidate()
        driftTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            var updatedWords = driftingWords
            
            for i in updatedWords.indices {
                var word = updatedWords[i]
                
                // Apply gravity influence (very subtle)
                let gravityInfluence: CGFloat = 0.07
                word.velocity.width += gravity.width * gravityInfluence
                word.velocity.height += gravity.height * gravityInfluence
                
                // Apply damping to prevent runaway velocities
                let damping: CGFloat = 0.99
                word.velocity.width *= damping
                word.velocity.height *= damping
                
                // Update position
                word.position.x += word.velocity.width
                word.position.y += word.velocity.height
                
                // Bounce off walls with some energy loss using actual text dimensions
                let bounceEnergy: CGFloat = 0.8
                let halfWidth = word.textSize.width / 2
                let halfHeight = word.textSize.height / 2
                
                if word.position.x - halfWidth < 0 || word.position.x + halfWidth > size.width {
                    word.velocity.width *= -bounceEnergy
                    word.position.x = max(halfWidth, min(size.width - halfWidth, word.position.x))
                }
                if word.position.y - halfHeight < 0 || word.position.y + halfHeight > size.height {
                    word.velocity.height *= -bounceEnergy
                    word.position.y = max(halfHeight, min(size.height - halfHeight, word.position.y))
                }

                updatedWords[i] = word
            }
            
            // Check for word-to-word collisions using actual text dimensions
            for i in 0..<updatedWords.count {
                for j in (i+1)..<updatedWords.count {
                    let word1 = updatedWords[i]
                    let word2 = updatedWords[j]
                    
                    let dx = word1.position.x - word2.position.x
                    let dy = word1.position.y - word2.position.y
                    let distance = sqrt(dx * dx + dy * dy)
                    
                    // Calculate collision distance based on actual text sizes
                    let collisionDistance = max(word1.textSize.width, word1.textSize.height, word2.textSize.width, word2.textSize.height) * 0.6
                    
                    if distance < collisionDistance && distance > 0 {
                        // Calculate collision response
                        let normalX = dx / distance
                        let normalY = dy / distance
                        
                        // Add some energy and randomness to the collision
                        let energyBoost: CGFloat = 1.05
                        let randomFactor: CGFloat = 0.3
                        
                        // Calculate new velocities with some randomness
                        let randomAngle1 = CGFloat.random(in: -randomFactor...randomFactor)
                        let randomAngle2 = CGFloat.random(in: -randomFactor...randomFactor)
                        
                        let newVel1X = (normalX + randomAngle1) * energyBoost
                        let newVel1Y = (normalY + randomAngle2) * energyBoost
                        let newVel2X = (-normalX + randomAngle1) * energyBoost
                        let newVel2Y = (-normalY + randomAngle2) * energyBoost
                        
                        updatedWords[i].velocity.width += newVel1X
                        updatedWords[i].velocity.height += newVel1Y
                        updatedWords[j].velocity.width += newVel2X
                        updatedWords[j].velocity.height += newVel2Y
                        
                        // Separate the words to prevent overlapping
                        let separation: CGFloat = (collisionDistance - distance) / 2
                        updatedWords[i].position.x += normalX * separation
                        updatedWords[i].position.y += normalY * separation
                        updatedWords[j].position.x -= normalX * separation
                        updatedWords[j].position.y -= normalY * separation
                    }
                }
            }
            
            driftingWords = updatedWords
        }
    }
    
    // MARK: - Motion/Gyroscope Functions
    
    func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
            guard let motion = motion else { return }
            
            // Convert device attitude to gravity vector
            // Multiply by small factor for subtle effect
            let gravityStrength: Double = 0.3
            gravity = CGSize(
                width: motion.gravity.x * gravityStrength,
                height: -motion.gravity.y * gravityStrength  // Inverted because screen coordinates
            )
            
            // Detect shake by checking acceleration magnitude
            let acceleration = motion.userAcceleration
            let accelerationMagnitude = sqrt(
                acceleration.x * acceleration.x +
                acceleration.y * acceleration.y +
                acceleration.z * acceleration.z
            )
            
            // Shake threshold and cooldown
            let shakeThreshold: Double = 2.5
            let shakeCooldown: TimeInterval = 0.5
            
            if accelerationMagnitude > shakeThreshold &&
               Date().timeIntervalSince(lastShakeTime) > shakeCooldown {
                lastShakeTime = Date()
                handleShake()
            }
        }
    }
    
    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
        driftTimer?.invalidate()
        driftTimer = nil
    }
    
    // MARK: - Shake Handler
    
    func handleShake() {
        guard let screenBounds = UIScreen.main.bounds as CGRect? else { return }
        
        for i in driftingWords.indices {
            // Jump to new random position
            let newX = CGFloat.random(in: 80...(screenBounds.width - 80))
            let newY = CGFloat.random(in: 100...(screenBounds.height - 100))
            driftingWords[i].position = CGPoint(x: newX, y: newY)
            
            // Give words new random velocities for dynamic effect
            let energyBoost: CGFloat = 2.0
            driftingWords[i].velocity = CGSize(
                width: CGFloat.random(in: -energyBoost...energyBoost),
                height: CGFloat.random(in: -energyBoost...energyBoost)
            )
        }
    }

    // MARK: - Word Position Key
    
    struct WordPositionKey: PreferenceKey {
        static var defaultValue: [Int: CGPoint] = [:]
        static func reduce(value: inout [Int: CGPoint], nextValue: () -> [Int: CGPoint]) {
            value.merge(nextValue()) { $1 }
        }
    }
}

// MARK: - Phase 1 View

private struct Phase1View: View {
    let displayedLines: [String]
    let isTyping: Bool
    let currentText: String
    let onWordPositionsCaptured: ([Int: CGPoint]) -> Void
    @State private var localWordPositions: [Int: CGPoint] = [:]
    
    // Helper function to calculate flat index for a word
    private func flatIndexForWord(lineIndex: Int, wordIndex: Int) -> Int {
        var flatIndex = 0
        for i in 0..<lineIndex {
            let line = displayedLines[i]
            if !line.isEmpty {
                flatIndex += line.components(separatedBy: " ").filter { !$0.isEmpty }.count
            }
        }
        return flatIndex + wordIndex
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(displayedLines.indices, id: \.self) { lineIndex in
                HStack(spacing: 4) {
                    let words = displayedLines[lineIndex].components(separatedBy: " ")
                    ForEach(words.indices, id: \.self) { wordIndex in
                        let word = words[wordIndex]
                        if !word.isEmpty {
                            let index = flatIndexForWord(lineIndex: lineIndex, wordIndex: wordIndex)
                            Text(word)
                                .font(.system(size: 20, weight: .regular, design: .monospaced))
                                .foregroundColor(.white)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(
                                                key: Poem_3_Who_Redo_View.WordPositionKey.self,
                                                value: [index: CGPoint(
                                                    x: geo.frame(in: .named("poem3space")).midX,
                                                    y: geo.frame(in: .named("poem3space")).midY
                                                )]
                                            )
                                    }
                                )
                        }
                    }
                }
            }
            if isTyping {
                Text(currentText + "▌")
                    .font(.system(size: 20, weight: .regular, design: .monospaced))
                    .foregroundColor(.white)
            }
        }
        .padding(.top, 100)
        .padding(.horizontal, 20)
        .onPreferenceChange(Poem_3_Who_Redo_View.WordPositionKey.self) { value in
            localWordPositions = value
            onWordPositionsCaptured(value)
        }
    }
}
