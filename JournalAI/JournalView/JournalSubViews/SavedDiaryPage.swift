//
//  SavedDiaryPage.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-04.
//
import SwiftUI

@available(iOS 26.0, *)
struct SavedDiaryPage: View {
  let entry: FormattedJournalEntry
  
  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      // Content
      Text(entry.originalText)
        .font(.custom("Noteworthy", size: 20))
        .lineSpacing(12)
        .foregroundStyle(EtherealTheme.textMain)
      
      // AI Insights "Sticky Notes"
      if let impact = entry.emotionalImpact {
        VStack(alignment: .leading, spacing: 8) {
          Label("THE ESSENCE", systemImage: "sparkles")
            .font(.system(size: 10, weight: .black))
            .foregroundStyle(EtherealTheme.secondary)
          
          Text(impact)
            .font(.system(.subheadline, design: .serif))
            .italic()
            .padding(.leading, 12)
            .overlay(alignment: .leading) {
              Rectangle().fill(EtherealTheme.secondary.opacity(0.3)).frame(width: 2)
            }
        }
        .padding(.vertical, 10)
      }
      
      if let imageData = entry.imageData, let uiImage = UIImage(data: imageData) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFit()
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .shadow(radius: 5)
      }
    }
    .padding(.bottom, 100) // Space for the toolbar
  }
}
