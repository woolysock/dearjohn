import SwiftUI

struct PoemLine: Identifiable {
    let id = UUID()
    let text: String
}

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Image("why-loading")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("a poem-ai-app-letter")
                    Text("of sorts")
                }
                .font(.custom("Futura", size: 28))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 50)
                
                Spacer().frame(height: 100)
                
                Text("by\nmeg&d design")
                    .font(.custom("Futura", size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
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
                    //WhyPoemView() // app content
                    MenuView()
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

struct WhyPoemView: View {
    @Environment(\.presentationMode) var presentationMode

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
    @State private var entryDirection: EntryDirection = .random
    @State private var cycleCount: Int = 2
    @State private var showMenu: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                (colorInverted ? Color.white : Color.black).ignoresSafeArea()

                PoemLineView(
                    text: poemLines[currentIndex].text,
                    entryDirection: entryDirection,
                    invertedColors: colorInverted
                )
                .id(currentIndex)
                .frame(width: geo.size.width, height: geo.size.height)

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
        .navigationBarBackButtonHidden(true)
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
            
            cycleCount += 1
            if cycleCount >= 2 {
                showMenu = true // now shows system Back button
                return
            }
        }
        
        entryDirection = EntryDirection.random
        NotificationCenter.default.post(name: .triggerEntryAnimation, object: nil)
    }
}

