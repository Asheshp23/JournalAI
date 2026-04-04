//
//  DiaryCover.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-03.
//
import SwiftUI

struct DiaryCover: View {
    let openProgress: Double
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Main Cover Material
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.18, green: 0.22, blue: 0.25), // Deep Charcoal/Navy
                            Color(red: 0.12, green: 0.14, blue: 0.17)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // Subtle Linen Texture
                    Image(systemName: "square.fill")
                        .resizable()
                        .opacity(0.03)
                        .blendMode(.overlay)
                )
            
            // Gold Foil Branding
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(EtherealTheme.accent.opacity(0.8))
                
                Text("My Journal")
                    .font(.custom("Snell Roundhand", size: 48))
                    .foregroundStyle(.white.opacity(0.9))
                
                Text("EST. 2025")
                    .font(.system(size: 10, weight: .black))
                    .kerning(4)
                    .foregroundStyle(.white.opacity(0.4))
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            // The Spine Shadow (makes it look 3D)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.black.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 25)
        }
        .shadow(color: .black.opacity(0.3), radius: 20, x: 10, y: 10)
        // The 3D Open Animation
        .rotation3DEffect(
            .degrees(-110 * openProgress),
            axis: (x: 0, y: 1, z: 0),
            anchor: .leading,
            perspective: 0.6
        )
        // Fade out as it opens so we don't see the back of the cover
        .opacity(1.0 - (openProgress * 1.1))
    }
}
