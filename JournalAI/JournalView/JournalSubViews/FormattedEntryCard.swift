//
//  FormattedEntryCard.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2025-06-16.
//
import SwiftUI

@available(iOS 26.0, *)
struct FormattedEntryCard: View {
  let entry: FormattedJournalEntry
  let alwaysExpanded: Bool
  let showExpansionButton: Bool
  @State private var isExpanded: Bool
  
  @State private var shimmerOpacity: Double = 0.0
  @State private var animateGradient = false
  @State private var showFullImage = false
  
  init(entry: FormattedJournalEntry, alwaysExpanded: Bool = false, showExpansionButton: Bool = true) {
    self.entry = entry
    self.alwaysExpanded = alwaysExpanded
    self.showExpansionButton = showExpansionButton
    _isExpanded = State(initialValue: alwaysExpanded)
  }
  
  var body: some View {
    ZStack {
      Ellipse()
        .fill(
          LinearGradient(
            colors: [Color.pink.opacity(0.4), Color.blue.opacity(0.4), Color.purple.opacity(0.4)],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
          )
        )
        .frame(width: 300, height: 180)
        .blur(radius: 30)
        .offset(x: -40, y: 20)
        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animateGradient)
        .onAppear {
          animateGradient = true
        }
      VStack(alignment: .leading, spacing: 12) {
        VStack(alignment: .leading, spacing: 16) {
          HStack {
            VStack(alignment: .leading) {
              if let wordOfTheDay = entry.wordOfTheDay {
                ReflectionSection(icon: "🌅", title: "Word of the Day", content: wordOfTheDay)
              }
              if let value = entry.valueOfTheDay {
                ReflectionSection(icon: "💠", title: "Value of the Day", content: value)
              }
            }
          }
          if let poeticReflection = entry.poeticReflection {
            ReflectionSection(icon: "📝", title: "Poetic Reflection", content: poeticReflection)
          }
          if let emotional = entry.emotionalImpact {
            ReflectionSection(icon: "💞", title: "Emotional Impact", content: emotional)
          }
          if let affirmation = entry.affirmation {
            ReflectionSection(icon: "✨", title: "Affirmation", content: affirmation)
          }
          if let tomorrowIntention = entry.tomorrowIntention {
            ReflectionSection(icon: "🌅", title: "Tomorrow's Focus", content: tomorrowIntention)
          }
          
          if let gratitude = entry.gratitude {
            ReflectionSection(icon: "😇", title: "Gratitude", content: formatGratitude(gratitude))
          }
          if let contributionItems = entry.contributions {
            if let service = contributionItems.service {
              ReflectionSection(icon: "🛠️", title: "Service", content: service)
            }
            if let creativeWork = contributionItems.creativeWork {
              ReflectionSection(icon: "🎨", title: "Creative Work", content: creativeWork)
            }
            if let presenceOffered = contributionItems.presenceOffered {
              ReflectionSection(icon: "🤝", title: "Presence Offered", content: presenceOffered)
            }
          }
          
          if let mindfulnessPractice = entry.mindfulnessPractice {
            ReflectionSection(icon: "🧘‍♀️", title: "Mindfulness Practice", content: mindfulnessPractice)
          }
          
          if let spiritualConnection = entry.spiritualConnection {
            ReflectionSection(icon: "🙏", title: "Spiritual Connection", content: spiritualConnection)
          }
          
          
          if let natureConnection = entry.natureConnection {
            ReflectionSection(icon: "🌿", title: "Nature Connection", content: natureConnection)
          }
          
          VStack(alignment: .leading, spacing: 12) {
            if let imageData = entry.imageData, let image = UIImage(data: imageData) {
              Text("Creative reflection")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(LinearGradient(
                  colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.8)],
                  startPoint: .leading,
                  endPoint: .trailing
                ))
                .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 1)
              Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: showFullImage ? .infinity : 200)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                  RoundedRectangle(cornerRadius: 6)
                    .stroke(.quaternary, lineWidth: 1)
                )
                .onTapGesture {
                  showFullImage.toggle()
                }
            }
          }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
      }
      .padding(20)
      .modifier(CardBackground())
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(.white.opacity(0.25), lineWidth: 1.5)
      )
      .shadow(color: .blue.opacity(0.15), radius: 30, x: 0, y: 16)
    }
    .scaleEffect(1.0)
  }
  
  private func formatGratitude(_ gratitude: GratitudeItems) -> String {
    var items: [String] = []
    if !gratitude.needsMet.isEmpty { items.append("• \(gratitude.needsMet)") }
    if !gratitude.momentsShared.isEmpty { items.append("• \(gratitude.momentsShared)") }
    if !gratitude.quietBlessings.isEmpty { items.append("• \(gratitude.quietBlessings)") }
    return items.joined(separator: "\n")
  }
}
