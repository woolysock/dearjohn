import SwiftUI

struct PoemLineView: View {
    let text: String
    let isActive: Bool
    let isFirst: Bool
    let hasStartedFirstLine: Bool
    let onFirstLineStart: () -> Void

    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var hasAnimatedIn: Bool = false
    @State private var hasAnimatedOut: Bool = false

    var body: some View {
        Text(text)
            .font(.largeTitle)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .opacity(opacity)
            .offset(y: offsetY)
            .onAppear {
                if isFirst && !hasStartedFirstLine {
                    // First line: animate from top after delay
                    offsetY = -400
                    opacity = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.easeOut(duration: 1.4)) {
                            offsetY = 0
                            opacity = 1
                            hasAnimatedIn = true
                            onFirstLineStart()
                        }
                    }
                } else if !isFirst {
                    // All other lines: start below, wait until active
                    offsetY = 400
                    opacity = 0
                }
            }
            .onChange(of: isActive) { _ in
                if isActive && !hasAnimatedIn {
                    // Animate in from bottom
                    withAnimation(.easeOut(duration: 1.4)) {
                        offsetY = 0
                        opacity = 1
                        hasAnimatedIn = true
                    }
                } else if !isActive && hasAnimatedIn && !hasAnimatedOut {
                    // Animate out upward
                    withAnimation(.easeIn(duration: 1)) {
                        offsetY = -600
                        opacity = 0
                        hasAnimatedOut = true
                    }
                }
            }
    }
}
