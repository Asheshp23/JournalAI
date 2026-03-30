//
//  String+Extensions.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2025-06-16.
//
import Foundation

extension String {
  nonisolated var isMeaningful: Bool {
    let cleaned = self.trimmingCharacters(in: .whitespacesAndNewlines)
    return cleaned.count > 5 && cleaned.range(of: "[A-Za-z]", options: .regularExpression) != nil
  }
  
  nonisolated func preview(limit: Int) -> String {
    let cleaned = trimmingCharacters(in: .whitespacesAndNewlines)
    guard cleaned.count > limit else { return cleaned }
    return "\(cleaned.prefix(limit)).…"
  }
}
