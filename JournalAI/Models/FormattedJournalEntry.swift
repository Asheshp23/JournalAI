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
  
  init(originalText: String) {
    self.id = UUID()
    self.originalText = originalText
    self.timestamp = Date()
    self.isProcessed = false
    
    self.wordOfTheDay = nil
    self.valueOfTheDay = nil
    self.gratitude = nil
    self.contributions = nil
    self.poeticReflection = nil
    self.emotionalImpact = nil
    self.mindfulnessPractice = nil
    self.spiritualConnection = nil
    self.natureConnection = nil
    self.affirmation = nil
    self.tomorrowIntention = nil
    self.imageData = nil
    self.processingError = nil
  }
  
  var displayDate: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: timestamp)
  }
  
  var hasReflectionContent: Bool {
    return wordOfTheDay != nil ||
    valueOfTheDay != nil ||
    gratitude != nil ||
    emotionalImpact != nil
  }
}
