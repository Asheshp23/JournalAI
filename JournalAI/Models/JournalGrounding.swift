//
//  JournalGrounding.swift
//  JournalAI
//
//  Created by Codex on 2026-04-03.
//
import Foundation

@available(iOS 26.0, *)
enum JournalGrounding {
  static func groundedGratitudeDetails(
    gratitude: GratitudeItems?,
    originalText: String
  ) -> [String] {
    guard let gratitude else { return [] }
    
    return [
      gratitude.needsMet,
      gratitude.momentsShared,
      gratitude.quietBlessings
    ]
    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    .filter { isGroundedInOriginalEntry($0, originalText: originalText) }
  }
  
  static func isGroundedInOriginalEntry(_ candidate: String, originalText: String) -> Bool {
    guard candidate.isMeaningful else { return false }
    
    let normalizedCandidate = candidate.normalizedSearchText
    let normalizedOriginal = originalText.normalizedSearchText
    
    if normalizedOriginal.contains(normalizedCandidate), normalizedCandidate.count >= 12 {
      return true
    }
    
    let overlap = candidate.groundingTokens.intersection(originalText.groundingTokens)
    return overlap.count >= 2
  }
}
