//
//  MagicButton.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-04.
//
import SwiftUI

struct MagicButton: View {
  let icon: String
  let label: String
  let color: Color
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        Image(systemName: icon)
          .font(.system(size: 18, weight: .medium))
        Text(label)
          .font(.system(size: 10, weight: .bold))
      }
      .foregroundStyle(color)
      .frame(width: 65)
    }
  }
}
