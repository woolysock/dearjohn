// Poem_1_Why_View.swift

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

extension Notification.Name {
    static let triggerEntryAnimation = Notification.Name("triggerEntryAnimation")
}

struct Poem_1_Why_View: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var showSwipeHint = false
    @State private var userHasSwiped = false
    @State private var currentIndex = 0
    @State private var colorInverted = false
    @State private var entryDirection: EntryDirection = .random
    @GestureState private var dragOffset: CGFloat = 0
    @State private var showMenu = true

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
            ZStack {
                (colorInverted ? Color.white : Color.black).ignoresSafeArea()

                VStack {
                    Spacer()

                    PoemLineViewer(
                        text: poemLines[currentIndex].text,
                        entryDirection: entryDirection,
                        invertedColors: colorInverted
                    )
                    .id(currentIndex)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

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
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .padding()
                            .foregroundColor(colorInverted ? .black : .white)
                        }
                    }
                }
            }
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { _ in
                        advanceIndex()
                    }
            )
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Trigger the entry animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NotificationCenter.default.post(name: .triggerEntryAnimation, object: nil)
            }

            // Show swipe hint after 3s if no swipe
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if !userHasSwiped {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        showSwipeHint = true
                    }
                }
            }

            // Mark this poem as viewed
            markPoemViewed("why")
        }
    }

    // Advance through poem lines
    private func advanceIndex() {
        userHasSwiped = true
        showSwipeHint = false

        if currentIndex < poemLines.count - 1 {
            currentIndex += 1
            entryDirection = .random
        } else {
            currentIndex = 0
            colorInverted.toggle()
            entryDirection = EntryDirection.randomReversed
        }
    }

    // Save poem view state
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

    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 5.0
    @State private var opacity: Double = 0

    var body: some View {
        Text(text)
            .font(.system(size: 100, weight: .bold))
            .foregroundColor(invertedColors ? .black : .white)
            .opacity(opacity)
            .scaleEffect(scale)
            .offset(offset)
            .onAppear {
                animateEntry()
            }
    }

    private func animateEntry() {
        // Set offset based on direction
        switch entryDirection {
        case .top: offset = CGSize(width: 0, height: -800)
        case .bottom: offset = CGSize(width: 0, height: 800)
        case .left: offset = CGSize(width: -800, height: 0)
        case .right: offset = CGSize(width: 800, height: 0)
        }

        scale = 5.0
        opacity = 0

        withAnimation(.easeOut(duration: 1.0)) {
            offset = .zero
            scale = 1.0
            opacity = 1.0
        }
    }
}
