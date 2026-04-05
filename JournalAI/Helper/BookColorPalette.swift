//
//  BookColorPalette.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-05.
//
import Foundation
import SwiftUI

enum BookColorPalette {
  private static let palettes: [(Color, Color)] = [
    (Color(red: 0.55, green: 0.28, blue: 0.16), Color(red: 0.38, green: 0.18, blue: 0.08)),
    (Color(red: 0.18, green: 0.38, blue: 0.58), Color(red: 0.10, green: 0.26, blue: 0.42)),
    (Color(red: 0.40, green: 0.26, blue: 0.58), Color(red: 0.26, green: 0.16, blue: 0.40)),
    (Color(red: 0.22, green: 0.44, blue: 0.28), Color(red: 0.14, green: 0.30, blue: 0.18)),
    (Color(red: 0.58, green: 0.36, blue: 0.18), Color(red: 0.40, green: 0.24, blue: 0.10)),
    (Color(red: 0.48, green: 0.22, blue: 0.36), Color(red: 0.32, green: 0.12, blue: 0.24)),
    (Color(red: 0.22, green: 0.40, blue: 0.46), Color(red: 0.14, green: 0.26, blue: 0.32)),
    (Color(red: 0.44, green: 0.34, blue: 0.24), Color(red: 0.30, green: 0.22, blue: 0.14)),
  ]
  
  static func colors(for entry: FormattedJournalEntry) -> (Color, Color) {
    let index = abs(entry.id.hashValue) % palettes.count
    return palettes[index]
  }
}
