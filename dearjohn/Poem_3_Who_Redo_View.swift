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
    var fontSize: CGFloat = 20.0
    var fontSizeIncreasing: Bool = true
    var isFlashing: Bool = false
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
    
    // Phase 1 states
    @State private var currentText = ""
    @State private var displayedLines: [String] = []
    @State private var currentLineIndex = 0
    @State private var isTyping = true
    @State private var typingTimer: Timer?
    @State private var fastTypingMode = false
    
    // Phase 2 states
    @State private var wordPositions: [Int: CGPoint] = [:]
    @State private var driftingWords: [DriftingWord] = []
    @State private var inPhase2 = false
    @State private var hasCapturedWordPositions = false
    @State private var driftTimer: Timer?
    @State private var showBackButton = false
    
    // Phase 3 states
    @State private var inPhase3 = false
    @State private var phase3Opacity: Double = 0.0
    
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
                    // Start motion updates for shake detection during Phase 1
                    startMotionUpdates()
                }
            } else {
                GeometryReader { geometry in
                    TimelineView(.animation) { _ in
                        ZStack {
                            ForEach(driftingWords) { word in
                                Text(word.text)
                                    .font(.system(size: word.fontSize, weight: .regular, design: .monospaced))
                                    .foregroundColor(word.isFlashing ? .gray : .white)
                                    .position(word.position)
                            }
                            
                            // Phase 3 gray overlay for top half of screen
                            if inPhase3 {
                                GeometryReader { geo in
                                    VStack(spacing: 0) {
                                        // Top 60% - gray overlay
                                        Rectangle()
                                            .fill(Color.gray)
                                            .opacity(phase3Opacity * 0.6)
                                            .frame(height: geo.size.height * 0.6)
                                        
                                        // Bottom 40% - transparent
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(height: geo.size.height * 0.4)
                                    }
                                }
                                
                                // Instruction text below the gray box
                                VStack {
                                    Spacer()
                                        .frame(height: geometry.size.height * 0.65) // Position just below gray area
                                    Text("can you catch all the words in the gray box?")
                                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                                        .foregroundColor(.white)
                                        .opacity(phase3Opacity)
                                    Spacer()
                                }
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

    // MARK: - Phase 1 Functions (Typing Animation)
    
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
        
        typingTimer = Timer.scheduledTimer(withTimeInterval: fastTypingMode ? 0.005 : 0.05, repeats: true) { timer in
            if charIndex < line.count {
                let index = line.index(line.startIndex, offsetBy: charIndex + 1)
                currentText = String(line[..<index])
                charIndex += 1
            } else {
                timer.invalidate()
                displayedLines.append(line)
                currentLineIndex += 1
                isTyping = false
                
                // Small delay before next line (faster if in fast mode)
                DispatchQueue.main.asyncAfter(deadline: .now() + (fastTypingMode ? 0.02 : 0.4)) {
                    startTypingNextLine()
                }
            }
        }
    }

    // MARK: - Phase 2 Functions (Drifting Words)
    
    func startPhase2() {
        inPhase2 = true
        
        // Motion updates already started in Phase 1, so no need to restart
        
        // Create drifting words from all displayed lines, filtering out empty strings
        var flatIndex = 0
        var tempDriftingWords: [DriftingWord] = []
        
        for line in displayedLines {
            if !line.isEmpty {
                let words = line.components(separatedBy: " ")
                for word in words {
                    if !word.isEmpty {
                        // Use captured position if available, otherwise center screen
                        let pos = wordPositions[flatIndex] ?? CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                        let randomVelocity = CGSize(
                            width: CGFloat.random(in: -1...1),  // Reduced from -2...2
                            height: CGFloat.random(in: -1...1)  // Reduced from -2...2
                        )
                        let textSize = calculateTextSize(for: word, fontSize: 20.0)
                        tempDriftingWords.append(DriftingWord(
                            text: word,
                            position: pos,
                            velocity: randomVelocity,
                            textSize: textSize,
                            fontSize: 20.0,
                            fontSizeIncreasing: true,
                            isFlashing: false
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
        
        // Start Phase 3 after 15 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
            startPhase3()
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
                
                var hitWall = false
                if word.position.x - halfWidth < 0 || word.position.x + halfWidth > size.width {
                    word.velocity.width *= -bounceEnergy
                    word.position.x = max(halfWidth, min(size.width - halfWidth, word.position.x))
                    hitWall = true
                }
                if word.position.y - halfHeight < 0 || word.position.y + halfHeight > size.height {
                    word.velocity.height *= -bounceEnergy
                    word.position.y = max(halfHeight, min(size.height - halfHeight, word.position.y))
                    hitWall = true
                }
                
                // If hit wall, flash gray momentarily
                if hitWall {
                    word.isFlashing = true
                    // Reset flash after 0.15 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        if let index = driftingWords.firstIndex(where: { $0.id == word.id }) {
                            driftingWords[index].isFlashing = false
                        }
                    }
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
                        
                        // Update font sizes for both colliding words
                        updateWordFontSize(&updatedWords[i])
                        updateWordFontSize(&updatedWords[j])
                    }
                }
            }
            
            driftingWords = updatedWords
        }
    }
    
    func updateWordFontSize(_ word: inout DriftingWord) {
        if word.fontSizeIncreasing {
            word.fontSize += 1.0
            if word.fontSize >= 30.0 {
                word.fontSize = 30.0
                word.fontSizeIncreasing = false
            }
        } else {
            word.fontSize -= 1.0
            if word.fontSize <= 10.0 {
                word.fontSize = 10.0
                word.fontSizeIncreasing = true
            }
        }
        
        // Update text size based on new font size
        word.textSize = calculateTextSize(for: word.text, fontSize: word.fontSize)
    }

    // MARK: - Phase 3 Functions (Gray Box Challenge)
    
    func startPhase3() {
        inPhase3 = true
        
        // Slowly fade in the gray overlay over 3 seconds
        withAnimation(.easeInOut(duration: 3.0)) {
            phase3Opacity = 1.0
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
            let shakeThreshold: Double = 2.0  // Reduced from 2.5 for more sensitivity
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
    
    func handleShake() {
        if !inPhase2 {
            // Phase 1: Speed up typing to fast mode
            fastTypingMode = true
        } else if !inPhase3 {
            // Phase 2: Jump to Phase 3
            startPhase3()
        } else {
            // Phase 3: Return to main menu
            presentationMode.wrappedValue.dismiss()
        }
    }

    // MARK: - Helper Functions
    
    // Helper function to calculate text size for a given font size
    func calculateTextSize(for text: String, fontSize: CGFloat) -> CGSize {
        let font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        return size
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
