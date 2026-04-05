//
//  BookSpineView.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-05.
//
import SwiftUI

@available(iOS 26.0, *)
struct BookSpineView: View {
  let entry: FormattedJournalEntry
  let onTap: () -> Void
  @State private var isPressed = false
  
  private var bookHeight: CGFloat {
    let words = entry.originalText.split(separator: " ").count
    return CGFloat(min(max(70, words * 2), 148))
  }
  
  private var bookWidth: CGFloat {
    entry.isProcessed ? 46 : 36
  }
  
  private var spineColors: (Color, Color) {
    BookColorPalette.colors(for: entry)
  }
  
  var body: some View {
    // Use Button so tap is always reliably captured
    Button(action: onTap) {
      ZStack(alignment: .bottom) {
        // Book body
        RoundedRectangle(cornerRadius: 3, style: .continuous)
          .fill(
            LinearGradient(
              colors: [spineColors.0, spineColors.1],
              startPoint: .top,
              endPoint: .bottom
            )
          )
          .frame(width: bookWidth, height: bookHeight)
          .overlay(alignment: .leading) {
            Rectangle()
              .fill(Color.black.opacity(0.18))
              .frame(width: 3)
              .clipShape(RoundedRectangle(cornerRadius: 2))
          }
          .overlay(alignment: .trailing) {
            Rectangle()
              .fill(
                LinearGradient(
                  colors: [
                    Color(red: 0.97, green: 0.94, blue: 0.87).opacity(0.6),
                    Color(red: 0.90, green: 0.87, blue: 0.79).opacity(0.4)
                  ],
                  startPoint: .top,
                  endPoint: .bottom
                )
              )
              .frame(width: 4)
          }
        
        // Rotated title
        Text(entry.heroTitle)
          .font(.system(size: 8, weight: .medium))
          .foregroundStyle(.white.opacity(0.8))
          .lineLimit(1)
          .rotationEffect(.degrees(-90))
          .frame(width: bookHeight - 20)
          .offset(y: -(bookHeight / 2) + 12)
        
        // Favourite dot
        if entry.isFavorite {
          Circle()
            .fill(Color(red: 0.95, green: 0.80, blue: 0.35))
            .frame(width: 5, height: 5)
            .offset(y: -6)
        }
      }
      .frame(width: bookWidth, height: bookHeight)
    }
    .buttonStyle(BookButtonStyle())
  }
}
