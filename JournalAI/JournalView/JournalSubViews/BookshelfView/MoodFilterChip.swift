//
//  MoodFilterChip.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-05.
//
import SwiftUI

struct MoodFilterChip: View {
  let filter: MoodFilter
  let isSelected: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      Text(filter.rawValue)
        .font(.caption.weight(isSelected ? .semibold : .regular))
        .foregroundStyle(isSelected ? filter.color : EtherealTheme.tertiaryText)
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(isSelected ? filter.color.opacity(0.12) : EtherealTheme.surface)
        .clipShape(Capsule())
        .overlay(
          Capsule().stroke(
            isSelected ? filter.color.opacity(0.4) : EtherealTheme.divider,
            lineWidth: 0.5
          )
        )
    }
    .buttonStyle(.plain)
  }
}
