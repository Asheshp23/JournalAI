//
//  ProcessingIndicator.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2025-06-16.
//
import SwiftUI

struct ProcessingIndicator: View {
  @State private var scales = [1.0, 1.0, 1.0]
  @State private var opacities = [1.0, 1.0, 1.0]
  
  private let rainbowGradient = LinearGradient(
    colors: [.red, .orange, .yellow, .green, .blue, .indigo, .purple],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )
  
  var body: some View {
    HStack(spacing: 6) {
      ForEach(0..<3) { index in
        Circle()
          .fill(rainbowGradient)
          .frame(width: 8, height: 8)
          .scaleEffect(scales[index])
          .opacity(opacities[index])
          .shadow(color: rainbowColor(at: index).opacity(0.7), radius: 10, x: 0, y: 0)
          .animation(
            .easeInOut(duration: 0.6)
            .repeatForever(autoreverses: true)
            .delay(Double(index) * 0.2),
            value: scales[index]
          )
      }
    }
    .onAppear {
      for i in 0..<3 {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
          withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            scales[i] = 0.5
            opacities[i] = 0.6
          }
        }
      }
    }
  }
  
  private func rainbowColor(at index: Int) -> Color {
    let colors: [Color] = [.red, .orange, .yellow]
    return colors[index % colors.count]
  }
}
