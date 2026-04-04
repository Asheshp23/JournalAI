//
//  JournalReflection.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2025-06-10.
//
import Foundation

@available(iOS 26.0, *)
struct JournalReflection: Codable, Equatable {
  let wordOfTheDay: String
  let valueOfTheDay: String
  let gratitude: GratitudeItems
  let contributions: ContributionItems
  let poeticReflection: String
  let emotionalImpact: String
  let mindfulnessPractice: String?
  let spiritualConnection: String?
  let natureConnection: String?
  let affirmation: String
  let tomorrowIntention: String
}

@available(iOS 26.0, *)
struct GratitudeItems: Codable, Equatable {
  let needsMet: String
  let momentsShared: String
  let quietBlessings: String
}

@available(iOS 26.0, *)
struct ContributionItems: Codable, Equatable {
  let creativeWork: String?
  let service: String?
  let presenceOffered: String?
}
