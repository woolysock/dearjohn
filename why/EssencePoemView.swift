//
//  EssencePoemView.swift
//  dearjohn
//
//  Created by Megan Donahue on 4/28/25.
//  Copyright © 2025 meg&d design. All rights reserved.
//
import SwiftUI

struct EssencePoemView: View {
    let poemLines = [
        "what", "is", "the", "essence", "of", "creation",
        "is", "it", "the", "thinking", "or", "the",
        "doing", "the", "sharing", "with", "others"
    ]
    
    @State private var wordStates: [WordState] = []
    
    struct WordState {
        var offset: CGSize = CGSize(width: 0, height: -600)
        var opacity: Double = 0
        var rotation: Double = 0
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ForEach(poemLines.indices, id: \.self) { index in
                Text(poemLines[index])
                    .font(.custom("Futura", size: 32))
                    .foregroundColor(.white.opacity(wordStates.indices.contains(index) ? wordStates[index].opacity : 0.9))
                    .offset(wordStates.indices.contains(index) ? wordStates[index].offset : CGSize(width: 0, height: -600))
                    .rotationEffect(.degrees(wordStates.indices.contains(index) ? wordStates[index].rotation : 0))
                    .onAppear {
                        animateWord(at: index)
                    }
            }
        }
        .onAppear {
            wordStates = Array(repeating: WordState(), count: poemLines.count)
        }
    }
    
    private func animateWord(at index: Int) {
        let randomDelay = Double.random(in: 0.5...3.0) // Longer gaps between words
        let randomOpacity = Double.random(in: 0.6...1.0) // Vary initial opacity
        let bounceHeight = Double.random(in: 30...70) // Random bounce height
        let finalX = Double.random(in: -200...200) // Final X position
        let finalY = Double.random(in: 800...1000) // Final Y position
        let finalRotation = Double.random(in: -40...40) // Random rotation during fall off
        
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
            // Fall to mid-point
            withAnimation(.easeIn(duration: 0.5)) {
                wordStates[index].offset = CGSize(width: 0, height: 0)
                wordStates[index].opacity = randomOpacity
            }
            
            // Bounce immediately after reaching mid-point
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let randomXOffset = Double.random(in: -30...30)
                withAnimation(.easeOut(duration: 0.2)) {
                    wordStates[index].offset = CGSize(width: randomXOffset, height: -bounceHeight)
                }
                
                // Fall off-screen with slight spin
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeIn(duration: 0.6)) {
                        wordStates[index].offset = CGSize(width: finalX, height: finalY)
                        wordStates[index].rotation = finalRotation
                        wordStates[index].opacity = 0
                    }
                }
            }
        }
    }
}
