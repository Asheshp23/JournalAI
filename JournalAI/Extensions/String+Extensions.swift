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

  nonisolated var normalizedSearchText: String {
    lowercased()
      .replacingOccurrences(of: "[^a-z0-9\\s]", with: " ", options: .regularExpression)
      .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }

  nonisolated var groundingTokens: Set<String> {
    let stopWords: Set<String> = [
      "about", "after", "again", "already", "also", "and", "before", "being", "from",
      "have", "into", "just", "more", "much", "that", "them", "then", "there", "they",
      "this", "today", "very", "want", "with", "would", "your"
    ]

    return Set(
      normalizedSearchText
        .split(separator: " ")
        .map(String.init)
        .filter { $0.count >= 4 && !stopWords.contains($0) }
    )
  }
}
