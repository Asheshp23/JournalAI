//
//  JournalView.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2025-06-06.
//
import SwiftUI

@available(iOS 17.0, *)
struct JournalView: View {
  @State private var vm = JournalVM()
  @FocusState private var isInputFocused: Bool
  
  var body: some View {
    ZStack(alignment: .bottom) {
      EtherealTheme.background.ignoresSafeArea()
      
      VStack(spacing: 0) {
        // MARK: - Top Bar
        HStack {
          Image(systemName: "circle.grid.cross.fill")
            .foregroundStyle(EtherealTheme.primary)
          Text("The Mindful Prism")
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(EtherealTheme.primary)
          Spacer()
          Image(systemName: "person.crop.circle.fill")
            .font(.title2)
            .foregroundStyle(EtherealTheme.textSecondary.opacity(0.5))
        }
        .padding()
        
        ScrollView(showsIndicators: false) {
          VStack(alignment: .leading, spacing: 32) {
            
            // Header
            VStack(alignment: .leading, spacing: 8) {
              Text("Reflection Space")
                .font(.system(size: 38, weight: .bold, design: .rounded))
              Text("Translate your thoughts into clarity. Let the prism illuminate the patterns within your words.")
                .font(.subheadline)
                .foregroundColor(EtherealTheme.textSecondary)
            }
            .padding(.horizontal)
            
            // MARK: - Input Area
            VStack(spacing: 16) {
              ZStack(alignment: .topLeading) {
                if vm.currentEntryText.isEmpty {
                  Text("How is your heart today?")
                    .foregroundColor(EtherealTheme.textSecondary.opacity(0.5))
                    .padding(.top, 12)
                    .padding(.leading, 4)
                }
                
                TextEditor(text: $vm.currentEntryText)
                  .frame(minHeight: 180)
                  .scrollContentBackground(.hidden)
                  .font(.system(size: 18, design: .rounded))
                  .focused($isInputFocused)
              }
              
              HStack {
                Spacer()
                Button(action: {
                  isInputFocused = false
                  Task { await vm.analyzeAndSaveEntry() }
                }) {
                  HStack {
                    if vm.isProcessing {
                      ProgressView().tint(.white)
                    } else {
                      Image(systemName: "sparkles")
                    }
                    Text(vm.isProcessing ? "Reflecting..." : "Enhance this entry")
                      .fontWeight(.bold)
                  }
                  .padding(.vertical, 14)
                  .padding(.horizontal, 24)
                  .background(vm.currentEntryText.isEmpty ? Color.gray.opacity(0.3) : EtherealTheme.primary)
                  .foregroundColor(.white)
                  .cornerRadius(25)
                }
                .disabled(vm.currentEntryText.isEmpty || vm.isProcessing)
              }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(32)
            .shadow(color: Color.black.opacity(0.04), radius: 20, x: 0, y: 10)
            .padding(.horizontal)
            
            // MARK: - AI Insights Section
            // Only show if we have a streaming entry or saved entries
            if let entry = vm.streamingEntry ?? vm.journalEntries.first {
              VStack(spacing: 24) {
                // Section Divider
                HStack {
                  Rectangle().fill(EtherealTheme.divider).frame(height: 1)
                  Text("PRISM INSIGHTS").font(.caption2).bold().tracking(2).foregroundColor(.gray)
                  Rectangle().fill(EtherealTheme.divider).frame(height: 1)
                }
                
                // Bento Grid Layout
                InsightCard(
                  icon: "book.fill",
                  category: "WORD OF THE DAY",
                  title: entry.wordOfTheDay ?? "...",
                  detail: "A thread that weaves through your current inner landscape.",
                  color: .blue
                )
                
                if let value = entry.valueOfTheDay {
                  InsightCard(
                    icon: "heart.fill",
                    category: "VALUE OF THE DAY",
                    title: value,
                    detail: "A guiding principle emerging from your reflection.",
                    color: .teal
                  )
                }
                
                if let poetic = entry.poeticReflection {
                  PoeticCard(text: poetic)
                }
                
                if let impact = entry.emotionalImpact {
                  EmotionalImpactCard(title: impact)
                }
                
                if let affirmation = entry.affirmation {
                  AffirmationCard(text: affirmation)
                }
              }
              .padding(.horizontal)
              .transition(.move(edge: .bottom).combined(with: .opacity))
            }
          }
          .padding(.bottom, 120)
        }
      }
      
      // Custom Floating Tab Bar
      CustomTabBar()
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
    .animation(.spring(), value: vm.streamingEntry)
    .animation(.spring(), value: vm.isProcessing)
  }
}
#Preview {
  if #available(iOS 17.0, *) {
    JournalView()
  } else {
    Text("iOS 17+ required")
  }
}
