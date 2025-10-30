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
    @State private var titleStackSpacing: CGFloat = 0
    @State private var viewedPoems: Set<String> = []
    //@State private var viewHeight: CGFloat = 0
    @State private var copyrightText: String = "©2025 meg&d design"
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                let desiredBottomY = geo.size.height * 0.4
                let isLandscape = geo.size.width > geo.size.height
                let topInset = geo.safeAreaInsets.top

               // let imageWidth = min(geo.size.width * 0.5, geo.size.height * 0.8)

                ZStack {
                    // Background: Top 40% black, bottom 60% white
                    VStack(spacing: 0) {
                        Color.black
                            .frame(height: desiredBottomY)
                        Color.white
                            .frame(height: geo.size.height + topInset - desiredBottomY)
                    }
                    .ignoresSafeArea()

                    // Title + About
                    //Responsive Layout
                    
                    
                    ZStack {
                        // Images positioned to align first image bottom with horizon
                        VStack(spacing: 0) {
                            Image("title-white")
                                .resizable()
                                .scaledToFit()
                                .frame(width: min(geo.size.width * 0.5, desiredBottomY))
                                .background(
                                    GeometryReader { imgGeo in
                                        Color.clear
                                            .onAppear {
                                                if (imgGeo.size.height > 10) {
                                                    imageHeight = imgGeo.size.height
                                                    titleStackSpacing = imageHeight * 0.3
                                                }
                                            }
                                            .onChange(of: imgGeo.size.height) {
                                                if (imgGeo.size.height > 10) {
                                                    imageHeight = imgGeo.size.height
                                                    titleStackSpacing = imageHeight * 0.3
                                                }
                                            }
                                    }
                                )
                            
                            Image("title-black-flip")
                                .resizable()
                                .scaledToFit()
                                .frame(width: min(geo.size.width * 0.5, desiredBottomY))
                        }
                        .padding(.leading, isLandscape ? 100 : 0)
                        .position(
                            x: isLandscape ? geo.size.width * 2/5 : geo.size.width * 2/3,
                            y: desiredBottomY
                            //y: isLandscape ? desiredBottomY : (desiredBottomY + topInset) - (imageHeight / 2) + 10
                        )
                        .ignoresSafeArea()
                        
                        // Text and about button positioned below the horizon
                        VStack(spacing: 0) {
                            Text("a digital book")
                                .font(.custom("Futura", size: 22))
                                .foregroundColor(.black)
                            Text("of poems")
                                .font(.custom("Futura", size: 22))
                                .foregroundColor(.black)
                            //Text("x: \(geo.size.width) y: \(geo.size.height)")
                            
                            Spacer().frame(height: isLandscape ? titleStackSpacing : titleStackSpacing * 2)
                            
                            NavigationLink(destination: AboutArtist()) {
                                poemButton(title: "about", b_size: geo.size.height * 0.1, isViewed: false)
                            }
                            
                            Spacer().frame(height: 10)
                            
                            Text(copyrightText)
                                .font(.custom("Futura", size: 8))
                                .foregroundColor(.gray)
                            //Spacer()
                        }
                        //.border(Color.black, width: 2)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .position(
                            x: geo.size.width * 2/3,
                            y: desiredBottomY + (isLandscape ? 20 : imageHeight) + ((geo.size.height - desiredBottomY-imageHeight) / 2)
                            
                        )
                    }
                    
                    
                    
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
                            
                        }
                        .position(
                            x: isLandscape ? 150 : 70,
                            y: isLandscape ? geo.size.height / 2 : (((geo.size.height + topInset) / 2 ) + 120)
                        )
                    }
                    .ignoresSafeArea()
                    
                    
                }
                .navigationBarHidden(true)
                .onAppear {
                    if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
                        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                        UserDefaults.standard.removeObject(forKey: "viewedPoems")
                    }
                    loadViewedPoems()
                }
//                .onChange(of: geo.size) {
//                    copyrightText = "\(geo.size.height) - \(topInset) - \(desiredBottomY)"
//                }
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
