//
//  PrismLensButton.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-05.
//
import SwiftUI

@available(iOS 26.0, *)
struct PrismLensButton: View {
  let lens: EntryDetailSheet.PrismLens
  let isActive: Bool
  let action: () -> Void
  private let purple = Color(red: 0.52, green: 0.35, blue: 0.72)
  
  var body: some View {
    Button(action: action) {
      HStack(spacing: 10) {
        Text(lens.icon).font(.body)
        VStack(alignment: .leading, spacing: 2) {
          Text(lens.rawValue)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(isActive ? purple : EtherealTheme.textMain)
          Text(lens.description)
            .font(.caption2)
            .foregroundStyle(EtherealTheme.tertiaryText)
            .lineLimit(1)
        }
        Spacer()
        if isActive {
          Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(purple)
            .font(.caption)
        }
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 10)
      .background(isActive ? purple.opacity(0.10) : EtherealTheme.surface)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(isActive ? purple.opacity(0.3) : EtherealTheme.divider, lineWidth: 0.5)
      )
    }
    .buttonStyle(.plain)
  }
}
