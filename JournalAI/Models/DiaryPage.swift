//
//  DiaryPage.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-04.
//
import Foundation

@available(iOS 26.0, *)
enum DiaryPage: Identifiable {
  case draft
  case entry(FormattedJournalEntry)
  
  var id: String {
    switch self {
    case .draft: return "draft"
    case .entry(let entry): return entry.id.uuidString
    }
  }
  
  var headerTitle: String {
    switch self {
    case .draft: return "A fresh page"
    case .entry(let entry): return entry.displayDate
    }
  }
  
  func headerSubtitle(for vm: JournalVM) -> String {
    switch self {
    case .draft: return vm.adaptiveNudge
    case .entry(let entry): return entry.supportingInsight
    }
  }
}
