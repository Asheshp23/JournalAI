//
//  JournalViewModel.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2025-06-06.
//
import AppIntents
import Combine
import Foundation
import FoundationModels
import ImagePlayground
import SwiftUI
import UIKit

@available(iOS 26.0, *)
enum AppTab: String, CaseIterable, Hashable {
  case reflect
  case timeline
  case insights
  
  var title: String {
    switch self {
    case .reflect:
      return "Reflect"
    case .timeline:
      return "Timeline"
    case .insights:
      return "Insights"
    }
  }
  
  var systemImage: String {
    switch self {
    case .reflect:
      return "square.and.pencil"
    case .timeline:
      return "clock.arrow.circlepath"
    case .insights:
      return "sparkles.rectangle.stack"
    }
  }
}

@available(iOS 26.0, *)
struct JournalInsightMetrics {
  let totalEntries: Int
  let reflectedEntries: Int
  let weeklyEntries: Int
  let streakDays: Int
  let favoriteAffirmations: Int
}

@available(iOS 26.0, *)
enum JournalRepository {
  nonisolated(unsafe) private static let entriesKey = "journal.entries"
  nonisolated(unsafe) private static let pendingDraftKey = "journal.pendingDraft"
  nonisolated(unsafe) private static let pendingTabKey = "journal.pendingTab"
  
  nonisolated(unsafe) private static let encoder = JSONEncoder()
  nonisolated(unsafe) private static let decoder = JSONDecoder()
  
  nonisolated static func loadEntries() -> [FormattedJournalEntry] {
    guard let data = UserDefaults.standard.data(forKey: entriesKey) else {
      return []
    }
    
    return (try? decoder.decode([FormattedJournalEntry].self, from: data)) ?? []
  }
  
  nonisolated static func saveEntries(_ entries: [FormattedJournalEntry]) {
    guard let data = try? encoder.encode(entries) else { return }
    UserDefaults.standard.set(data, forKey: entriesKey)
  }
  
  @discardableResult
  nonisolated static func captureQuickEntry(text: String, source: String) -> FormattedJournalEntry {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    let entry = FormattedJournalEntry(originalText: trimmed, captureSource: source)
    var entries = loadEntries()
    entries.insert(entry, at: 0)
    saveEntries(entries)
    return entry
  }
  
  nonisolated static func latestEntry() -> FormattedJournalEntry? {
    loadEntries().sorted { $0.timestamp > $1.timestamp }.first
  }
  
  nonisolated static func savePendingDraft(_ draft: String?) {
    let trimmed = draft?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    if trimmed.isEmpty {
      UserDefaults.standard.removeObject(forKey: pendingDraftKey)
    } else {
      UserDefaults.standard.set(trimmed, forKey: pendingDraftKey)
    }
  }
  
  nonisolated static func takePendingDraft() -> String? {
    let draft = UserDefaults.standard.string(forKey: pendingDraftKey)
    UserDefaults.standard.removeObject(forKey: pendingDraftKey)
    return draft
  }
  
  nonisolated static func savePendingTab(_ tab: AppTab?) {
    if let tab {
      UserDefaults.standard.set(tab.rawValue, forKey: pendingTabKey)
    } else {
      UserDefaults.standard.removeObject(forKey: pendingTabKey)
    }
  }
  
  nonisolated static func takePendingTab() -> AppTab? {
    let rawValue = UserDefaults.standard.string(forKey: pendingTabKey)
    UserDefaults.standard.removeObject(forKey: pendingTabKey)
    guard let rawValue else { return nil }
    return AppTab(rawValue: rawValue)
  }
}

@available(iOS 26.0, *)
enum JournalPromptProvider {
  static let prompts = [
    "What drained me today, and what quietly restored me?",
    "Where did I feel most like myself today?",
    "What am I carrying into tomorrow that I can soften tonight?",
    "Which conversation stayed with me, and why?",
    "What small win deserves more credit than I gave it?"
  ]
}

@available(iOS 26.0, *)
@MainActor
final class JournalVM: ObservableObject {
  @Published var journalEntries: [FormattedJournalEntry]
  @Published var currentEntryText = ""
  @Published var isProcessing = false
  @Published var streamingEntry: FormattedJournalEntry?
  @Published var selectedTab: AppTab = .reflect
  @Published var statusMessage: String?
  @Published var selectedPrompt: String?
  
  private let modelSession = LanguageModelSession()
  
  init() {
    journalEntries = JournalRepository.loadEntries().sorted { $0.timestamp > $1.timestamp }
    consumePendingIntentState()
  }
  
  var suggestedPrompts: [String] {
    JournalPromptProvider.prompts
  }
  
  var latestEntry: FormattedJournalEntry? {
    streamingEntry ?? journalEntries.first
  }
  
  var latestAffirmation: String? {
    journalEntries.first { !($0.affirmation ?? "").isEmpty }?.affirmation
  }
  
  var metrics: JournalInsightMetrics {
    let calendar = Calendar.current
    let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date())
    let reflectedEntries = journalEntries.filter { $0.isProcessed }.count
    let weeklyEntries = journalEntries.filter { entry in
      guard let weekInterval else { return false }
      return weekInterval.contains(entry.timestamp)
    }.count
    
    let entryDays = Set(journalEntries.map { calendar.startOfDay(for: $0.timestamp) })
    var streakDays = 0
    var dayCursor = calendar.startOfDay(for: Date())
    
    while entryDays.contains(dayCursor) {
      streakDays += 1
      guard let previousDay = calendar.date(byAdding: .day, value: -1, to: dayCursor) else {
        break
      }
      dayCursor = previousDay
    }
    
    return JournalInsightMetrics(
      totalEntries: journalEntries.count,
      reflectedEntries: reflectedEntries,
      weeklyEntries: weeklyEntries,
      streakDays: streakDays,
      favoriteAffirmations: journalEntries.filter { $0.isFavorite }.count
    )
  }
  
  var reflectionCompletionRatio: Double {
    guard metrics.totalEntries > 0 else { return 0 }
    return Double(metrics.reflectedEntries) / Double(metrics.totalEntries)
  }
  
  func consumePendingIntentState() {
    if let pendingTab = JournalRepository.takePendingTab() {
      selectedTab = pendingTab
    }
    
    if let pendingDraft = JournalRepository.takePendingDraft() {
      currentEntryText = pendingDraft
      selectedTab = .reflect
      statusMessage = "Siri opened a fresh reflection for you."
    }
  }
  
  func dismissStatus() {
    statusMessage = nil
  }
  
  func applyPrompt(_ prompt: String) {
    selectedPrompt = prompt
    currentEntryText = prompt
    selectedTab = .reflect
  }
  
  func saveQuickCapture() {
    let trimmed = currentEntryText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }
    
    journalEntries.insert(
      FormattedJournalEntry(originalText: trimmed, captureSource: "manual-quick-capture"),
      at: 0
    )
    persistEntries()
    currentEntryText = ""
    statusMessage = "Quick capture saved. You can reflect on it later."
    selectedTab = .timeline
  }
  
  func analyzeAndSaveEntry() async {
    let trimmed = currentEntryText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.isMeaningful else { return }
    
    isProcessing = true
    streamingEntry = nil
    defer {
      isProcessing = false
      streamingEntry = nil
    }
    
    do {
      let formattedEntry = try await processEntry(trimmed)
      journalEntries.insert(formattedEntry, at: 0)
      persistEntries()
      currentEntryText = ""
      statusMessage = "Reflection ready. Your new insight has been saved."
      selectedTab = .insights
    } catch {
      statusMessage = "Reflection failed. Your draft is still here."
      print("Failed to process entry: \(error)")
    }
  }
  
  func generateImage() async {
    let trimmed = currentEntryText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.isMeaningful else { return }
    
    isProcessing = true
    streamingEntry = nil
    defer {
      isProcessing = false
      streamingEntry = nil
    }
    
    do {
      let formattedEntry = try await processEntry(trimmed)
      let imageCreator = try await ImageCreator()
      let images = imageCreator.images(
        for: [.text(buildImagePrompt(from: formattedEntry))],
        style: .animation,
        limit: 1
      )
      
      var savedEntry = formattedEntry
      for try await image in images {
        savedEntry.imageData = UIImage(cgImage: image.cgImage).jpegData(compressionQuality: 0.95)
        break
      }
      
      journalEntries.insert(savedEntry, at: 0)
      persistEntries()
      currentEntryText = ""
      statusMessage = "Reflection image saved to your timeline."
      selectedTab = .timeline
    } catch {
      statusMessage = "Image generation was unavailable just now."
      print("Failed to generate image: \(error)")
    }
  }
  
  func toggleFavorite(entryID: UUID) {
    guard let index = journalEntries.firstIndex(where: { $0.id == entryID }) else { return }
    journalEntries[index].isFavorite.toggle()
    persistEntries()
  }
  
  func deleteEntries(at offsets: IndexSet) {
    journalEntries.remove(atOffsets: offsets)
    persistEntries()
  }
  
  private func persistEntries() {
    journalEntries.sort { $0.timestamp > $1.timestamp }
    JournalRepository.saveEntries(journalEntries)
  }
  
  private func processEntry(_ text: String) async throws -> FormattedJournalEntry {
    let prompt = buildStructuredPrompt(from: text)
    var lastEntry = FormattedJournalEntry(originalText: text, captureSource: "ai-reflection")
    
    let stream = modelSession.streamResponse(
      to: prompt,
      generating: JournalReflection.self,
      options: GenerationOptions(temperature: 0.8)
    )
    
    for try await item in stream {
      let partialEntry = mapToFormattedEntry(
        originalText: text,
        reflection: item.content
      )
      streamingEntry = partialEntry
      lastEntry = partialEntry
    }
    
    lastEntry.isProcessed = true
    return lastEntry
  }
  
  private func mapToFormattedEntry(
    originalText: String,
    reflection: JournalReflection.PartiallyGenerated
  ) -> FormattedJournalEntry {
    var entry = FormattedJournalEntry(
      originalText: originalText,
      captureSource: "ai-reflection"
    )
    
    entry.wordOfTheDay = sanitized(reflection.wordOfTheDay)
    entry.valueOfTheDay = sanitized(reflection.valueOfTheDay)
    entry.poeticReflection = sanitized(reflection.poeticReflection)
    entry.emotionalImpact = sanitized(reflection.emotionalImpact)
    entry.affirmation = sanitized(reflection.affirmation)
    entry.tomorrowIntention = sanitized(reflection.tomorrowIntention)
    
    if let partialGratitude = reflection.gratitude {
      let needsMet = partialGratitude.needsMet ?? ""
      let momentsShared = partialGratitude.momentsShared ?? ""
      let quietBlessings = partialGratitude.quietBlessings ?? ""
      
      if !needsMet.isEmpty || !momentsShared.isEmpty || !quietBlessings.isEmpty {
        entry.gratitude = GratitudeItems(
          needsMet: needsMet,
          momentsShared: momentsShared,
          quietBlessings: quietBlessings
        )
      }
    }
    
    if let partialContrib = reflection.contributions {
      let creativeWork = sanitized(partialContrib.creativeWork)
      let service = sanitized(partialContrib.service)
      let presenceOffered = sanitized(partialContrib.presenceOffered)
      
      if creativeWork != nil || service != nil || presenceOffered != nil {
        entry.contributions = ContributionItems(
          creativeWork: creativeWork,
          service: service,
          presenceOffered: presenceOffered
        )
      }
    }
    
    entry.mindfulnessPractice = sanitized(reflection.mindfulnessPractice)
    entry.spiritualConnection = sanitized(reflection.spiritualConnection)
    entry.natureConnection = sanitized(reflection.natureConnection)
    entry.isProcessed = true
    return entry
  }
  
  private func sanitized(_ value: String?) -> String? {
    guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
      return nil
    }
    
    if trimmed.caseInsensitiveCompare("Not present today") == .orderedSame {
      return nil
    }
    
    return trimmed
  }
  
  private func buildStructuredPrompt(from text: String) -> String {
    """
    Act as a warm, insightful journaling guide.
    Transform the user's note into a grounded reflection.
    
    User note:
    \(text)
    
    Produce:
    - a word of the day
    - a value of the day
    - gratitude with needs met, moments shared, and quiet blessings
    - contributions with creative work, service, and presence offered
    - a short poetic reflection
    - one emotional impact sentence
    - optional mindfulness, spiritual, and nature connections when genuinely present
    - an affirmation
    - a gentle intention for tomorrow
    
    Guidelines:
    - Stay faithful to the user's tone and lived experience
    - Be specific, emotionally intelligent, and concise
    - If a section is not supported by the note, return "Not present today"
    - Keep all output friendly for display in short SwiftUI cards
    """
  }
  
  private func buildImagePrompt(from entry: FormattedJournalEntry) -> String {
    var elements: [String] = []
    
    if let emotion = entry.emotionalImpact {
      elements.append("mood: \(emotion)")
    }
    
    if let value = entry.valueOfTheDay {
      elements.append("guiding value: \(value)")
    }
    
    if let poetic = entry.poeticReflection {
      elements.append("atmosphere: \(poetic)")
    }
    
    let style = elements.isEmpty ? "abstract mindful composition" : elements.joined(separator: ", ")
    return "A contemplative editorial illustration with soft light, layered textures, and calming symbolism inspired by \(style)"
  }
}

@available(iOS 26.0, *)
struct CaptureJournalEntryIntent: AppIntent {
  static let title: LocalizedStringResource = "Save Quick Journal Entry"
  static let description = IntentDescription("Capture a journal note with Siri without opening the app.")
  
  @Parameter(title: "Entry")
  var entry: String
  
  static var parameterSummary: some ParameterSummary {
    Summary("Save \(\.$entry) to JournalAI")
  }
  
  func perform() async throws -> some IntentResult & ProvidesDialog {
    let trimmed = entry.trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard !trimmed.isEmpty else {
      return .result(dialog: IntentDialog("I need a few words to save to your journal."))
    }
    
    JournalRepository.captureQuickEntry(text: trimmed, source: "siri")
    return .result(dialog: IntentDialog("Saved your journal note in JournalAI."))
  }
}

@available(iOS 26.0, *)
struct StartReflectionIntent: AppIntent {
  static let title: LocalizedStringResource = "Start Reflection"
  static let description = IntentDescription("Open JournalAI with a prompt or draft ready to reflect on.")
  static let openAppWhenRun = true
  
  @Parameter(title: "Reflection Prompt")
  var prompt: String?
  
  static var parameterSummary: some ParameterSummary {
    Summary("Start a reflection with \(\.$prompt)")
  }
  
  func perform() async throws -> some IntentResult & ProvidesDialog {
    JournalRepository.savePendingTab(.reflect)
    JournalRepository.savePendingDraft(prompt)
    return .result(dialog: IntentDialog("Opening JournalAI for your next reflection."))
  }
}

@available(iOS 26.0, *)
struct ReviewLatestInsightIntent: AppIntent {
  static let title: LocalizedStringResource = "Review Latest Insight"
  static let description = IntentDescription("Hear the latest affirmation or insight from your journal.")
  
  func perform() async throws -> some IntentResult & ProvidesDialog {
    guard let latestEntry = JournalRepository.latestEntry() else {
      return .result(dialog: IntentDialog("You do not have any journal entries yet."))
    }
    
    if let affirmation = latestEntry.affirmation, !affirmation.isEmpty {
      return .result(dialog: IntentDialog("Your latest affirmation is: \(affirmation)"))
    }
    
    return .result(dialog: IntentDialog("Your latest journal insight is \(latestEntry.heroTitle)."))
  }
}

@available(iOS 26.0, *)
struct JournalAppShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: CaptureJournalEntryIntent(),
      phrases: [
        "Save a journal entry in \(.applicationName)",
        "Capture a thought with \(.applicationName)"
      ],
      shortTitle: "Quick Capture",
      systemImageName: "waveform.and.mic"
    )
    
    AppShortcut(
      intent: StartReflectionIntent(),
      phrases: [
        "Start reflecting in \(.applicationName)",
        "Open my journal in \(.applicationName)"
      ],
      shortTitle: "Start Reflection",
      systemImageName: "square.and.pencil"
    )
    
    AppShortcut(
      intent: ReviewLatestInsightIntent(),
      phrases: [
        "What is my latest insight in \(.applicationName)",
        "Read my affirmation from \(.applicationName)"
      ],
      shortTitle: "Latest Insight",
      systemImageName: "sparkles"
    )
  }
}
