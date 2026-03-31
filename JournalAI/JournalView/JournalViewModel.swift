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
import UserNotifications

@available(iOS 26.0, *)
enum JournalRitualTemplate: String, CaseIterable, Hashable {
  case threeGoodThings
  case morningReset
  case eveningReflection
  case freewrite
  
  var title: String {
    switch self {
    case .threeGoodThings:
      return "3 Good Things"
    case .morningReset:
      return "Morning Reset"
    case .eveningReflection:
      return "Evening Reflection"
    case .freewrite:
      return "Freewrite"
    }
  }
  
  var systemImage: String {
    switch self {
    case .threeGoodThings:
      return "heart.text.square"
    case .morningReset:
      return "sunrise.fill"
    case .eveningReflection:
      return "moon.stars.fill"
    case .freewrite:
      return "square.and.pencil"
    }
  }
  
  var subtitle: String {
    switch self {
    case .threeGoodThings:
      return "A proven gratitude ritual that keeps the daily habit simple."
    case .morningReset:
      return "Start the day by noticing what is already supportive."
    case .eveningReflection:
      return "Close the day with gratitude, learning, and softness."
    case .freewrite:
      return "A blank page when you want to think in your own shape."
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
enum JournalRepository {
  nonisolated(unsafe) private static let entriesKey = "journal.entries"
  nonisolated(unsafe) private static let pendingDraftKey = "journal.pendingDraft"
  
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
  @Published var statusMessage: String?
  @Published var selectedPrompt: String?
  @Published var selectedRitual: JournalRitualTemplate = .threeGoodThings
  @Published var hasAskedForMindfulPrism = false
  
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
    
    if let gratitude = entry.gratitude {
      let details = [
        gratitude.needsMet,
        gratitude.momentsShared,
        gratitude.quietBlessings
      ]
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
      .joined(separator: " • ")
      
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
  
  func dismissStatus() {
    statusMessage = nil
  }
  
  func applyPrompt(_ prompt: String) {
    selectedPrompt = prompt
    currentEntryText = prompt
    hasAskedForMindfulPrism = false
  }
  
  func applyRitual(_ ritual: JournalRitualTemplate) {
    selectedRitual = ritual
    hasAskedForMindfulPrism = false
    
    guard !ritual.starterText.isEmpty else { return }
    currentEntryText = ritual.starterText
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
      statusMessage = "Your new chapter has been shaped and saved."
      hasAskedForMindfulPrism = true
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
    Act as a warm, insightful gratitude journaling guide.
    Transform the user's note into a grounded gratitude reflection.
    
    User note:
    \(text)
    
    Produce:
    - a word of the day
    - a value of the day
    - gratitude with needs met, moments shared, and quiet blessings, always grounded in concrete details
    - contributions with creative work, service, and presence offered
    - a short poetic reflection
    - one emotional impact sentence
    - optional mindfulness, spiritual, and nature connections when genuinely present
    - an affirmation
    - a gentle intention for tomorrow
    
    Guidelines:
    - Prioritize appreciation, perspective, and emotional honesty over self-optimization
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
    JournalRepository.savePendingDraft(prompt)
    return .result(dialog: IntentDialog("Opening JournalAI for your next reflection."))
  }
}

@available(iOS 26.0, *)
struct ReviewLatestInsightIntent: AppIntent {
  static let title: LocalizedStringResource = "Review Latest Chapter"
  static let description = IntentDescription("Hear the latest affirmation or story beat from your journal.")
  
  func perform() async throws -> some IntentResult & ProvidesDialog {
    guard let latestEntry = JournalRepository.latestEntry() else {
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
