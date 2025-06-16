//
//  CardBackground.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2025-06-06.
//
import SwiftUI

struct CardBackground: ViewModifier {
  @State private var animate = false
  
  func body(content: Content) -> some View {
    content
      .background(
        ZStack {
          Color.white.opacity(0.04)
            .blur(radius: 10)

          Circle()
            .fill(Color.white.opacity(0.14))
            .frame(width: 120, height: 120)
            .offset(x: 40, y: 30)
            .blur(radius: 32)
            .opacity(0.18)
        }
          .clipShape(RoundedRectangle(cornerRadius: 16))
      )
      .background(.ultraThinMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 16))
  }
}
