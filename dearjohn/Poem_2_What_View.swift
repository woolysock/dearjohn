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
                                        withAnimation(.easeOut(duration: 0.5)) {
                                            presentationMode.wrappedValue.dismiss()
                                        }
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
                                if showHintText {
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
    
    private func startQuestionMarkAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            questionMarkPulse = 1.2
        }
    }

    
}

