//
//  BookButtonStyle.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-05.
//
import SwiftUI

struct BookButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
      .offset(y: configuration.isPressed ? 3 : 0)
      .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
  }
}
