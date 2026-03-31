//
//  JournalView.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2025-06-06.
//
import SwiftUI

@available(iOS 26.0, *)
struct JournalView: View {
  @ObservedObject var vm: JournalVM
  @FocusState private var isInputFocused: Bool
  
  var body: some View {
    NavigationStack {
      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 24) {
          nudgeCard
          ritualStrip
          composerCard
          storyBeatsSection
          memorySection
          archiveSection
        }
        .padding(20)
      }
      .background(EtherealTheme.background.ignoresSafeArea())
      .navigationBarTitleDisplayMode(.inline)
    }
  }
  
  private var sectionSpacing: CGFloat { 12 }
  
  private var calmDivider: some View {
    Rectangle()
      .fill(EtherealTheme.divider)
      .frame(height: 1)
  }
  
  private var nudgeCard: some View {
    VStack(alignment: .leading, spacing: 10) {
      Label("Today’s nudge", systemImage: "sun.max.fill")
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(EtherealTheme.primary)
      Text(vm.adaptiveNudge)
        .font(.body)
        .foregroundStyle(EtherealTheme.textMain)
    }
    .padding(.vertical, 2)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  private var ritualStrip: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text(vm.storyTitle)
          .font(.title3.bold())
        Spacer()
        Text("\(vm.metrics.streakDays) day streak")
          .font(.caption.weight(.semibold))
          .foregroundStyle(EtherealTheme.textSecondary)
      }
      
      Text(vm.chapterPrompt)
        .font(.subheadline)
        .foregroundStyle(EtherealTheme.textSecondary)
      
      calmDivider
      
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(JournalRitualTemplate.allCases, id: \.self) { ritual in
            Button {
              vm.applyRitual(ritual)
              isInputFocused = ritual != .freewrite
            } label: {
              VStack(alignment: .leading, spacing: 8) {
                Label(ritual.title, systemImage: ritual.systemImage)
                  .font(.subheadline.weight(.semibold))
                Text(ritual.subtitle)
                  .font(.caption)
                  .multilineTextAlignment(.leading)
                  .lineLimit(3)
              }
              .foregroundStyle(vm.selectedRitual == ritual ? Color.white : EtherealTheme.textMain)
              .padding(16)
              .frame(width: 210, alignment: .leading)
              .background(vm.selectedRitual == ritual ? EtherealTheme.primary : EtherealTheme.surface)
              .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.vertical, 2)
      }
    }
  }
  
  private var composerCard: some View {
    VStack(alignment: .leading, spacing: 18) {
      HStack {
        VStack(alignment: .leading, spacing: 6) {
          Text(vm.selectedRitual.title)
            .font(.title3.bold())
          Text(vm.selectedRitual.subtitle)
            .font(.subheadline)
            .foregroundStyle(EtherealTheme.textSecondary)
        }
        Spacer()
        if vm.isProcessing {
          ProcessingIndicator()
        }
      }
      
      ZStack(alignment: .topLeading) {
        if vm.currentEntryText.isEmpty {
          Text("Write the scene, the feeling, the person, the shift, or the tiny grace you want this chapter to hold.")
            .foregroundStyle(EtherealTheme.textSecondary.opacity(0.65))
            .padding(.top, 12)
            .padding(.leading, 6)
        }
        
        TextEditor(text: $vm.currentEntryText)
          .focused($isInputFocused)
          .scrollContentBackground(.hidden)
          .font(.system(size: 18, design: .rounded))
          .frame(minHeight: 220)
          .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
              Spacer()
              Button("Done") {
                isInputFocused = false
              }
              .font(.headline)
              .foregroundStyle(EtherealTheme.primary)
            }
          }
      }
      .padding(12)
      .background(EtherealTheme.surface)
      .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
      
      HStack(spacing: 12) {
        Button {
          isInputFocused = false
          vm.saveQuickCapture()
        } label: {
          Label("Save Chapter", systemImage: "book.closed.fill")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(SecondaryActionButtonStyle())
        .disabled(vm.currentEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isProcessing)
        
        Button {
          isInputFocused = false
          Task { await vm.analyzeAndSaveEntry() }
        } label: {
          Label(vm.isProcessing ? "Shaping..." : "Shape Story", systemImage: "wand.and.stars")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryActionButtonStyle())
        .disabled(!vm.currentEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isMeaningful || vm.isProcessing)
      }
      
      HStack(spacing: 12) {
        Button {
          isInputFocused = false
          vm.askForMindfulPrism()
          Task { await vm.analyzeAndSaveEntry() }
        } label: {
          Label("Ask Mindful Prism", systemImage: "sparkles.rectangle.stack")
            .font(.subheadline.weight(.semibold))
        }
        .buttonStyle(.plain)
        .foregroundStyle(EtherealTheme.primary)
        .disabled(!vm.currentEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isMeaningful || vm.isProcessing)
        
        Spacer()
        
        Button {
          isInputFocused = false
          Task { await vm.generateImage() }
        } label: {
          Label("Illustrate Scene", systemImage: "photo.artframe")
            .font(.subheadline.weight(.semibold))
        }
        .buttonStyle(.plain)
        .foregroundStyle(EtherealTheme.secondary)
        .disabled(!vm.currentEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isMeaningful || vm.isProcessing)
      }
    }
    .padding(22)
    .background(EtherealTheme.cardGradient)
    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
  }
  
  @ViewBuilder
  private var storyBeatsSection: some View {
    if !vm.storyBeats.isEmpty {
      VStack(alignment: .leading, spacing: 14) {
        Text(vm.hasAskedForMindfulPrism ? "Your page, with Mindful Prism" : "Today’s story beats")
          .font(.title3.bold())
        
        ForEach(vm.storyBeats) { beat in
          VStack(alignment: .leading, spacing: 10) {
            Label(beat.title, systemImage: beat.systemImage)
              .font(.headline)
              .foregroundStyle(EtherealTheme.primary)
            Text(beat.body)
              .font(.body)
              .foregroundStyle(EtherealTheme.textMain)
          }
          .padding(18)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color.white)
          .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
      }
    }
  }
  
  private var archiveSection: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack {
        Text("Past chapters")
          .font(.title3.bold())
        Spacer()
        Text("\(vm.storyArchive.count) saved")
          .font(.caption.weight(.semibold))
          .foregroundStyle(EtherealTheme.textSecondary)
      }
      
      if vm.storyArchive.isEmpty {
        Text("Your saved chapters will appear here as your story grows.")
          .font(.subheadline)
          .foregroundStyle(EtherealTheme.textSecondary)
          .padding(18)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color.white)
          .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
      } else {
        ForEach(vm.storyArchive) { entry in
          HStack(alignment: .top, spacing: 14) {
            Circle()
              .fill(EtherealTheme.accent.opacity(0.55))
              .frame(width: 12, height: 12)
              .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 6) {
              Text(entry.heroTitle)
                .font(.headline)
                .foregroundStyle(EtherealTheme.textMain)
              Text(entry.supportingInsight)
                .font(.subheadline)
                .foregroundStyle(EtherealTheme.textSecondary)
                .lineLimit(2)
              Text(entry.displayDate)
                .font(.caption)
                .foregroundStyle(EtherealTheme.textSecondary)
            }
            
            Spacer()
            
            Button {
              vm.toggleFavorite(entryID: entry.id)
            } label: {
              Image(systemName: entry.isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(entry.isFavorite ? Color.red : EtherealTheme.textSecondary)
            }
            .buttonStyle(.plain)
          }
          .padding(18)
          .background(Color.white)
          .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
      }
    }
  }
  
  private var memorySection: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Memory trail")
        .font(.title3.bold())
      
      if let onThisDay = vm.onThisDayEntry {
        MemoryCard(
          title: "On this day",
          subtitle: onThisDay.heroTitle,
          bodyText: onThisDay.supportingInsight,
          footer: onThisDay.displayDate,
          gradient: LinearGradient(
            colors: [Color.white, EtherealTheme.accent.opacity(0.18)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
      }
      
      if let throwback = vm.throwbackEntry {
        MemoryCard(
          title: "A page worth revisiting",
          subtitle: throwback.heroTitle,
          bodyText: throwback.supportingInsight,
          footer: throwback.displayDate,
          gradient: LinearGradient(
            colors: [Color.white, Color.orange.opacity(0.10)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
      }
    }
  }
}

private struct MemoryCard: View {
  let title: String
  let subtitle: String
  let bodyText: String
  let footer: String
  let gradient: LinearGradient
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.headline)
      Text(subtitle)
        .font(.title3.bold())
      Text(bodyText)
        .font(.body)
        .foregroundStyle(EtherealTheme.textSecondary)
      Text(footer)
        .font(.caption)
        .foregroundStyle(EtherealTheme.textSecondary)
    }
    .padding(20)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(gradient)
    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
  }
}

private struct PrimaryActionButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.headline)
      .padding(.horizontal, 18)
      .padding(.vertical, 14)
      .background(configuration.isPressed ? EtherealTheme.primary.opacity(0.85) : EtherealTheme.primary)
      .foregroundStyle(.white)
      .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
  }
}

private struct SecondaryActionButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.headline)
      .padding(.horizontal, 18)
      .padding(.vertical, 14)
      .background(configuration.isPressed ? EtherealTheme.divider.opacity(0.8) : EtherealTheme.divider)
      .foregroundStyle(EtherealTheme.textMain)
      .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
  }
}
