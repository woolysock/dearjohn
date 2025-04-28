// PoemLineView.swift
import SwiftUI

enum EntryDirection: CaseIterable {
    case top, bottom, left, right

    static var random: EntryDirection {
        allCases.randomElement()!
    }

    static var randomReversed: EntryDirection {
        switch allCases.randomElement()! {
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

struct PoemLineView: View {
    let text: String
    let entryDirection: EntryDirection
    let invertedColors: Bool

    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 5.0
    @State private var opacity: Double = 0

    var body: some View {
        Text(text)
            .font(.system(size: 100, weight: .bold, design: .default))
            .foregroundColor(invertedColors ? .black : .white)
            .opacity(opacity)
            .scaleEffect(scale)
            .offset(offset)
            .onAppear {
                animateEntry()
            }
    }

    private func animateEntry() {
        // Reset the initial position based on the random entry direction
        switch entryDirection {
        case .top:
            offset = CGSize(width: 0, height: -1000)
        case .bottom:
            offset = CGSize(width: 0, height: 1000)
        case .left:
            offset = CGSize(width: -1000, height: 0)
        case .right:
            offset = CGSize(width: 1000, height: 0)
        }
        scale = 15.0
        opacity = 0

        withAnimation(.easeOut(duration: 1.0)) {
            offset = .zero
            scale = 1.0
            opacity = 1.0
        }
    }
}
