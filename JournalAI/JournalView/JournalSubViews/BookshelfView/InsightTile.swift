//
//  InsightTile.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-05.
//
import SwiftUI

struct InsightTile: View {
  let icon: String
  let label: String
  let content: String
  let accentColor: Color
  
  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Label(label.uppercased(), systemImage: icon)
        .font(.system(size: 10, weight: .bold))
        .kerning(0.8)
        .foregroundStyle(accentColor)
      Text(content)
        .font(.system(.subheadline, design: .serif))
        .foregroundStyle(EtherealTheme.textSecondary)
        .lineSpacing(3)
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(EtherealTheme.surface)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay(RoundedRectangle(cornerRadius: 12).stroke(EtherealTheme.divider, lineWidth: 0.5))
  }
}
