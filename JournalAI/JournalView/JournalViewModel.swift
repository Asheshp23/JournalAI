//
//  JournalViewModel.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2025-06-06.
//
import AppIntents
import Combine
import Foundation
import ImagePlayground
import SwiftUI
import UIKit
import UserNotifications

@available(iOS 26.0, *)
enum JournalRitualTemplate: String, CaseIterable, Hashable {
  case threeGoodThings
  case morningReset
  case eveningReflection
  case freewrite
  
  /// Returns the most appropriate template based on the current time of day.
  static var recommended: JournalRitualTemplate {
    let hour = Calendar.current.component(.hour, from: Date())
    
    switch hour {
    case 5..<11:   // 5 AM - 10:59 AM
      return .morningReset
    case 11..<17:  // 11 AM - 4:59 PM
      return .threeGoodThings
    case 17..<24, 0..<5: // 5 PM - 4:59 AM
      return .eveningReflection
    default:
      return .freewrite
    }
  }
  
  var title: String {
    switch self {
    case .threeGoodThings: return "3 Good Things"
    case .morningReset: return "Morning Reset"
    case .eveningReflection: return "Evening Reflection"
    case .freewrite: return "Freewrite"
    }
  }
  
  var systemImage: String {
    switch self {
    case .threeGoodThings: return "heart.text.square"
    case .morningReset: return "sunrise.fill"
    case .eveningReflection: return "moon.stars.fill"
    case .freewrite: return "square.and.pencil"
    }
  }
  
  var subtitle: String {
    switch self {
    case .threeGoodThings: return "A proven gratitude ritual that keeps the daily habit simple."
    case .morningReset: return "Start the day by noticing what is already supportive."
    case .eveningReflection: return "Close the day with gratitude, learning, and softness."
    case .freewrite: return "A blank page when you want to think in your own shape."
    }
  }
  
  var starterText: String {
    switch self {
    case .threeGoodThings:
      return """
            Three good things from today:
            1.
            2.
            3.
            
            Why they mattered:
            -
            """
    case .morningReset:
      return """
            Today I want to notice:
            
            Something I am already grateful for:
            
            A kind intention for myself:
            """
    case .eveningReflection:
      return """
            What felt good today?
            
            What challenged me?
            
            What am I grateful for right now?
            
            How do I want to close the day?
            """
    case .freewrite:
      return ""
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
struct StreakDay: Identifiable {
  let id = UUID()
  let label: String
  let isCompleted: Bool
  let isToday: Bool
}

@available(iOS 26.0, *)
struct StoryBeat: Identifiable {
  let id = UUID()
  let title: String
  let body: String
  let systemImage: String
}

@available(iOS 26.0, *)
@MainActor
enum JournalRepository {
  private static let pendingDraftKey = "intent.pendingDraft"
  private static let autosaveDraftKey = "editor.autosaveDraft"
  
  static func loadEntries() -> [FormattedJournalEntry] {
    JournalDataStore.shared.loadEntries()
  }
  
  static func saveEntries(_ entries: [FormattedJournalEntry]) {
    JournalDataStore.shared.replaceEntries(entries)
  }
  
  @discardableResult
  static func captureQuickEntry(text: String, source: String) -> FormattedJournalEntry {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    let entry = FormattedJournalEntry(originalText: trimmed, captureSource: source)
    var entries = loadEntries()
    entries.insert(entry, at: 0)
    saveEntries(entries)
    return entry
  }
  
  static func latestEntry() -> FormattedJournalEntry? {
    JournalDataStore.shared.latestEntry()
  }
  
  static func savePendingDraft(_ draft: String?) {
    JournalDataStore.shared.saveDraft(draft, for: pendingDraftKey)
  }
  
  static func takePendingDraft() -> String? {
    JournalDataStore.shared.takeDraft(for: pendingDraftKey)
  }

  static func saveAutosaveDraft(_ draft: String?) {
    JournalDataStore.shared.saveDraft(draft, for: autosaveDraftKey)
  }

  static func loadAutosaveDraft() -> String? {
    JournalDataStore.shared.loadDraft(for: autosaveDraftKey)
  }

  static func clearAutosaveDraft() {
    JournalDataStore.shared.deleteDraft(for: autosaveDraftKey)
  }
}

@available(iOS 26.0, *)
enum JournalPromptProvider {
  static let prompts = [
    "What moment from today do you want to remember?",
    "Who did you connect with today, and what made it meaningful?",
    "What are you grateful for right now?",
    "What challenged you today, and what did you learn?",
    "What made you smile or feel light today?",
    "What surprised you today?",
    "How did you take care of yourself today?",
    "What small detail from today feels important?",
    "What do you want to do differently tomorrow?",
    "What is one intention you want to carry into tomorrow?"
  ]
}

@available(iOS 26.0, *)
@MainActor
final class JournalVM: ObservableObject {
  @Published var journalEntries: [FormattedJournalEntry]
  @Published var currentEntryText = ""
  @Published var isProcessing = false
  @Published var streamingEntry: FormattedJournalEntry?
  @Published var statusMessage: String?
  @Published var selectedPrompt: String?
  @Published var selectedRitual: JournalRitualTemplate = .threeGoodThings
  @Published var hasAskedForMindfulPrism = false
  
  init() {
    journalEntries = JournalRepository.loadEntries().sorted { $0.timestamp > $1.timestamp }
    consumePendingIntentState()
    restoreAutosavedDraftIfNeeded()
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
  
  var displayedStoryEntry: FormattedJournalEntry? {
    if hasAskedForMindfulPrism {
      return latestEntry
    }
    
    return journalEntries.first
  }
  
  var throwbackEntry: FormattedJournalEntry? {
    let cutoffDate = Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date.distantPast
    return journalEntries.first(where: { $0.timestamp < cutoffDate })
  }
  
  var latestGratitudeItems: [String] {
    guard let gratitude = latestEntry?.gratitude else { return [] }
    
    return [
      gratitude.needsMet,
      gratitude.momentsShared,
      gratitude.quietBlessings
    ]
    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    .filter { !$0.isEmpty }
  }
  
  var onThisDayEntry: FormattedJournalEntry? {
    let calendar = Calendar.current
    let today = Date()
    let currentMonth = calendar.component(.month, from: today)
    let currentDay = calendar.component(.day, from: today)
    
    return journalEntries.first {
      let month = calendar.component(.month, from: $0.timestamp)
      let day = calendar.component(.day, from: $0.timestamp)
      return month == currentMonth && day == currentDay && !calendar.isDate($0.timestamp, inSameDayAs: today)
    }
  }
  
  var streakWeek: [StreakDay] {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEEE"
    
    return (0..<7).compactMap { offset in
      guard let date = calendar.date(byAdding: .day, value: offset - 6, to: today) else { return nil }
      let isCompleted = journalEntries.contains { calendar.isDate($0.timestamp, inSameDayAs: date) }
      return StreakDay(
        label: formatter.string(from: date),
        isCompleted: isCompleted,
        isToday: calendar.isDate(date, inSameDayAs: today)
      )
    }
  }
  
  var storyTitle: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMM d"
    return "Chapter for \(formatter.string(from: Date()))"
  }
  
  var adaptiveNudge: String {
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: Date())
    let weekday = calendar.weekdaySymbols[calendar.component(.weekday, from: Date()) - 1]
    
    switch hour {
    case 5..<12:
      return "Good morning. It’s \(weekday), a gentle time to notice one thing already supporting you."
    case 12..<17:
      return "This \(weekday) afternoon, what small moment has been quietly good so far?"
    case 17..<22:
      return "As \(weekday) slows down, what deserves gratitude before the day closes?"
    default:
      return "It’s late on \(weekday). What can you thank today for before you rest?"
    }
  }
  
  var chapterPrompt: String {
    let calendar = Calendar.current
    let weekday = calendar.weekdaySymbols[calendar.component(.weekday, from: Date()) - 1]
    
    switch selectedRitual {
    case .threeGoodThings:
      return "Tell the story of three bright moments from this \(weekday)."
    case .morningReset:
      return "Open today like a first page. What feeling do you want guiding the chapter?"
    case .eveningReflection:
      return "If today were a scene in your life, what moment would you keep?"
    case .freewrite:
      return "Write this day as it felt, not as it should have been."
    }
  }
  
  var storyBeats: [StoryBeat] {
    guard let entry = displayedStoryEntry else { return [] }
    
    var beats: [StoryBeat] = []
    
    let openingLine = entry.originalText.preview(limit: 120)
    if !openingLine.isEmpty {
      beats.append(
        StoryBeat(
          title: "Opening Scene",
          body: openingLine,
          systemImage: "text.alignleft"
        )
      )
    }
    
    let gratitudeDetails = JournalGrounding.groundedGratitudeDetails(
      gratitude: entry.gratitude,
      originalText: entry.originalText
    )
    if !gratitudeDetails.isEmpty {
      let details = gratitudeDetails.joined(separator: " • ")
      
      if !details.isEmpty {
        beats.append(
          StoryBeat(
            title: "Quiet Gifts",
            body: details,
            systemImage: "gift.fill"
          )
        )
      }
    }
    
    if hasAskedForMindfulPrism, let affirmation = entry.affirmation {
      beats.append(
        StoryBeat(
          title: "Mindful Prism",
          body: affirmation,
          systemImage: "sparkles.rectangle.stack"
        )
      )
    } else if let emotionalImpact = entry.emotionalImpact {
      beats.append(
        StoryBeat(
          title: "What Stayed",
          body: emotionalImpact,
          systemImage: "waveform.path.ecg"
        )
      )
    }
    
    if let tomorrowIntention = entry.tomorrowIntention {
      beats.append(
        StoryBeat(
          title: "Next Page",
          body: tomorrowIntention,
          systemImage: "arrow.right.circle.fill"
        )
      )
    }
    
    return beats
  }
  
  var storyArchive: [FormattedJournalEntry] {
    Array(journalEntries.prefix(8))
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
    if let pendingDraft = JournalRepository.takePendingDraft() {
      currentEntryText = pendingDraft
      statusMessage = "Siri opened a fresh reflection for you."
    }
  }

  func restoreAutosavedDraftIfNeeded() {
    guard currentEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
    guard let autosavedDraft = JournalRepository.loadAutosaveDraft() else { return }
    guard autosavedDraft.trimmingCharacters(in: .whitespacesAndNewlines).isMeaningful else { return }
    currentEntryText = autosavedDraft
    statusMessage = "Your unfinished page is ready to continue."
  }
  
  func dismissStatus() {
    statusMessage = nil
  }
  
  func applyPrompt(_ prompt: String) {
    selectedPrompt = prompt
    currentEntryText = prompt
    hasAskedForMindfulPrism = false
    JournalRepository.saveAutosaveDraft(prompt)
  }
  
  func applyRitual(_ ritual: JournalRitualTemplate) {
    selectedRitual = ritual
    hasAskedForMindfulPrism = false
    
    guard !ritual.starterText.isEmpty else { return }
    currentEntryText = ritual.starterText
    JournalRepository.saveAutosaveDraft(ritual.starterText)
  }

  func handleDraftChange(_ draft: String) {
    JournalRepository.saveAutosaveDraft(draft)
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
    JournalRepository.clearAutosaveDraft()
    statusMessage = "Quick capture saved. You can reflect on it later."
    hasAskedForMindfulPrism = false
  }
  
  func askForMindfulPrism() {
    hasAskedForMindfulPrism = true
  }
  
  func scheduleDailyReminder(hour: Int, title: String, body: String) async {
    let center = UNUserNotificationCenter.current()
    let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    guard granted == true else {
      statusMessage = "Notifications are off. You can enable them in Settings."
      return
    }
    
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    
    var components = DateComponents()
    components.hour = hour
    components.minute = 0
    
    let request = UNNotificationRequest(
      identifier: "journalai.reminder.\(hour)",
      content: content,
      trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    )
    
    center.removePendingNotificationRequests(withIdentifiers: [
      "journalai.reminder.8",
      "journalai.reminder.20"
    ])
    try? await center.add(request)
    statusMessage = "Daily reminder scheduled."
  }
  
  func analyzeAndSaveEntry(showMindfulPrism: Bool = false) async {
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
      JournalRepository.clearAutosaveDraft()
      statusMessage = "Your new chapter has been shaped and saved."
      hasAskedForMindfulPrism = showMindfulPrism
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
      JournalRepository.clearAutosaveDraft()
      statusMessage = "Reflection image saved to your journal history."
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

  func deleteEntry(entryID: UUID) {
    journalEntries.removeAll { $0.id == entryID }
    persistEntries()
  }
  
  private func persistEntries() {
    journalEntries.sort { $0.timestamp > $1.timestamp }
    JournalRepository.saveEntries(journalEntries)
  }
  
  private func processEntry(_ text: String) async throws -> FormattedJournalEntry {
    let reflection = makeReflection(from: text)
    var entry = FormattedJournalEntry(
      originalText: text,
      captureSource: "ai-reflection"
    )
    
    entry.wordOfTheDay = reflection.wordOfTheDay
    entry.valueOfTheDay = reflection.valueOfTheDay
    entry.poeticReflection = reflection.poeticReflection
    entry.emotionalImpact = reflection.emotionalImpact
    entry.affirmation = reflection.affirmation
    entry.tomorrowIntention = reflection.tomorrowIntention
    entry.gratitude = reflection.gratitude
    entry.contributions = reflection.contributions
    entry.mindfulnessPractice = reflection.mindfulnessPractice
    entry.spiritualConnection = reflection.spiritualConnection
    entry.natureConnection = reflection.natureConnection
    entry.isProcessed = true
    streamingEntry = entry
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

  private func makeReflection(from text: String) -> JournalReflection {
    let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
    let sentences = normalizedText
      .split(whereSeparator: \.isNewline)
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
    
    let titleSeed = normalizedText.groundingTokens.first?.capitalized ?? "Today"
    let opening = sentences.first ?? normalizedText.preview(limit: 120)
    let closing = sentences.last ?? "I want to carry this day gently."
    
    let groundedBits = Array(normalizedText.groundingTokens.prefix(3))
    let gratitude = GratitudeItems(
      needsMet: groundedBits.first.map { "I noticed \($0) in my day." } ?? "Not present today",
      momentsShared: groundedBits.dropFirst().first.map { "I want to remember \($0)." } ?? "Not present today",
      quietBlessings: groundedBits.dropFirst(2).first.map { "A quiet detail was \($0)." } ?? "Not present today"
    )
    
    let contributions = ContributionItems(
      creativeWork: normalizedText.localizedCaseInsensitiveContains("made") ? "I made space for expression today." : nil,
      service: normalizedText.localizedCaseInsensitiveContains("help") ? "I offered care where I could." : nil,
      presenceOffered: normalizedText.localizedCaseInsensitiveContains("with") ? "I was present in an ordinary moment." : nil
    )
    
    return JournalReflection(
      wordOfTheDay: titleSeed,
      valueOfTheDay: groundedBits.first?.capitalized ?? "Presence",
      gratitude: gratitude,
      contributions: contributions,
      poeticReflection: opening.preview(limit: 90),
      emotionalImpact: closing.preview(limit: 110),
      mindfulnessPractice: normalizedText.localizedCaseInsensitiveContains("breathe") ? "A slower breath helped me return to the moment." : nil,
      spiritualConnection: nil,
      natureConnection: normalizedText.localizedCaseInsensitiveContains("walk") ? "The day held a small sense of movement and air." : nil,
      affirmation: "This page is enough exactly as it is.",
      tomorrowIntention: "Tomorrow I want to notice one honest moment and write it down."
    )
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
    Summary("Save \(\.$entry) to Quiet Pages")
  }
  
  func perform() async throws -> some IntentResult & ProvidesDialog {
    let trimmed = entry.trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard !trimmed.isEmpty else {
      return .result(dialog: IntentDialog("I need a few words to save to your journal."))
    }
    
    _ = await MainActor.run {
      JournalRepository.captureQuickEntry(text: trimmed, source: "siri")
    }
    return .result(dialog: IntentDialog("Saved your journal note in Quiet Pages."))
  }
}

@available(iOS 26.0, *)
struct StartReflectionIntent: AppIntent {
  static let title: LocalizedStringResource = "Start Reflection"
  static let description = IntentDescription("Open Quiet Pages with a prompt or draft ready to reflect on.")
  static let openAppWhenRun = true
  
  @Parameter(title: "Reflection Prompt")
  var prompt: String?
  
  static var parameterSummary: some ParameterSummary {
    Summary("Start a reflection with \(\.$prompt)")
  }
  
  func perform() async throws -> some IntentResult & ProvidesDialog {
    await MainActor.run {
      JournalRepository.savePendingDraft(prompt)
    }
    return .result(dialog: IntentDialog("Opening Quiet Pages for your next reflection."))
  }
}

@available(iOS 26.0, *)
struct ReviewLatestInsightIntent: AppIntent {
  static let title: LocalizedStringResource = "Review Latest Chapter"
  static let description = IntentDescription("Hear the latest affirmation or story beat from your journal.")
  
  func perform() async throws -> some IntentResult & ProvidesDialog {
    guard let latestEntry = await MainActor.run(body: {
      JournalRepository.latestEntry()
    }) else {
      return .result(dialog: IntentDialog("You do not have any journal entries yet."))
    }
    
    if let affirmation = latestEntry.affirmation, !affirmation.isEmpty {
      return .result(dialog: IntentDialog("Your latest affirmation is: \(affirmation)"))
    }
    
    return .result(dialog: IntentDialog("Your latest saved chapter is \(latestEntry.heroTitle)."))
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
          "What is my latest chapter in \(.applicationName)",
          "Read my affirmation from \(.applicationName)"
        ],
        shortTitle: "Latest Chapter",
        systemImageName: "sparkles"
      )
  }
}
