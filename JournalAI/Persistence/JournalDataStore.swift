//
//  JournalDataStore.swift
//  JournalAI
//
//  Created by Codex on 2026-04-03.
//
import Foundation

@available(iOS 26.0, *)
@MainActor
final class JournalDataStore {
  static let shared = JournalDataStore()
  
  private struct PersistedStore: Codable {
    var entries: [FormattedJournalEntry] = []
    var drafts: [String: String] = [:]
  }
  
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private let storeURL: URL
  
  private init() {
    let supportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
      ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let directoryURL = supportURL.appendingPathComponent("JournalAI", isDirectory: true)
    try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    storeURL = directoryURL.appendingPathComponent("journal-store.json")
  }
  
  func loadEntries() -> [FormattedJournalEntry] {
    loadStore().entries.sorted { $0.timestamp > $1.timestamp }
  }
  
  func replaceEntries(_ entries: [FormattedJournalEntry]) {
    var store = loadStore()
    store.entries = entries
    saveStore(store)
  }
  
  func latestEntry() -> FormattedJournalEntry? {
    loadEntries().first
  }
  
  func saveDraft(_ draft: String?, for key: String) {
    var store = loadStore()
    let trimmed = draft?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    
    if trimmed.isEmpty {
      store.drafts.removeValue(forKey: key)
    } else {
      store.drafts[key] = draft
    }
    
    saveStore(store)
  }
  
  func loadDraft(for key: String) -> String? {
    loadStore().drafts[key]
  }
  
  func takeDraft(for key: String) -> String? {
    var store = loadStore()
    let draft = store.drafts.removeValue(forKey: key)
    saveStore(store)
    return draft
  }
  
  func deleteDraft(for key: String) {
    var store = loadStore()
    store.drafts.removeValue(forKey: key)
    saveStore(store)
  }
  
  private func loadStore() -> PersistedStore {
    guard let data = try? Data(contentsOf: storeURL) else { return PersistedStore() }
    return (try? decoder.decode(PersistedStore.self, from: data)) ?? PersistedStore()
  }
  
  private func saveStore(_ store: PersistedStore) {
    do {
      let data = try encoder.encode(store)
      try data.write(to: storeURL, options: .atomic)
    } catch {
      print("Failed to save journal store: \(error)")
    }
  }
}
