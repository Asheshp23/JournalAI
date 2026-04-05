//
//  ShelfMonthSection.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-05.
//
import SwiftUI

@available(iOS 26.0, *)
struct ShelfMonthSection: View {
  let monthLabel: String
  let entries: [FormattedJournalEntry]
  let onSelect: (FormattedJournalEntry) -> Void
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(monthLabel.uppercased())
        .font(.system(size: 10, weight: .bold))
        .kerning(1.5)
        .foregroundStyle(EtherealTheme.tertiaryText)
        .padding(.horizontal, 24)
        .padding(.bottom, 10)
      
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .bottom, spacing: 5) {
          ForEach(entries) { entry in
            BookSpineView(entry: entry, onTap: {
              UIImpactFeedbackGenerator(style: .light).impactOccurred()
              onSelect(entry)
            })
          }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
      }
      
      ShelfPlank()
        .padding(.horizontal, 16)
    }
  }
}
