//
//  ReflectionSection.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2025-06-16.
//
import SwiftUI

struct ReflectionSection: View {
  let icon: String
  let title: String
  let content: String
  
  private let iconGradient = LinearGradient(
    colors: [.red, .orange, .yellow, .green, .blue, .purple],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )
  
  private let titleGradient = LinearGradient(
    colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.8)],
    startPoint: .leading,
    endPoint: .trailing
  )
  
  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack(spacing: 8) {
        Text(icon)
          .font(.title2)
          .foregroundStyle(iconGradient)
          .shadow(color: Color.red.opacity(0.5), radius: 2, x: 0, y: 0)
        Text(title)
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundStyle(titleGradient)
          .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 1)
      }
      Text(content)
        .font(.body)
        .foregroundStyle(.primary)
      Divider()
        .background(Color.white.opacity(0.6))
        .padding(.bottom, 4)
    }
  }
}
