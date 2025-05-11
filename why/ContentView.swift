//ContentView.swift

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
    @State private var isLoading = false

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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isLoading = false
                }
            }
        }
 //   var body: some View {
 //       MainMenuView()
 //   }
}

