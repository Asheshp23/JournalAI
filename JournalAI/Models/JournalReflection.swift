//
//  JournalReflection.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2025-06-10.
//
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct JournalReflection {
  @Guide(description: "A single word that captures the essence of the day's experiences")
  let wordOfTheDay: String
  
  @Guide(description: "A core principle or value that guided decisions today")
  let valueOfTheDay: String
  
  @Guide(description: "Three specific things to be grateful for today")
  let gratitude: GratitudeItems
  
  @Guide(description: "Ways you contributed positively today")
  let contributions: ContributionItems
  
  @Guide(description: "2-3 lines reflecting the day's mood and energy")
  let poeticReflection: String
  
  @Guide(description: "One honest sentence about how the day affected you emotionally")
  let emotionalImpact: String
  
  @Guide(description: "Mindfulness moments or breathing practices from today")
  let mindfulnessPractice: String?
  
  @Guide(description: "Spiritual practices or moments of connection")
  let spiritualConnection: String?
  
  @Guide(description: "Interactions with nature and their impact")
  let natureConnection: String?
  
  @Guide(description: "A personal truth or positive statement to live by")
  let affirmation: String
  
  @Guide(description: "Tomorrow's gentle intention, not a rigid goal")
  let tomorrowIntention: String
}

@available(iOS 26.0, *)
@Generable
struct GratitudeItems: Codable, Equatable {
  @Guide(description: "Basic needs that were fulfilled")
  let needsMet: String
  
  @Guide(description: "Meaningful moments shared with others")
  let momentsShared: String
  
  @Guide(description: "Small, quiet blessings often overlooked")
  let quietBlessings: String
}

@available(iOS 26.0, *)
@Generable
struct ContributionItems: Codable, Equatable {
  @Guide(description: "Creative work or artistic expression")
  let creativeWork: String?
  
  @Guide(description: "Service provided to others")
  let service: String?
  
  @Guide(description: "Simply being present for someone or something")
  let presenceOffered: String?
}
