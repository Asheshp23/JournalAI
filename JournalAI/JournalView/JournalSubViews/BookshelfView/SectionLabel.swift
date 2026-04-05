//
//  SectionLabel.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-05.
//
import SwiftUI

struct SectionLabel: View {
  let text: String
  init(_ text: String) { self.text = text }
  var body: some View {
    Text(text.uppercased())
      .font(.system(size: 10, weight: .bold))
      .kerning(1.2)
      .foregroundStyle(EtherealTheme.tertiaryText)
  }
}
