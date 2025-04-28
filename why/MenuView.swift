struct MenuView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                NavigationLink(destination: BlankScreen1()) {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(height: 150)
                        .overlay(Text("Screen 1").foregroundColor(.white))
                        .cornerRadius(12)
                }
                NavigationLink(destination: BlankScreen2()) {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(height: 150)
                        .overlay(Text("Screen 2").foregroundColor(.white))
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct BlankScreen1: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Text("Blank Screen 1")
                .font(.largeTitle)
                .foregroundColor(.black)
        }
    }
}

struct BlankScreen2: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Text("Blank Screen 2")
                .font(.largeTitle)
                .foregroundColor(.black)
        }
    }
}
