//
//  DetailPill.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-05.
//
import SwiftUI

struct DetailPill: View {
  let text: String
  let color: Color
  var body: some View {
    Text(text)
      .font(.system(size: 10, weight: .medium))
      .foregroundStyle(.white.opacity(0.9))
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(color)
      .clipShape(Capsule())
  }
}
