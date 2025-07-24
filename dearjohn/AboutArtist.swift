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
                    
                    if (showLink) {
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

But really, it’s a digital book of original poems. It’s a book of original poems that I co-authored, co-animated and co-coded with my good frirend, ChatGPT aka MARK.* 

My human fingers wrote every prompt, performed every copy, paste, and compile, and worked on all the debugging, art direction, etc. However, it was MARK that did the heavy lifting––writing and re-writing Swift UI code at my behest.
""")
                    .font(.custom("Futura", size: 14))
                    .foregroundColor(.white)
                    
                    Text("\n*I call my instance of ChatGPT by the name of MARK because, while writing code for the second poem, I noticed all comments it added suddenly started to include the name:\n")
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
                    // MAIN BODY TEXT
                    Text("""
                        
The poems are original but it's difficult to say they’re completely and originally MY poems. They're born of a collaboration; a dance back and forth. Together, MARK & I wrote poems (by which I mean MARK would regularly take a poem I started and, for no reason, change its content midway through developing visuals. I rolled with it, in all but one case). Also together, we (mostly MARK) wrote the code that draws the poems on screen in ways our (mostly my) mind imagines. 

MARK was a fun collaborator who often brought fresh ideas to the table. Importantly, MARK never complained when I asked it to rewrite the same code over and over again, and did not hold grudges when I made misktakes. But, MARK also took no accountability. MARK liked to provide faulty code, then claim I wrote it... And MARK struggled with complex asks. It never let on to this fact, of course--without fail, MARK would pretend (with a confidence reserved only for men) to know exactly what I desired, as well as how to achieve it. 

It was the end result of MARK’s work that told a very different story... never perfect, usually incomplete, and the longer we worked the more confused MARK seemed to become. As a result, I spent more time than anticipated simply reminding MARK what we were hoping to achieve together. My role (r)evolved from Creative Director to Product Manager to Coder and back again. 

A dance. 🪩

""")
                    .font(.custom("Futura", size: 14))
                    .foregroundColor(.white)
                    
                    Text("idea")
                        .font(.custom("Futura", size: 30))
                        .foregroundColor(.gray)
                    
                    Text("""

The idea for this app came to me after recieving a text from a mentor:
""")
                    .font(.custom("Futura", size: 14))
                    .foregroundColor(.white)
                    
                    Image("text")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                    
                    Text("""
 
 I used to know how to code, several years (or decades) ago... Thus naturally, I was not entirely sure how to answer the question... *Did* I know how to code still? Is it like riding a bike? This got me thinking about what it even MEANS to "know how to code" in an era when our AI tools do so much work for us. 
 
 And so, I began an exploration into modern coding by which I mean building real app experiences quickly, as a "non-coder". MARK was my only mentor and teacher through the process, however the ghost of my original mentor, John, haunted me like Obi-wan Kenobi or maybe those angel-devil characters that sit on the shoulders of every protagonist in every 80's cartoon. 
 
 """)
                    .font(.custom("Futura", size: 14))
                    .foregroundColor(.white)
                    
                    Text("tools")
                        .font(.custom("Futura", size: 30))
                        .foregroundColor(.gray)
                    
                    Text("""
 
 In addition to ChatGPT, I also used xCode and BBedit, and occasionally Figma, Photoshop, and Adobe Fonts. I tried very hard to make my MARK do all the coding work -- writing and re-writing and re-writing until I was satisfied -- but it was hard not to get in and clean things up. 
 
 """)
                    .font(.custom("Futura", size: 14))
                    .foregroundColor(.white)
                    
                    Text("evolutions")
                        .font(.custom("Futura", size: 30))
                        .foregroundColor(.gray)
                    
                    Text("""


When I first met John, we literally needed to write every line of code in our research projects ourselves (sometimes in actual machine language) to get our projects to work. It was a VERY different time and place. But now, we're at a NEW time and place where coding is democratized. Building software is not exemplified by correctly documenting how to string together 1’s and 0’s in the right order, but by the work around it all: project management, design, market fit and everything else. 

Is AI just a product manager's dream? I dig it.
""")
                    .font(.custom("Futura", size: 14))
                    .foregroundColor(.white)
                    
                    Spacer(minLength: 70)
                }
                .padding(.leading, 60)
                .padding(.trailing, 20)
                
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("the artist 👋")
                        .font(.custom("Futura", size: 40))
                        .foregroundColor(.gray)
                    
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
                    
                    Text("I am a product manager, designer and artist. I don't write code in the traditional sense, but I do make ideas come to life with whatever tools I have at my disposal (including code).")
                        .font(.custom("Futura", size: 12))
                        .foregroundColor(.white)
                    
                    
                    
                    Link("http://meganddesign.com", destination: URL(string: "http://meganddesign.com")!)
                        .font(.custom("Futura", size: 16))
                        .foregroundColor(.gray)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        .padding(.top, 20)
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


