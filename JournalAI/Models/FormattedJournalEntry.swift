//
//  FormattedJournalEntry.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2025-06-06.
//
import Foundation

@available(iOS 26.0, *)
struct FormattedJournalEntry: Identifiable, Codable, Equatable {
  let id: UUID
  let originalText: String
  let timestamp: Date
  let captureSource: String
  
  var wordOfTheDay: String?
  var valueOfTheDay: String?
  var gratitude: GratitudeItems?
  var contributions: ContributionItems?
  var poeticReflection: String?
  var emotionalImpact: String?
  var mindfulnessPractice: String?
  var spiritualConnection: String?
  var natureConnection: String?
  var affirmation: String?
  var tomorrowIntention: String?
  var imageData: Data?
  var isProcessed: Bool
  var processingError: String?
  var isFavorite: Bool
  
  nonisolated init(
    id: UUID = UUID(),
    originalText: String,
    timestamp: Date = Date(),
    captureSource: String = "manual",
    wordOfTheDay: String? = nil,
    valueOfTheDay: String? = nil,
    gratitude: GratitudeItems? = nil,
    contributions: ContributionItems? = nil,
    poeticReflection: String? = nil,
    emotionalImpact: String? = nil,
    mindfulnessPractice: String? = nil,
    spiritualConnection: String? = nil,
    natureConnection: String? = nil,
    affirmation: String? = nil,
    tomorrowIntention: String? = nil,
    imageData: Data? = nil,
    isProcessed: Bool = false,
    processingError: String? = nil,
    isFavorite: Bool = false
  ) {
    self.id = id
    self.originalText = originalText
    self.timestamp = timestamp
    self.captureSource = captureSource
    self.wordOfTheDay = wordOfTheDay
    self.valueOfTheDay = valueOfTheDay
    self.gratitude = gratitude
    self.contributions = contributions
    self.poeticReflection = poeticReflection
    self.emotionalImpact = emotionalImpact
    self.mindfulnessPractice = mindfulnessPractice
    self.spiritualConnection = spiritualConnection
    self.natureConnection = natureConnection
    self.affirmation = affirmation
    self.tomorrowIntention = tomorrowIntention
    self.imageData = imageData
    self.isProcessed = isProcessed
    self.processingError = processingError
    self.isFavorite = isFavorite
  }
  
  nonisolated var displayDate: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: timestamp)
  }
  
  nonisolated var hasReflectionContent: Bool {
    return wordOfTheDay != nil ||
    valueOfTheDay != nil ||
    gratitude != nil ||
    emotionalImpact != nil
  }
  
  nonisolated var heroTitle: String {
    if let wordOfTheDay, !wordOfTheDay.isEmpty {
      return wordOfTheDay
    }
    
    if let valueOfTheDay, !valueOfTheDay.isEmpty {
      return valueOfTheDay
    }
    
    return originalText.preview(limit: 42)
  }
  
  nonisolated var supportingInsight: String {
    if let affirmation, !affirmation.isEmpty {
      return affirmation
    }
    
    if let emotionalImpact, !emotionalImpact.isEmpty {
      return emotionalImpact
    }
    
    if isProcessed {
      return "Reflection captured"
    }
    
    return "Quick capture saved"
  }
  
  nonisolated var reflectionStatus: String {
    isProcessed ? "Reflected" : "Captured"
  }
}
