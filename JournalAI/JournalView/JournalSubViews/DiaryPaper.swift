//
//  DiaryPaper.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-04.
//
import SwiftUI

struct DiaryPaper: View {
  let cornerRadius: CGFloat
  
  var body: some View {
    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
      .fill(EtherealTheme.paper)
      .overlay(alignment: .topLeading) {
        // The Margin Line (Vertical)
        Rectangle()
          .fill(EtherealTheme.destructive.opacity(0.15))
          .frame(width: 1.5)
          .padding(.leading, 32)
      }
      .overlay {
        // The Horizontal Lines
        VStack(spacing: 31.5) { // Adjusted to match Noteworthy font height
          ForEach(0..<22, id: \.self) { _ in
            Rectangle()
              .fill(EtherealTheme.line.opacity(0.4))
              .frame(height: 0.5)
          }
        }
        .padding(.top, 48)
        .allowsHitTesting(false)
      }
      .overlay {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .strokeBorder(EtherealTheme.divider.opacity(0.4))
      }
  }
}
