//
//  JournalViewModel.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2025-06-06.
//
import Foundation
import FoundationModels
import CoreGraphics
import ImagePlayground
import UIKit

@available(iOS 26.0, *)
@MainActor
@Observable
class JournalVM {
  var journalEntries: [FormattedJournalEntry] = []
  var currentEntryText: String = ""
  var isProcessing = false
  var streamingEntry: FormattedJournalEntry? = nil
  var generatedImage: CGImage? = nil
  
  private let modelSession = LanguageModelSession()
  
  func analyzeAndSaveEntry() async {
    let trimmed = currentEntryText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.isMeaningful else { return }
    
    await MainActor.run {
      isProcessing = true
      streamingEntry = nil
    }
    defer { Task { await MainActor.run { isProcessing = false; self.streamingEntry = nil } } }
    
    do {
      let formattedEntry = try await processEntry(trimmed)
      await MainActor.run {
        journalEntries.insert(formattedEntry, at: 0)
        currentEntryText = ""
      }
    } catch {
      // Handle error appropriately
      print("Failed to process entry: \(error)")
    }
  }
  
  func generateImage() async {
    let trimmed = currentEntryText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.isMeaningful else { return }
    
    await MainActor.run {
      isProcessing = true
      streamingEntry = nil
    }
    defer { Task { await MainActor.run { isProcessing = false; self.streamingEntry = nil } } }
    
    do {
      let formattedEntry = try await processEntry(trimmed)
      
      let imageCreator = try await ImageCreator()
      let style = ImagePlaygroundStyle.animation
      
      let images = imageCreator.images(
        for: [.text("\(buildImagePrompt(from: formattedEntry))")],
        style: style,
        limit: 1
      )
      
      for try await image in images {
        if let jpegData = UIImage(cgImage: image.cgImage).jpegData(compressionQuality: 0.95) {
          var newEntry = formattedEntry
          newEntry.imageData = jpegData
          await MainActor.run {
            journalEntries.insert(newEntry, at: 0)
          }
        }
      }
      await MainActor.run {
        currentEntryText = ""
      }
    } catch {
      print(error.localizedDescription)
    }
  }
  
  private func processEntry(_ text: String) async throws -> FormattedJournalEntry {
    let prompt = buildStructuredPrompt(from: text)
    var lastEntry = FormattedJournalEntry(originalText: text)
    
    let stream = modelSession.streamResponse(
      to: prompt,
      generating: JournalReflection.self,
      options: GenerationOptions(temperature: 1.0)
    )
    
    for try await item in stream {
      let partialEntry = mapToFormattedEntry(originalText: text, reflection: item.content)
      await MainActor.run { self.streamingEntry = partialEntry }
      lastEntry = partialEntry
    }
    lastEntry.isProcessed = true
    return lastEntry
    
  }
  
  private func mapToFormattedEntry(originalText: String, reflection: JournalReflection.PartiallyGenerated) -> FormattedJournalEntry {
    var entry = FormattedJournalEntry(originalText: originalText)
    
    entry.wordOfTheDay = (reflection.wordOfTheDay ?? "").isEmpty ? nil : reflection.wordOfTheDay
    entry.valueOfTheDay = (reflection.valueOfTheDay ?? "").isEmpty ? nil : reflection.valueOfTheDay
    entry.poeticReflection = (reflection.poeticReflection ?? "").isEmpty ? nil : reflection.poeticReflection
    entry.emotionalImpact = (reflection.emotionalImpact ?? "").isEmpty ? nil : reflection.emotionalImpact
    entry.affirmation = (reflection.affirmation ?? "").isEmpty ? nil : reflection.affirmation
    entry.tomorrowIntention = (reflection.tomorrowIntention ?? "").isEmpty ? nil : reflection.tomorrowIntention
    
    if let partialGratitude = reflection.gratitude {
      let needsMet = partialGratitude.needsMet ?? ""
      let momentsShared = partialGratitude.momentsShared ?? ""
      let quietBlessings = partialGratitude.quietBlessings ?? ""
      if needsMet.isEmpty && momentsShared.isEmpty && quietBlessings.isEmpty {
        entry.gratitude = nil
      } else {
        entry.gratitude = GratitudeItems(needsMet: needsMet, momentsShared: momentsShared, quietBlessings: quietBlessings)
      }
    } else {
      entry.gratitude = nil
    }
    
    if let partialContrib = reflection.contributions {
      let creativeWork = partialContrib.creativeWork
      let service = partialContrib.service
      let presenceOffered = partialContrib.presenceOffered
      if (creativeWork ?? "").isEmpty && (service ?? "").isEmpty && (presenceOffered ?? "").isEmpty {
        entry.contributions = nil
      } else {
        entry.contributions = ContributionItems(creativeWork: creativeWork, service: service, presenceOffered: presenceOffered)
      }
    } else {
      entry.contributions = nil
    }
    
    // Optional fields
    entry.mindfulnessPractice = (reflection.mindfulnessPractice ?? "").isEmpty ? nil : reflection.mindfulnessPractice
    entry.spiritualConnection = (reflection.spiritualConnection ?? "").isEmpty ? nil : reflection.spiritualConnection
    entry.natureConnection = (reflection.natureConnection ?? "").isEmpty ? nil : reflection.natureConnection
    
    entry.isProcessed = true
    return entry
  }
  
  
  private func buildStructuredPrompt(from text: String) -> String {
    
    let format = """
    🪶 Word of the Day
    A thread that weaves through the day’s inner and outer landscape
    
    💠 Value of the Day
    A guiding principle I tried to live by
    
    🌅 Gratitude
    • Needs met
    • Moments shared
    • Quiet blessings
    
    🌱 Contributions
    • Creative work
    • Service
    • Presence offered
    
    🎨 Poetic Reflection
    A few lines that echo the mood, tone, or energy of the day
    
    💞 Emotional Impact
    One honest sentence on how the day touched me
    
    🫁 Mindfulness Practice
    Breathwork, stillness, conscious pauses
    Any moment I truly arrived in my body and breath
    
    🕊 Spiritual Connection
    Mantra, prayer, silence, or awe
    
    🌄 Nature & Connection
    Trees, sky, wind, earth, and how they held me
    
    ✨ Affirmation
    A truth I want to live from
    
    🌟 Intention for Tomorrow
    A gentle focus, not a demand
    
    """
    
    return """
    Act as a life coach and
    Transform this journal entry into the specified format. Extract relevant themes and emotions.
    
    Input: \(currentEntryText)
    
    Required format:
    \(format)
    
    Instructions:
    - Find genuine connections between the input and each section
    - If a section doesn't apply, write "Not present today"
    - Keep responses authentic to the original entry's tone
    - Response should be swiftui text component friendly
    """
  }
  
  private func buildImagePrompt(from entry: FormattedJournalEntry) -> String {
    var elements: [String] = []
    
    if let emotion = entry.emotionalImpact {
      elements.append("mood: \(emotion)")
    }
    
    if let nature = entry.natureConnection {
      elements.append("natural setting: \(nature)")
    }
    
    if let poetic = entry.poeticReflection {
      elements.append("atmosphere: \(poetic)")
    }
    
    let style = elements.isEmpty ? "abstract mindful composition" : elements.joined(separator: ", ")
    
    return "Artistic representation of \(style), minimalist, contemplative, soft lighting"
  }
}
