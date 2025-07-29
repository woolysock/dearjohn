//
//  AboutArtist.swift
//  dearjohn
//
//  Created by Megan Donahue on 5/10/25.
//  Copyright © 2025 meg&d design. All rights reserved.
//

import SwiftUI

struct AboutArtist: View {
    @State private var showLink = false
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea() // Full black background
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading) {
                    Spacer().frame(height: 120)
                    
                    if showLink {
                        // HEADER with two styles inline
                        HStack(spacing: 0) {
                            Text("dearjohn")
                                .font(.custom("Futura", size: 30))
                                .foregroundColor(.gray)
                            
                            Text("  is an app.")
                                .font(.custom("Futura", size: 14))
                                .foregroundColor(.white)
                                .baselineOffset(-10)
                        }
                    }
                    
                    Text("""
But really, it’s a digital book of original poems. 

It’s a book of digital poems that I co-authored, designed, and coded with my new friend, MARK.*

 
""")
                    .font(.custom("Futura", size: 14))
                    .foregroundColor(.white)
                    
                    
                    // MAIN BODY TEXT
                    
                    Text("idea coding")
                        .font(.custom("Futura", size: 20))
                        .foregroundColor(.gray)
                    
                    Text("""
                    
                    The poems are original; born of a collaborative dance where MARK & I tag-teamed (usually nicely, unless MARK would rewrite a poem without my approval, which happened on too many occasions).
                    
                    Together, we (mostly MARK) wrote the code that draws the poems on screen as our (mostly MY) mind imagined.

                    And while AI helped a lot, it would be false to assume my human flesh did no work. I wrote every prompt, performed every copy/paste, compile, oversaw debugging, testing, Art Direction, graphic design, storytelling, and more. MARK did the heavy coding, writing and re-writing Swift UI at my behest; tuning an animation or adding a new section to a poem without grumble or complaint. But MARK did not have a vision.
                    
                    """)
                    .font(.custom("Futura", size: 14))
                    .foregroundColor(.white)
                    
                    Text("\n*I call my AI instance by the name of MARK because, while writing code for the second poem, I noticed all comments it added suddenly started to include the name:")
                        .font(.custom("Futura", size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.leading, 60)
                .padding(.trailing, 20)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.0)) {
                        showLink = true
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("// MARK: - Main View")
                        .font(.custom("Courier New", size: 30))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .frame(height: 50) // Constrain height to ensure single line
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.leading, 60)
                .padding(.trailing, -40)
                
                VStack(alignment: .leading) {
//                    Text("more")
//                        .font(.custom("Futura", size: 20))
//                        .foregroundColor(.gray)
//                    
                    Text("""

Read more about why (and how) I made this digital poetry app on my website:
""")
                    .font(.custom("Futura", size: 14))
                    .foregroundColor(.white)
                    
                    Button(action: {
                        if let url = URL(string: "http://meganddesign.com/dearjohn") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("http://meganddesign.com/dearjohn")
                            .font(.custom("Futura", size: 16))
                            .foregroundColor(.gray)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                            .padding(.top, 20)
                    }
                    Spacer(minLength: 50)
                }
                .padding(.leading, 60)
                .padding(.trailing, 20)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("the artist 👋")
                        .font(.custom("Futura", size: 40))
                        .foregroundColor(.gray)
                    
                    Text("My name is Megan.")
                        .font(.custom("Futura", size: 18))
                        .foregroundColor(.white)
                    
                    //                    Text("      Galbraith Donahue.")
                    //                        .font(.custom("Futura", size: 18))
                    //                        .foregroundColor(.gray)
                    
                    // Static right-aligned block
                    VStack(alignment: .trailing, spacing: 8) {
                        Spacer().frame(height: 30)
                        Text("I built this in Seattle. ☁️")
                            .font(.custom("Futura", size: 18))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 50)
                    
                    Spacer().frame(height: 15)
                    
                    Text("I am a business owner, an artist, a product manager, a designer, and a technologist. I don't always code in the traditional sense but I do make ideas come to life -- with whatever tools I have at my disposal.")
                        .font(.custom("Futura", size: 12))
                        .foregroundColor(.white)
                    
                }
                .padding(.leading, 60)
                .padding(.trailing, 20)
                
                Spacer(minLength: 100) // breathing room at the end
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
