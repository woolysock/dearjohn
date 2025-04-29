//
//  MenuView.swift
//  why
//
//  Created by Megan Donahue on 4/28/25.
//  Copyright © 2025 meg&d design. All rights reserved.
//
import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    Image("why-loading")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                    // 3x3 Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 30), count: 3), spacing: 30) {
                        NavigationLink(destination: WhyPoemView()) {
                            poemButton(title: "why?")
                        }
                        NavigationLink(destination: EssencePoemView()) {
                            poemButton(title: "what?")
                        }
                        NavigationLink(destination: PoemThreeView()) {
                            poemButton(title: "?")
                        }
                        NavigationLink(destination: PoemFourView()) {
                            poemButton(title: "?")
                        }
                        NavigationLink(destination: PoemFiveView()) {
                            poemButton(title: "?")
                        }
                        NavigationLink(destination: PoemSixView()) {
                            poemButton(title: "?")
                        }
                        NavigationLink(destination: PoemSevenView()) {
                            poemButton(title: "?")
                        }
                        NavigationLink(destination: PoemEightView()) {
                            poemButton(title: "?")
                        }
                        NavigationLink(destination: PoemNineView()) {
                            poemButton(title: "?")
                        }
                    }
                    .padding()

                    Spacer().frame(height: 10)

                    // About the Artist Button
                    NavigationLink(destination: AboutArtist()) {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 200, height: 50)
                            .overlay(
                                Text("about the artist")
                                    .font(.custom("Futura", size: 12))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            )
                    }
                    .padding(.bottom, 20)

                    Text("meg&d design")
                        .font(.custom("Futura", size: 10))
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                    
                }
                .padding()
            }
        }
    }

    // Reusable button style
    func poemButton(title: String) -> some View {
        Rectangle()
            .fill(Color.white)
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                Text(title)
                    .font(.custom("Futura", size: 14))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(5)
            )
    }
}



// Keep repeating for all 9 poem views

struct PoemThreeView: View { var body: some View { ZStack { Color.black.ignoresSafeArea(); Text("Poem Three Content Here").font(.custom("Futura", size: 24)).foregroundColor(.white).padding() } } }

struct PoemFourView: View { var body: some View { ZStack { Color.black.ignoresSafeArea(); Text("Poem Four Content Here").font(.custom("Futura", size: 24)).foregroundColor(.white).padding() } } }

struct PoemFiveView: View { var body: some View { ZStack { Color.black.ignoresSafeArea(); Text("Poem Five Content Here").font(.custom("Futura", size: 24)).foregroundColor(.white).padding() } } }

struct PoemSixView: View { var body: some View { ZStack { Color.black.ignoresSafeArea(); Text("Poem Six Content Here").font(.custom("Futura", size: 24)).foregroundColor(.white).padding() } } }

struct PoemSevenView: View { var body: some View { ZStack { Color.black.ignoresSafeArea(); Text("Poem Seven Content Here").font(.custom("Futura", size: 24)).foregroundColor(.white).padding() } } }

struct PoemEightView: View { var body: some View { ZStack { Color.black.ignoresSafeArea(); Text("Poem Eight Content Here").font(.custom("Futura", size: 24)).foregroundColor(.white).padding() } } }

struct PoemNineView: View { var body: some View { ZStack { Color.black.ignoresSafeArea(); Text("Poem Nine Content Here").font(.custom("Futura", size: 24)).foregroundColor(.white).padding() } } }



struct AboutArtist: View {
    @State private var showLink = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 10) {
                Text("why hello 👋")
                    .font(.custom("Futura", size: 48))
                    .foregroundColor(.white)

                Text("My name is Megan")
                    .font(.custom("Futura", size: 18))
                    .foregroundColor(.white)

                Text("      Galbraith Donahue.")
                    .font(.custom("Futura", size: 18))
                    .foregroundColor(.gray)

                // Static right-aligned block
                VStack(alignment: .trailing, spacing: 8) {
                    Spacer().frame(height: 30)
                    Text("I live in Seattle. ☁️")
                        .font(.custom("Futura", size: 18))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 50)

                Spacer().frame(height: 15)

                Text("I am a product manager, designer and artist. I don't write code in the traditional sense, but I do make ideas come to life with whatever tools I have at my disposal (including code). This is an exploration into modern coding by which I mean building a real experience as a quote non-coder unquote. ChatGPT was my only mentor and teacher through the process, however the ghost of my graduate advisor, John Maeda, haunted me like Obi-wan Kenobi or maybe those angel-devil characters that sat on the shoulders of every protagonist in every eighties cartoon. That said, I also used xCode, BBedit, Adobe Fonts. I tried very hard to make my pal cgpt30 do all the work writing and re-writing and re-writing our code until I was satisfied it was right. \n\n Is AI just a product manager's dream?")
                    .font(.custom("Futura", size: 12))
                    .foregroundColor(.white)

                // Animated Link underneath paragraph
                if showLink {
                    Link("http://meganddesign.com", destination: URL(string: "http://meganddesign.com")!)
                        .font(.custom("Futura", size: 16))
                        .foregroundColor(.gray)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        .padding(.top, 20)
                }
            }
            .padding(.leading, 50)
            .padding(.trailing, 50)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    showLink = true
                }
            }
        }
    }
}



