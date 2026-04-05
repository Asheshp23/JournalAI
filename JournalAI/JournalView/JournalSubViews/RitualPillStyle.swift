//
//  RitualPillStyle.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-04.
//
import SwiftUI

struct RitualPillStyle: ToggleStyle {
  let icon: String
  func makeBody(configuration: Configuration) -> some View {
    Button { configuration.isOn = true } label: {
      HStack(spacing: 4) {
        Image(systemName: icon)
        configuration.label
      }
      .font(.system(size: 12, weight: .medium))
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(configuration.isOn ? EtherealTheme.secondary : Color.clear)
      .foregroundStyle(configuration.isOn ? .white : EtherealTheme.textSecondary)
      .clipShape(Capsule())
      .overlay(Capsule().stroke(EtherealTheme.divider, lineWidth: configuration.isOn ? 0 : 1))
    }
  }
}
