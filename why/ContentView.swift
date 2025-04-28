import SwiftUI

struct PoemLine: Identifiable {
    let id = UUID()
    let text: String
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack{
                Image("why-loading")
                    .resizable()
                    .scaledToFit()
                    .frame(width:60)
                Text("meg&d design")
                    .font(.system(size: 28, weight: .thin))
                    .foregroundColor(.white)
                Text("2025")
                    .font(.system(size: 10, weight: .thin))
                    .foregroundColor(.white)
                
            }
            
        }
    }
}

struct ContentView: View {
    @State private var isLoading = true

        var body: some View {
            Group {
                if isLoading {
                    LoadingView() //custom load screen goes here
                } else {
                    FullPoemView() // app content
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isLoading = false
                }
            }
        }
 //   var body: some View {
 //       MainMenuView()
 //   }
}

struct FullPoemView: View {
    let poemLines: [PoemLine] = [
        PoemLine(text: "WHY"),
        PoemLine(text: "write   code"),
        PoemLine(text: "surely"),
        PoemLine(text: "  code will    "),
        PoemLine(text: "   happily      write write write"),
        PoemLine(text: "ITSELF"),
        PoemLine(text: "for"),
        PoemLine(text: "ME"),
        PoemLine(text: "I"),
        PoemLine(text: "happily happily happily happily happily happily"),
        PoemLine(text: "ASK"),
        PoemLine(text: "it to"),
    ]
    let bookmark: Int = 6
    
    @State private var currentIndex: Int = 0
    @State private var colorInverted: Bool = false
    @State private var scrollDirectionForward: Bool = true
    @GestureState private var dragOffset: CGFloat = 0
    @State private var entryDirection: EntryDirection = .random // <-- New random direction for each line
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                (colorInverted ? Color.white : Color.black).ignoresSafeArea()
                
                PoemLineView(
                    text: poemLines[currentIndex].text,
                    entryDirection: entryDirection, // <-- Pass it in
                    invertedColors: colorInverted
                )
                .id(currentIndex)
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        advanceIndex()
                   }
            )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NotificationCenter.default.post(name: .triggerEntryAnimation, object: nil)
            }
        }
    }
    
    private func advanceIndex() {
        if currentIndex == 0 {
            if colorInverted {
                colorInverted.toggle()
                scrollDirectionForward = true
                currentIndex += 1
            } else {
                currentIndex += 1
            }
        } else if currentIndex < poemLines.count - 1 {
            colorInverted ? (currentIndex -= 1) : (currentIndex += 1)
        } else {
            scrollDirectionForward = false
            colorInverted.toggle()
            currentIndex = bookmark
        }
        
        // ❗ When you change the index, also pick a NEW random direction
        entryDirection = EntryDirection.random
        print("New entry direction: \(entryDirection)")
        NotificationCenter.default.post(name: .triggerEntryAnimation, object: nil)
    }
}

