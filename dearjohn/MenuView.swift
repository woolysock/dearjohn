//
//  MenuView.swift
//  dearjohn
//
//  Created by Megan Donahue on 4/28/25.
//  Copyright © 2025 meg&d design.
//

import SwiftUI

struct MenuView: View {
    
    @State private var stackHeight: CGFloat = 0
    @State private var imageHeight: CGFloat = 0
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

                    // Title + About
                    VStack(spacing: 0) {
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

                    // Poem Buttons
                    VStack {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 1), spacing: 10) {
                            NavigationLink(destination: Poem_1_Why_View()) {
                                poemButton(title: "why", b_size: 100, isViewed: viewedPoems.contains("why"))
                            }
                            NavigationLink(destination: Poem_2_What_View()) {
                                poemButton(title: "what", b_size: 100, isViewed: viewedPoems.contains("what"))
                            }
                            NavigationLink(destination: Poem_3_Who_Redo_View()) {
                                poemButton(title: "who", b_size: 100, isViewed: viewedPoems.contains("who"))
                            }
//                            NavigationLink(destination: Poem_4_How_View()) {
//                                poemButton(title: "how", b_size: 100, isViewed: viewedPoems.contains("how"))
//                            }
                        }
                        .position(
                            x: 70,
                            y: geo.size.height - 50 - (400 + (10 * 3)) / 2
                        )
                    }
                }
                .navigationBarHidden(true)
                .onAppear {
                    loadViewedPoems()
                }
            }
        }
    }

    // Load poem view state from UserDefaults
    private func loadViewedPoems() {
        let stored = UserDefaults.standard.stringArray(forKey: "viewedPoems") ?? []
        viewedPoems = Set(stored)
    }

    // Poem button view with color state
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
