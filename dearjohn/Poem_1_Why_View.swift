//
//  Poem_1_Why_View.swift
//  dearjohn
//
//  Created by Megan Donahue
//  Copyright © 2025 meg&d design. All rights reserved.
//

import SwiftUI

struct PoemLine: Identifiable {
    let id = UUID()
    let text: String
}

enum EntryDirection: CaseIterable {
    case top, bottom, left, right

    static var random: EntryDirection {
        allCases.randomElement()!
    }

    static var randomReversed: EntryDirection {
        switch random {
        case .top: return .bottom
        case .bottom: return .top
        case .left: return .right
        case .right: return .left
        }
    }
}

struct Poem_1_Why_View: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var showSwipeHint = false
    @State private var userHasSwiped = false
    @State private var currentIndex = 0
    @State private var colorInverted = false
    @State private var entryDirection: EntryDirection = .random
    @State private var showMenu = true
    @State private var exitingText: String? = nil
    @State private var exitDirection: CGSize = .zero
    @State private var isExiting = false
    @State private var currentOffset: CGSize = .zero
    @State private var exitingOpacity: Double = 1.0
    @State private var exitingScale: CGFloat = 1.0
    @State private var exitingOffset: CGSize = .zero

    let poemLines: [PoemLine] = [
        PoemLine(text: "WHY"),
        PoemLine(text: "write   code"),
        PoemLine(text: "surely"),
        PoemLine(text: "  code will    "),
        PoemLine(text: "   happily      write write write"),
        PoemLine(text: "ITSELF    for ME"),
        PoemLine(text: "for I"),
        PoemLine(text: "happily happily happily happily happily happily"),
        PoemLine(text: "ASK"),
        PoemLine(text: "it to"),
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                (colorInverted ? Color.white : Color.black).ignoresSafeArea()

                VStack {
                    Spacer()

                    ZStack {
                        // Current text (always show unless we have exiting text)
                        if !isExiting || exitingText == nil {
                            PoemLineViewer(
                                text: poemLines[currentIndex].text,
                                entryDirection: entryDirection,
                                invertedColors: colorInverted,
                                dragOffset: currentOffset
                            )
                            .id("current-\(currentIndex)")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        
                        // Exiting text (overlay on top)
                        if let exitingText = exitingText, isExiting {
                            Text(exitingText)
                                .font(.system(size: 100, weight: .bold))
                                .foregroundColor(colorInverted ? .black : .white)
                                .opacity(exitingOpacity)
                                .scaleEffect(exitingScale)
                                .offset(CGSize(
                                    width: exitingOffset.width + currentOffset.width,
                                    height: exitingOffset.height + currentOffset.height
                                ))
                        }
                    }

                    if showSwipeHint {
                        Text("(swipe in any direction)")
                            .font(.custom("Futura", size: 18))
                            .foregroundColor(.gray)
                            .transition(.opacity)
                            .shadow(color: .white.opacity(0.8), radius: 10)
                            .padding(.top, 20)
                            .onAppear {
                                withAnimation(
                                    Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)
                                ) { }
                            }
                    }

                    Spacer()
                }

                .overlay(alignment: .topLeading) {
                    if showMenu {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(colorInverted ? .black : .white)
                                .padding(12)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding(.top, 50)
                        .padding(.leading, 20)
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isExiting {
                            currentOffset = CGSize(
                                width: value.translation.width * 0.3,
                                height: value.translation.height * 0.3
                            )
                        }
                    }
                    .onEnded { value in
                        if isExiting { return }

                        let swipeThreshold: CGFloat = 50
                        let distance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))

                        if distance > swipeThreshold {
                            isExiting = true  // Prevent further gestures

                            // Calculate a "swipe-away" direction based on current drag
                            let direction = CGVector(
                                dx: value.translation.width,
                                dy: value.translation.height
                            )

                            let magnitude = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
                            let normalized = CGVector(
                                dx: direction.dx / magnitude,
                                dy: direction.dy / magnitude
                            )

                            // Animate the current word flying off in the drag direction
                            withAnimation(.easeInOut(duration: 0.4)) {
                                currentOffset = CGSize(
                                    width: normalized.dx * 500,
                                    height: normalized.dy * 500
                                )
                            }

                            // Wait for animation to finish, then advance
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                currentOffset = .zero
                                advanceIndex(with: value.translation)
                                isExiting = false
                            }

                        } else {
                            // Not a valid swipe - snap back
                            withAnimation(.easeOut(duration: 0.3)) {
                                currentOffset = .zero
                            }
                        }
                    }
            )

        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if !userHasSwiped {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        showSwipeHint = true
                    }
                }
            }

            markPoemViewed("why")
        }
    }

    // MARK: - Exit Animation
    private func startExitAnimation(with translation: CGSize) {
        // Store current text for exit animation
        exitingText = poemLines[currentIndex].text
        
        // Calculate exit trajectory and speed
        let (exitTrajectory, animationSpeed) = calculateExitParameters(from: translation)
        exitDirection = exitTrajectory
        
        // Set initial exit state
        exitingOpacity = 1.0
        exitingScale = 1.0
        exitingOffset = .zero
        isExiting = true
        
        // Start exit animation - mirrors entry animation but in reverse
        withAnimation(.easeIn(duration: animationSpeed)) {
            exitingOffset = exitDirection
            exitingScale = 3.0  // Scale up as it exits (reverse of entry)
            exitingOpacity = 0.0
        }
        
        // Clean up after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed) {
            cleanupExitAnimation()
        }
    }
    
    private func calculateExitParameters(from translation: CGSize) -> (trajectory: CGSize, speed: Double) {
        // Calculate swipe velocity/speed
        let swipeDistance = sqrt(translation.width * translation.width + translation.height * translation.height)
        
        // Base animation duration - faster swipes = faster animations
        let baseSpeed = 1.0
        let speedMultiplier = max(0.3, min(1.5, swipeDistance / 200.0)) // Clamp between 0.3 and 1.5
        let animationSpeed = baseSpeed / speedMultiplier
        
        // Calculate exit trajectory (similar to entry animation distance)
        let exitDistance: CGFloat = 800 // Same as entry animation
        let normalizedX = translation.width / swipeDistance
        let normalizedY = translation.height / swipeDistance
        
        let trajectory = CGSize(
            width: normalizedX * exitDistance,
            height: normalizedY * exitDistance
        )
        
        return (trajectory, animationSpeed)
    }
    
    private func cleanupExitAnimation() {
        isExiting = false
        exitingText = nil
        exitDirection = .zero
        exitingOpacity = 1.0
        exitingScale = 1.0
        exitingOffset = .zero
        currentOffset = .zero
    }

    // MARK: - Word Advancement
    private func advanceToNextWord() {
        if currentIndex < poemLines.count - 1 {
            currentIndex += 1
            entryDirection = .random
        } else {
            currentIndex = 0
            colorInverted.toggle()
            entryDirection = EntryDirection.randomReversed
        }
    }

    private func advanceIndex(with translation: CGSize) {
        userHasSwiped = true
        showSwipeHint = false

        // Start exit animation for current word
        startExitAnimation(with: translation)
        
        // Immediately update to next word (entry animation will start instantly)
        advanceToNextWord()
    }

    private func markPoemViewed(_ id: String) {
        var viewed = UserDefaults.standard.stringArray(forKey: "viewedPoems") ?? []
        if !viewed.contains(id) {
            viewed.append(id)
            UserDefaults.standard.set(viewed, forKey: "viewedPoems")
        }
    }
}

struct PoemLineViewer: View {
    let text: String
    let entryDirection: EntryDirection
    let invertedColors: Bool
    let dragOffset: CGSize

    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 5.0
    @State private var opacity: Double = 0

    var body: some View {
        Text(text)
            .font(.system(size: 100, weight: .bold))
            .foregroundColor(invertedColors ? .black : .white)
            .opacity(opacity)
            .scaleEffect(scale)
            .offset(CGSize(
                width: offset.width + dragOffset.width,
                height: offset.height + dragOffset.height
            ))
            .onAppear {
                startEntranceAnimation()
            }
    }

    // MARK: - Entrance Animation
    private func startEntranceAnimation() {
        // Set initial state
        setInitialEntranceState()
        
        // Animate to final state
        withAnimation(.easeOut(duration: 1.0)) {
            setFinalEntranceState()
        }
    }
    
    private func setInitialEntranceState() {
        offset = calculateInitialOffset()
        scale = 5.0
        opacity = 0
    }
    
    private func setFinalEntranceState() {
        offset = .zero
        scale = 1.0
        opacity = 1.0
    }
    
    private func calculateInitialOffset() -> CGSize {
        switch entryDirection {
        case .top:
            return CGSize(width: 0, height: -800)
        case .bottom:
            return CGSize(width: 0, height: 800)
        case .left:
            return CGSize(width: -800, height: 0)
        case .right:
            return CGSize(width: 800, height: 0)
        }
    }
}
