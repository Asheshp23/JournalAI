//
//  EntryDetailSheet.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-05.
//
import SwiftUI

@available(iOS 26.0, *)
struct EntryDetailSheet: View {
  let entry: FormattedJournalEntry
  let onClose: () -> Void
  
  @State private var prismOpen = false
  @State private var activeLens: PrismLens? = nil
  @State private var lensResult: String = ""
  
  enum PrismLens: String, CaseIterable, Hashable {
    case deepen  = "Deepen"
    case reframe = "Reframe"
    case distill = "Distill"
    
    var icon: String {
      switch self {
      case .deepen:  return "🌊"
      case .reframe: return "🔮"
      case .distill: return "✨"
      }
    }
    var description: String {
      switch self {
      case .deepen:  return "Expand emotional nuance beneath the surface"
      case .reframe: return "Offer an alternative perspective on this"
      case .distill: return "The core truth in one resonant sentence"
      }
    }
  }
  
  private var headerGradient: LinearGradient {
    let (c1, c2) = BookColorPalette.colors(for: entry)
    return LinearGradient(colors: [c1, c2], startPoint: .topLeading, endPoint: .bottomTrailing)
  }
  
  var body: some View {
    NavigationStack {
      ZStack {
        EtherealTheme.background.ignoresSafeArea()
        
        ScrollView(showsIndicators: false) {
          VStack(alignment: .leading, spacing: 0) {
            detailHeader
            
            VStack(alignment: .leading, spacing: 24) {
              // Original journal text
              Text(entry.originalText)
                .font(.custom("Noteworthy", size: 17))
                .lineSpacing(8)
                .foregroundStyle(EtherealTheme.textMain)
              
              Divider().background(EtherealTheme.divider)
              
              mindfulPrismSection
              
              if entry.isProcessed {
                reflectionInsights
              }
              
              onThisDayHint
              
              Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            onClose()
          } label: {
            HStack(spacing: 4) {
              Image(systemName: "chevron.left")
                .font(.system(size: 13, weight: .semibold))
              Text("Shelf")
                .font(.subheadline)
            }
            .foregroundStyle(EtherealTheme.primary)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Image(systemName: entry.isFavorite ? "bookmark.fill" : "bookmark")
            .foregroundStyle(EtherealTheme.primary)
        }
      }
      .navigationBarTitleDisplayMode(.inline)
    }
  }
  
  // MARK: - Header
  
  private var detailHeader: some View {
    ZStack(alignment: .bottomLeading) {
      headerGradient.frame(height: 220)
      
      if let imageData = entry.imageData, let ui = UIImage(data: imageData) {
        Image(uiImage: ui)
          .resizable()
          .scaledToFill()
          .frame(height: 220)
          .clipped()
          .opacity(0.35)
      }
      
      VStack(alignment: .leading, spacing: 6) {
        HStack(spacing: 6) {
          if let mood = entry.emotionalImpact {
            DetailPill(text: String(mood.prefix(24)), color: .white.opacity(0.22))
          }
          if entry.isProcessed {
            DetailPill(text: "reflected", color: .white.opacity(0.18))
          }
        }
        Text(entry.heroTitle)
          .font(.system(.title2, design: .serif))
          .fontWeight(.semibold)
          .foregroundStyle(.white)
          .lineLimit(2)
        Text(entry.displayDate)
          .font(.caption)
          .foregroundStyle(.white.opacity(0.65))
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 20)
    }
    .clipShape(
      UnevenRoundedRectangle(
        topLeadingRadius: 0,
        bottomLeadingRadius: 20,
        bottomTrailingRadius: 20,
        topTrailingRadius: 0
      )
    )
  }
  
  // MARK: - Mindful Prism
  
  private var mindfulPrismSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Button {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
          prismOpen.toggle()
          if !prismOpen { activeLens = nil; lensResult = "" }
        }
      } label: {
        HStack(spacing: 12) {
          PrismGemView()
            .frame(width: 36, height: 36)
          
          VStack(alignment: .leading, spacing: 2) {
            Text("Mindful Prism")
              .font(.subheadline.weight(.semibold))
              .foregroundStyle(Color(red: 0.52, green: 0.35, blue: 0.72))
            Text("On-device · private · 3 lenses")
              .font(.caption2)
              .foregroundStyle(EtherealTheme.tertiaryText)
          }
          Spacer()
          Image(systemName: prismOpen ? "chevron.up" : "chevron.down")
            .font(.caption.weight(.semibold))
            .foregroundStyle(EtherealTheme.tertiaryText)
        }
        .padding(14)
        .background(Color(red: 0.52, green: 0.35, blue: 0.72).opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
          RoundedRectangle(cornerRadius: 14)
            .stroke(Color(red: 0.52, green: 0.35, blue: 0.72).opacity(0.22), lineWidth: 0.5)
        )
      }
      .buttonStyle(.plain)
      
      if prismOpen {
        VStack(spacing: 8) {
          ForEach(PrismLens.allCases, id: \.self) { lens in
            PrismLensButton(
              lens: lens,
              isActive: activeLens == lens
            ) {
              withAnimation(.easeInOut(duration: 0.2)) {
                activeLens = lens
                lensResult = makeLensResult(lens)
              }
            }
          }
          
          if !lensResult.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
              Text(lensResult)
                .font(.system(.subheadline, design: .serif))
                .italic()
                .foregroundStyle(EtherealTheme.textSecondary)
                .lineSpacing(4)
              
              HStack(spacing: 4) {
                Image(systemName: "cpu")
                  .font(.system(size: 10))
                Text("Generated on-device · not stored")
                  .font(.caption2)
              }
              .foregroundStyle(EtherealTheme.tertiaryText)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 0.52, green: 0.35, blue: 0.72).opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .leading) {
              Rectangle()
                .fill(Color(red: 0.62, green: 0.42, blue: 0.82))
                .frame(width: 2)
                .clipShape(RoundedRectangle(cornerRadius: 1))
            }
            .transition(.move(edge: .top).combined(with: .opacity))
          }
        }
        .padding(.horizontal, 2)
        .transition(.move(edge: .top).combined(with: .opacity))
      }
    }
  }
  
  // MARK: - AI Reflection Insights
  
  @ViewBuilder
  private var reflectionInsights: some View {
    VStack(alignment: .leading, spacing: 12) {
      SectionLabel("Reflection")
      
      if let affirmation = entry.affirmation {
        InsightTile(icon: "sparkles", label: "Affirmation", content: affirmation, accentColor: EtherealTheme.primary)
      }
      if let tomorrow = entry.tomorrowIntention {
        InsightTile(icon: "arrow.right.circle", label: "Tomorrow's Intention", content: tomorrow, accentColor: EtherealTheme.secondary)
      }
      if let poetic = entry.poeticReflection {
        InsightTile(icon: "text.quote", label: "Poetic Reflection", content: poetic, accentColor: EtherealTheme.accent)
      }
    }
  }
  
  // MARK: - On This Day
  
  private var onThisDayHint: some View {
    VStack(alignment: .leading, spacing: 8) {
      SectionLabel("From around this time, other years")
      
      HStack(spacing: 8) {
        Image(systemName: "clock.arrow.circlepath")
          .foregroundStyle(EtherealTheme.tertiaryText)
          .font(.caption)
        Text("Past entries from this period will appear here")
          .font(.caption)
          .foregroundStyle(EtherealTheme.tertiaryText)
          .italic()
      }
      .padding(12)
      .background(EtherealTheme.surface)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .overlay(RoundedRectangle(cornerRadius: 10).stroke(EtherealTheme.divider, lineWidth: 0.5))
    }
  }
  
  // MARK: - Lens result placeholder (wire to on-device LLM)
  
  private func makeLensResult(_ lens: PrismLens) -> String {
    let preview = String(entry.originalText.prefix(80))
    switch lens {
    case .deepen:
      return "Beneath \"\(preview)…\" there may be a deeper longing for stillness — a part of you that's been running on output for a while."
    case .reframe:
      return "What if this feeling isn't a problem to solve, but information to receive? The resistance itself might be the doorway."
    case .distill:
      return entry.affirmation ?? "You are in the process of becoming — and that is already enough."
    }
  }
}
