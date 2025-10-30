//
//  Poem_2_What_View.swift
//  dearjohn
//
//  Created by Megan Donahue on 4/28/25.
//  Copyright © 2025 meg&d design. All rights reserved.
//

import SwiftUI

// MARK: - View Extension to Capture Position
extension View {
    func capturePosition(index: Int, onChange: @escaping (Int, CGPoint) -> Void) -> some View {
        self.background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: WordPositionKey.self, value: [index: geo.frame(in: .global).origin])
            }
        )
        .onPreferenceChange(WordPositionKey.self) { values in
            if let newPos = values[index] {
                onChange(index, newPos)
            }
        }
    }
}

struct WordPositionKey: PreferenceKey {
    static var defaultValue: [Int: CGPoint] = [:]
    
    static func reduce(value: inout [Int: CGPoint], nextValue: () -> [Int: CGPoint]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// MARK: - Main View
struct Poem_2_What_View: View {
    @Environment(\.presentationMode) var presentationMode

    let poemWords = [
        "what", "is", "the", "essence", "of", "creation?",
        "is", "it", "the", "thinking?", "or", "the",
        "doing?", "or", "the", "sharing", "with", "others", "?"
    ]
    
    @State private var wordStates: [WordState] = []
    @State private var finishedWordCount = 0
    @State private var phase2Started = false
    @State private var showFinalWords: [Bool] = []
    @State private var phase3Started = false
    @State private var wordZoomOutStates: [Bool] = []
    @State private var showQuestionMark = false
    @State private var questionMarkScale: CGFloat = 0.1
    @State private var questionMarkTapped = false
    @State private var navigateToMenu = false
    @State private var restartTimer: Timer?
    @State private var wordPositions: [Int: CGPoint] = [:]
    @State private var showMenu = true
    
    // for question mark
    @State private var questionMarkPulse: CGFloat = 1.0
    @State private var showHintText = false
    @State private var hintTextOpacity: Double = 0.0
    @State private var phase4Started = false
    @State private var babyQuestionMarks: [BabyQuestionMark] = []
    @State private var showFinalPoem = false
    @State private var finalPoemLines: [String] = [
        "what",
        "is the",
        "essence",
        "of",
        "creation,",
        "if its",
        "not",
        "just",
        "re-creation?"
    ]
    @State private var finalPoemOpacities: [Double] = []

    struct BabyQuestionMark {
        var id = UUID()
        var position: CGPoint
        var velocity: CGPoint
        var size: CGFloat
        var opacity: Double
        var rotationSpeed: Double
        var currentRotation: Double = 0
        var pathAngle: Double = 0
        var pathRadius: CGFloat = 0
        var pathSpeed: Double = 0
    }
    
    struct WordState {
        var offset: CGSize = CGSize(width: 0, height: -600)
        var opacity: Double = 0
        var rotation: Double = 0
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if !phase2Started {
                    // Phase 1: bouncing words
                    ForEach(poemWords.indices, id: \.self) { index in
                        Text(poemWords[index])
                            .font(.custom("Futura", size: 32))
                            .foregroundColor(.white.opacity(wordStates.indices.contains(index) ? wordStates[index].opacity : 0.9))
                            .offset(wordStates.indices.contains(index) ? wordStates[index].offset : CGSize(width: 0, height: -600))
                            .rotationEffect(.degrees(wordStates.indices.contains(index) ? wordStates[index].rotation : 0))
                            .onAppear {
                                animateWord(at: index)
                            }
                    }
                }
                
                if phase2Started && !phase3Started {
                    // Phase 2: stacked vertical words
                    VStack(alignment: .trailing, spacing: 2) {
                        ForEach(poemWords.indices, id: \.self) { index in
                            Text(poemWords[index])
                                .font(.custom("Futura", size: 32))
                                .foregroundColor(.white)
                                .opacity(showFinalWords.indices.contains(index) && showFinalWords[index] ? 1 : 0)
                                .offset(x: 0, y: showFinalWords.indices.contains(index) && showFinalWords[index] ? 0 : 20)
                                .animation(
                                    .easeOut(duration: 1.2).delay(Double(index) * 0.1),
                                    value: showFinalWords.indices.contains(index) ? showFinalWords[index] : false
                                )
                                .capturePosition(index: index) { idx, point in
                                    saveWordPosition(index: idx, point: point)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .padding(.trailing, 50)
                    .padding(.vertical, 8)
                }
                
                if phase3Started {
                    // Phase 3: words zipping to center
                    ForEach(poemWords.indices, id: \.self) { index in
                        if showFinalWords[index] {
                            Text(poemWords[index])
                                .font(.custom("Futura", size: 32))
                                .foregroundColor(.white)
                                .opacity(wordZoomOutStates[index] ? 0 : 1)
                                .scaleEffect(wordZoomOutStates[index] ? 0.1 : 1)
                                .offset(wordStates[index].offset)
                                .animation(
                                    .easeIn(duration: 1.0),
                                    value: wordStates[index].offset
                                )
                        }
                    }
                }
                
                if showQuestionMark {
                    Group {
                        if !questionMarkTapped {
                            ZStack {
                                // Question mark stays centered
                                Text("?")
                                    .font(.custom("Futura", size: 200))
                                    .foregroundColor(.white)
                                    .scaleEffect(questionMarkScale * questionMarkPulse)
                                    .opacity(0.9)
                                    .onTapGesture {
                                        startPhase4()
                                    }
                                    .onAppear {
                                        restartTimer?.invalidate()
                                        
                                        // Start pulsing after a brief pause
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            startQuestionMarkAnimation()
                                        }
                                        
                                        // Show hint text after longer pause
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                            showHintText = true
                                            withAnimation(.easeInOut(duration: 1.0)) {
                                                hintTextOpacity = 0.6
                                            }
                                        }
                                    }
                                
                                // Hint text positioned below without affecting question mark
                                if showHintText && !phase4Started {
                                    VStack {
                                        Spacer()
                                        Text("tap to continue")
                                            .font(.custom("Futura", size: 16))
                                            .foregroundColor(.white)
                                            .opacity(hintTextOpacity)
                                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: hintTextOpacity)
                                            .offset(y: 120) // Position it below the question mark
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Phase 4: Baby question marks spinning around
                if phase4Started && !showFinalPoem {
                    ForEach(babyQuestionMarks, id: \.id) { babyQM in
                        Text("?")
                            .font(.custom("Futura", size: babyQM.size))
                            .foregroundColor(.white)
                            .opacity(babyQM.opacity)
                            .rotationEffect(.degrees(babyQM.currentRotation))
                            .position(babyQM.position)
                    }
                }

                // Phase 5: Final poem text
                if showFinalPoem {
                    VStack(spacing: 8) {
                        ForEach(0..<finalPoemLines.count, id: \.self) { index in
                            Text(finalPoemLines[index])
                                .font(.custom("Futura", size: 28))
                                .foregroundColor(.white)
                                .opacity(finalPoemOpacities.indices.contains(index) ? finalPoemOpacities[index] : 0)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

            }
            .overlay(alignment: .topLeading) {
                if showMenu {
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
                    .padding(.top, 50)
                    .padding(.leading, 20)
                }
            }
            .onAppear {
                wordStates = Array(repeating: WordState(), count: poemWords.count)
                showFinalWords = Array(repeating: false, count: poemWords.count)
                wordZoomOutStates = Array(repeating: false, count: poemWords.count)
                finalPoemOpacities = Array(repeating: 0.0, count: finalPoemLines.count)
                
                var viewed = UserDefaults.standard.stringArray(forKey: "viewedPoems") ?? []
                if !viewed.contains("what") {
                    viewed.append("what")
                    UserDefaults.standard.set(viewed, forKey: "viewedPoems")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToMenu) {
            MenuView()
        }
    }
    
    // MARK: - Phase 1 Animation (Bouncing)
    func animateWord(at index: Int) {
        let randomDelay = Double.random(in: 0.75...4.0)
        let randomOpacity = Double.random(in: 0.6...1.0)
        let bounceHeight = Double.random(in: 30...70)
        let finalX = Double.random(in: -200...200)
        let finalY = Double.random(in: 800...1000)
        let finalRotation = Double.random(in: -40...40)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
            withAnimation(.easeIn(duration: 0.5)) {
                wordStates[index].offset = CGSize(width: 0, height: 0)
                wordStates[index].opacity = randomOpacity
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let randomXOffset = Double.random(in: -30...30)
                withAnimation(.easeOut(duration: 0.2)) {
                    wordStates[index].offset = CGSize(width: randomXOffset, height: -bounceHeight)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeIn(duration: 0.6)) {
                        wordStates[index].offset = CGSize(width: finalX, height: finalY)
                        wordStates[index].rotation = finalRotation
                        wordStates[index].opacity = 0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        finishedWordCount += 1
                        if finishedWordCount == poemWords.count {
                            withAnimation {
                                phase2Started = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                animateFinalWords()
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Phase 2 Animation (Stack and Capture)
    private func animateFinalWords() {
        for index in poemWords.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                withAnimation {
                    showFinalWords[index] = true
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(poemWords.count) * 0.15 + 2.0) {
            withAnimation {
                phase3Started = true
                let screenCenter = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                for index in poemWords.indices {
                    if let position = wordPositions[index] {
                        let dx = position.x - screenCenter.x
                        let dy = position.y - screenCenter.y
                        wordStates[index].offset = CGSize(width: dx, height: dy)
                    }
                }
            }
            animateZoomOut()
        }
    }

    // MARK: - Phase 3 Animation (Zoom and Fly to Center)
    private func animateZoomOut() {
        for index in poemWords.indices {
            let delay = Double.random(in: 0.2...(2.0))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.2).repeatCount(3, autoreverses: true)) {
                    wordStates[index].offset.width += 10
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    let randomCurveX = CGFloat.random(in: -150...150)
                    let randomCurveY = CGFloat.random(in: -300...300)
                    
                    withAnimation(.easeIn(duration: 1.0)) {
                        wordStates[index].offset = CGSize(width: randomCurveX / 2, height: randomCurveY / 2)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeIn(duration: 0.5)) {
                            wordStates[index].offset = .zero
                            wordZoomOutStates[index] = true
                        }
                        
                        if index == poemWords.count - 1 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                showQuestionMark = true
                                questionMarkScale = 1.0
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Save Word Position
    private func saveWordPosition(index: Int, point: CGPoint) {
        wordPositions[index] = point
    }

    // MARK: - Optional restart hook
    private func restartPoem() {
        questionMarkTapped = false
        showQuestionMark = false
        navigateToMenu = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showQuestionMark = true
        }
    }
    
    // Add this new function to handle the question mark animation:
    private func startQuestionMarkAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            questionMarkPulse = 1.2
        }
    }

    // Phase 4: Explode question mark into spinning babies
    private func startPhase4() {
        phase4Started = true
        showQuestionMark = false
        
        // Create 100 baby question marks exploding from center
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let centerX = screenWidth / 2
        let centerY = screenHeight / 2
        
        for _ in 0..<100 {
            // Random explosion direction
            let explosionAngle = Double.random(in: 0...360) * .pi / 180
            let explosionSpeed = CGFloat.random(in: 100...400)
            
            let babyQM = BabyQuestionMark(
                position: CGPoint(x: centerX, y: centerY), // Start at center
                velocity: CGPoint(
                    x: CGFloat(cos(explosionAngle)) * explosionSpeed,
                    y: CGFloat(sin(explosionAngle)) * explosionSpeed
                ),
                size: CGFloat.random(in: 12...30),
                opacity: Double.random(in: 0.6...1.0),
                rotationSpeed: Double.random(in: -15...15), // Individual spin speed
                pathRadius: CGFloat.random(in: 20...80), // Size of circular path
                pathSpeed: Double.random(in: 2...8) // Speed of circular motion
            )
            babyQuestionMarks.append(babyQM)
        }
        
        // Start the animation
        animateSpinningQuestionMarks()
        
        // After 4 seconds, slow down and fade into final poem
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            slowDownAndTransition()
        }
    }

    private func animateSpinningQuestionMarks() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            guard phase4Started && !showFinalPoem else {
                timer.invalidate()
                return
            }
            
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            for i in 0..<babyQuestionMarks.count {
                // Update the path angle for circular motion around their own center
                babyQuestionMarks[i].pathAngle += babyQuestionMarks[i].pathSpeed
                
                // Calculate circular offset from their current trajectory position
                let circularX = CGFloat(cos(babyQuestionMarks[i].pathAngle * .pi / 180)) * babyQuestionMarks[i].pathRadius
                let circularY = CGFloat(sin(babyQuestionMarks[i].pathAngle * .pi / 180)) * babyQuestionMarks[i].pathRadius
                
                // Update main trajectory position
                babyQuestionMarks[i].position.x += babyQuestionMarks[i].velocity.x * 0.05
                babyQuestionMarks[i].position.y += babyQuestionMarks[i].velocity.y * 0.05
                
                // Apply strong drag to slow down trajectory movement over time
                babyQuestionMarks[i].velocity.x *= 0.985  // Stronger drag
                babyQuestionMarks[i].velocity.y *= 0.985
                
                // Keep them within screen bounds with bouncing that also slows down over time
                let margin: CGFloat = 80
                let centerX = screenWidth / 2
                let centerY = screenHeight / 2
                
                // Calculate current speed to determine bounce strength
                let currentSpeed = sqrt(babyQuestionMarks[i].velocity.x * babyQuestionMarks[i].velocity.x + babyQuestionMarks[i].velocity.y * babyQuestionMarks[i].velocity.y)
                let bounceStrength = max(0.3, min(1.0, currentSpeed / 200)) // Bounce gets weaker as they slow down
                
                if babyQuestionMarks[i].position.x < margin {
                    babyQuestionMarks[i].position.x = margin
                    babyQuestionMarks[i].velocity.x = abs(babyQuestionMarks[i].velocity.x) * bounceStrength + CGFloat.random(in: 10...30)
                    babyQuestionMarks[i].velocity.y += (centerY - babyQuestionMarks[i].position.y) * 0.01
                } else if babyQuestionMarks[i].position.x > screenWidth - margin {
                    babyQuestionMarks[i].position.x = screenWidth - margin
                    babyQuestionMarks[i].velocity.x = -abs(babyQuestionMarks[i].velocity.x) * bounceStrength - CGFloat.random(in: 10...30)
                    babyQuestionMarks[i].velocity.y += (centerY - babyQuestionMarks[i].position.y) * 0.01
                }
                
                if babyQuestionMarks[i].position.y < margin {
                    babyQuestionMarks[i].position.y = margin
                    babyQuestionMarks[i].velocity.y = abs(babyQuestionMarks[i].velocity.y) * bounceStrength + CGFloat.random(in: 10...30)
                    babyQuestionMarks[i].velocity.x += (centerX - babyQuestionMarks[i].position.x) * 0.01
                } else if babyQuestionMarks[i].position.y > screenHeight - margin {
                    babyQuestionMarks[i].position.y = screenHeight - margin
                    babyQuestionMarks[i].velocity.y = -abs(babyQuestionMarks[i].velocity.y) * bounceStrength - CGFloat.random(in: 10...30)
                    babyQuestionMarks[i].velocity.x += (centerX - babyQuestionMarks[i].position.x) * 0.01
                }
                
                // Calculate final position with circular motion, but keep it within bounds
                var finalX = babyQuestionMarks[i].position.x + circularX
                var finalY = babyQuestionMarks[i].position.y + circularY
                
                // Clamp the final position to screen bounds
                finalX = max(20, min(screenWidth - 20, finalX))
                finalY = max(20, min(screenHeight - 20, finalY))
                
                babyQuestionMarks[i].position = CGPoint(x: finalX, y: finalY)
                
                // Update individual rotation (spinning around their own center) - this continues
                babyQuestionMarks[i].currentRotation += babyQuestionMarks[i].rotationSpeed
            }
        }
    }

    private func slowDownAndTransition() {
        // Gradually slow down both trajectory and circular motion
        for i in 0..<babyQuestionMarks.count {
            withAnimation(.easeOut(duration: 2.0)) {
                babyQuestionMarks[i].velocity.x *= 0.1
                babyQuestionMarks[i].velocity.y *= 0.1
                babyQuestionMarks[i].pathSpeed *= 0.3
                babyQuestionMarks[i].rotationSpeed *= 0.2
            }
        }
        
        // After slowing down, fade out babies and show final poem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 1.5)) {
                for i in 0..<babyQuestionMarks.count {
                    babyQuestionMarks[i].opacity = 0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showFinalPoem = true
                animateFinalPoemLines()
            }
        }
    }

    private func animateFinalPoemLines() {
        for i in 0..<finalPoemLines.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    finalPoemOpacities[i] = 1.0
                }
            }
        }
        
        // After final poem is complete, add a way to exit
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(finalPoemLines.count) * 0.4 + 2.0) {
            // Could add another tap gesture or auto-return to menu
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
