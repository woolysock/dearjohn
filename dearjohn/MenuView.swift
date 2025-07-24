//
//  MenuView.swift
//  dearjohn
//
//  Created by Megan Donahue on 4/28/25.
//  Copyright © 2025 meg&d design. All rights reserved.
//
import SwiftUI

struct MenuView: View {
    
    @State private var stackHeight: CGFloat = 0
    @State private var imageHeight: CGFloat = 0
    
    // Track which poems have been viewed
    @State private var viewedPoems: Set<String> = []
        
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                
                let desiredBottomY = geo.size.height * 0.4
                
                ZStack {
                    // Background: Top 40% black, bottom 60% white
                    VStack(spacing: 0) {
                        Color.black
                            .frame(height: desiredBottomY)
                        Color.white
                            .frame(height: geo.size.height * 0.6)
                    }
                    .ignoresSafeArea()
                    
                                       
                    VStack(spacing:0){
                        
                        //Spacer(minLength: max(0, desiredBottomY - imageHeight))
                        
                        Image("title-white")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.5)
                            .background(
                                GeometryReader { imgGeo in
                                    Color.clear
                                        .onAppear {
                                            imageHeight = imgGeo.size.height
                                        }
                                        .onChange(of: imgGeo.size.height) {
                                            imageHeight = imgGeo.size.height
                                        }
                                }
                            )
            
                        Image("title-black-flip")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.5)
            
                        Spacer().frame(height: 30)
                        
                        Text("a digital book")
                            .font(.custom("Futura", size: 22))
                            .foregroundColor(.black)
                        Text("of poems")
                            .font(.custom("Futura", size: 22))
                            .foregroundColor(.black)
                        
                        Spacer().frame(height: 100)
                        NavigationLink(destination: AboutArtist()) {
                            poemButton(title: "about", b_size: 80, isViewed: false)
                        }
                        Spacer().frame(height: 10)
                        Text("©2025 meg&d design")
                            .font(.custom("Futura", size: 8))
                            .foregroundColor(.gray)
                        
                    }
                    .background(
                        GeometryReader { stackGeo in
                            Color.clear
                                .onAppear {
                                    stackHeight = stackGeo.size.height
                                }
                                .onChange(of: stackGeo.size.height) {
                                    stackHeight = stackGeo.size.height
                                }
                        }
                    )
                    .position(
                        x: geo.size.width * 0.65,
                        y: desiredBottomY + (stackHeight / 2) - imageHeight
                    )
                    .ignoresSafeArea()
                    
                    
                    // Vertical stack of buttons in bottom-left
                    VStack {
                        // Menu List
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 1), spacing: 10) {
                            NavigationLink(destination: Poem_1_Why_View()
                                .onDisappear {
                                    viewedPoems.insert("why")
                                }
                            ) {
                                poemButton(title: "why", b_size: 100, isViewed: viewedPoems.contains("why"))
                            }
                            NavigationLink(destination: Poem_2_What_View()
                                .onDisappear {
                                    viewedPoems.insert("what")
                                }
                            ) {
                                poemButton(title: "what", b_size: 100, isViewed: viewedPoems.contains("what"))
                            }
                            NavigationLink(destination: Poem_3_Who_Redo_View()
                                .onDisappear {
                                    viewedPoems.insert("who")
                                }
                            ) {
                                poemButton(title: "who", b_size: 100, isViewed: viewedPoems.contains("who"))
                            }
//                            NavigationLink(destination: Poem_4_How_View()
//                                .onDisappear {
//                                    viewedPoems.insert("how")
//                                }
//                            ) {
//                                poemButton(title: "how", b_size: 100, isViewed: viewedPoems.contains("how"))
//                            }
                        }
                        .position(
                            x: 70,
                            y: geo.size.height-50-(400+(10*3))/2
                        )
                    }
                }
            .navigationBarHidden(true)
            }
        }
    }
    
    // Modified button function to handle viewed state
    func poemButton(title: String, b_size: CGFloat, isViewed: Bool) -> some View {
        Rectangle()
            .fill(isViewed ? Color.black : Color.gray)
            .frame(width: b_size, height: b_size)
            .overlay(
                VStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .fill(isViewed ? Color.gray : Color.black)
                        .frame(height: 10)
                },
                alignment: .bottom
            )
            .overlay(
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(isViewed ? Color.gray : Color.black)
                        .frame(width: 10)
                    Spacer()
                },
                alignment: .leading
            )
            .overlay(
                VStack(spacing: 0) {
                    Text(title)
                        .font(.custom("Futura", size: 18))
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.leading)
                        .padding(10)
                },
                alignment: .bottom
            )
    }
}














// MGD: THE LAST DRAFT BEFORE I ADDED THE CLAUDE REWRITE


////
////  MenuView.swift
////  dearjohn
////
////  Created by Megan Donahue on 4/28/25.
////  Copyright © 2025 meg&d design. All rights reserved.
////
//import SwiftUI
//
//struct MenuView: View {
//    
//    @State private var stackHeight: CGFloat = 0
//    @State private var imageHeight: CGFloat = 0
//        
//    var body: some View {
//        NavigationView {
//            GeometryReader { geo in
//                
//                let desiredBottomY = geo.size.height * 0.4
//                
//                ZStack {
//                    // Background: Top 40% black, bottom 60% white
//                    VStack(spacing: 0) {
//                        Color.black
//                            .frame(height: desiredBottomY)
//                        Color.white
//                            .frame(height: geo.size.height * 0.6)
//                    }
//                    .ignoresSafeArea()
//                    
//                                       
//                    VStack(spacing:0){
//                        
//                        //Spacer(minLength: max(0, desiredBottomY - imageHeight))
//                        
//                        Image("title-white")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: geo.size.width * 0.5)
//                            .background(
//                                GeometryReader { imgGeo in
//                                    Color.clear
//                                        .onAppear {
//                                            imageHeight = imgGeo.size.height
//                                        }
//                                        .onChange(of: imgGeo.size.height) {
//                                            imageHeight = imgGeo.size.height
//                                        }
//                                }
//                            )
//            
//                        Image("title-black-flip")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: geo.size.width * 0.5)
//            
//                        Spacer().frame(height: 30)
//                        
//                        Text("a digital book")
//                            .font(.custom("Futura", size: 22))
//                            .foregroundColor(.black)
//                        Text("of poems")
//                            .font(.custom("Futura", size: 22))
//                            .foregroundColor(.black)
//                        
//                        Spacer().frame(height: 100)
//                        NavigationLink(destination: AboutArtist()) {
//                            poemButton(title: "about", b_size: 80)
//                        }
//                        Spacer().frame(height: 10)
//                        Text("©2025 meg&d design")
//                            .font(.custom("Futura", size: 8))
//                            .foregroundColor(.gray)
//                        
//                        
////                        Text("y: \(desiredBottomY) + ih: \(imageHeight) + sh: \(stackHeight) + screen: \(geo.size.height)")
////                            .font(.custom("Futura", size: 8))
////                            .foregroundColor(.black)
//                    }
//                    .background(
//                        GeometryReader { stackGeo in
//                            Color.clear
//                                .onAppear {
//                                    stackHeight = stackGeo.size.height
//                                }
//                                .onChange(of: stackGeo.size.height) {
//                                    stackHeight = stackGeo.size.height
//                                }
//                        }
//                    )
//                    .position(
//                        x: geo.size.width * 0.65,
//                        y: desiredBottomY + (stackHeight / 2) - imageHeight
//                    )
//                    .ignoresSafeArea()
//                    
//                    
//                    // Vertical stack of buttons in bottom-left
//                    VStack {
//                        // Menu List
//                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 1), spacing: 10) {
//                            NavigationLink(destination: Poem_1_Why_View()) {
//                                poemButton(title: "why", b_size: 100)
//                            }
//                            NavigationLink(destination: Poem_2_What_View()) {
//                                poemButton(title: "what", b_size: 100)
//                            }
//                            NavigationLink(destination: Poem_3_Who_Redo_View()) {
//                                poemButton(title: "who", b_size: 100)
//                            }
////                            NavigationLink(destination: Poem_4_How_View()) {
////                                poemButton(title: "how", b_size: 100)
////                            }
//                        }
//                        .position(
//                            x: 70,
//                            y: geo.size.height-50-(400+(10*3))/2
//                        )
//                    }
//                }
//            .navigationBarHidden(true)
//            
//            
//            //  // PREVIOUS
//            //// ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★
//            //            ZStack {
//            //                Color.black.ignoresSafeArea()
//            //                VStack {
//            //                    Image("why-loading")
//            //                        .resizable()
//            //                        .scaledToFit()
//            //                        .frame(width: 200)
//            //
//            //                    Spacer()
//            //
//            //                    Rectangle()
//            //                        .fill(Color.white)
//            //                        .scaledToFit()
//            //                        .frame(height:800)
//            //                }
//            //                VStack {
//            //                    // Menu List
//            //                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 1), spacing: 20) {
//            //                        NavigationLink(destination: Poem_1_Why_View()) {
//            //                            poemButton(title: "why?")
//            //                        }
//            //                        NavigationLink(destination: Poem_2_What_View()) {
//            //                            poemButton(title: "what?")
//            //                        }
//            //                        NavigationLink(destination: Poem_3_Who_View()) {
//            //                            poemButton(title: "who?")
//            //                        }
//            //                        NavigationLink(destination: Poem_4_How_View()) {
//            //                            poemButton(title: "how?")
//            //                        }
//            //                    }
//            //                    .padding()
//            //
//            //                    Spacer().frame(height: 20)
//            //
//            //                    // About the Artist Button
//            //                    NavigationLink(destination: AboutArtist()) {
//            //                        Rectangle()
//            //                            .fill(Color.gray)
//            //                            .frame(width: 200, height: 50)
//            //                            .overlay(
//            //                                Text("about the artist")
//            //                                    .font(.custom("Futura", size: 12))
//            //                                    .foregroundColor(.white)
//            //                                    .multilineTextAlignment(.center)
//            //                            )
//            //                    }
//            //                    .padding(.bottom, 20)
//            //
//            //                    Text("©meg&d design 2025")
//            //                        .font(.custom("Futura", size: 10))
//            //                        .foregroundColor(.gray)
//            //                        .padding(.bottom, 10)
//            //
//            //                }
//            //                .padding()
//            
//            }
//        }
//    }
//    
////    // Reusable button style
////    // NINETIES VARIATION WITH BLUE STRIPES
////    // ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★
////    func poemButton(title: String) -> some View {
////        Rectangle()
////            .overlay(
////                Rectangle()
////                    .fill(Color.white)
////                    .aspectRatio(1, contentMode: .fit)
////                    .overlay(
////                        Text(title)
////                            .font(.custom("Futura", size: 12))
////                            .foregroundColor(.black)
////                            .multilineTextAlignment(.leading)
////                            .padding(5)
////                    )
////                    .foregroundColor(.white)
////                    .frame(width: 100, height: 50, alignment: .bottomLeading)
////            )
////    }
//    
//    // Reusable button style
//    // ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★
//    
//    
//    func poemButton(title: String, b_size: CGFloat) -> some View {
//        Rectangle()
//            .fill(Color.gray)
//            .frame(width: b_size, height: b_size)
//            .overlay(
//                VStack(spacing: 0) {
//                    Spacer()
//                    Rectangle()
//                        .fill(Color.black)
//                        .frame(height: 10)
//                },
//                alignment: .bottom
//            )
//            .overlay(
//                HStack(spacing: 0) {
//                    Rectangle()
//                        .fill(Color.black)
//                        .frame(width: 10)
//                    Spacer()
//                },
//                alignment: .leading
//            )
//        
//            .overlay(
//                VStack(spacing: 0) {
//                    Text(title)
//                        .font(.custom("Futura", size: 18))
//                        .foregroundColor(.white)
//                        .multilineTextAlignment(.leading)
//                        .padding(10)
//                },
//                alignment: .bottom
//                
//            )
//    }
//    
//}
//
//
//
