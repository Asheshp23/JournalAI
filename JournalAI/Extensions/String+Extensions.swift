//
//  String+Extensions.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2025-06-16.
//
import Foundation

extension String {
  var isMeaningful: Bool {
    let cleaned = self.trimmingCharacters(in: .whitespacesAndNewlines)
    return cleaned.count > 5 && cleaned.range(of: "[A-Za-z]", options: .regularExpression) != nil
  }
}
