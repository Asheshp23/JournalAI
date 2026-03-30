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
          heroSection
          promptStrip
          composerCard
          siriCard
          
          if let entry = vm.latestEntry {
            latestInsightSection(entry: entry)
          }
        }
        .padding(20)
      }
      .background(EtherealTheme.background.ignoresSafeArea())
      .navigationTitle("Reflect")
    }
  }
  
  private var heroSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("JournalAI")
        .font(.caption.weight(.semibold))
        .foregroundStyle(EtherealTheme.primary)
        .textCase(.uppercase)
      
      Text("A calmer journaling flow, now with quick capture, history, insights, and Siri.")
        .font(.system(size: 34, weight: .bold, design: .rounded))
        .foregroundStyle(EtherealTheme.textMain)
      
      Text("Product direction: make reflection easier to start, easier to return to, and useful even when you only have a few seconds.")
        .font(.subheadline)
        .foregroundStyle(EtherealTheme.textSecondary)
    }
  }
  
  private var promptStrip: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Start from a prompt")
        .font(.headline)
      
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(vm.suggestedPrompts, id: \.self) { prompt in
            Button {
              vm.applyPrompt(prompt)
              isInputFocused = true
            } label: {
              Text(prompt)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(vm.selectedPrompt == prompt ? Color.white : EtherealTheme.textMain)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(vm.selectedPrompt == prompt ? EtherealTheme.primary : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
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
          Text("Reflection space")
            .font(.title3.bold())
          Text("Write freely, quick-save a note, or ask AI to shape it into insight.")
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
          Text("What happened today, what stayed with you, or what do you need to release?")
            .foregroundStyle(EtherealTheme.textSecondary.opacity(0.65))
            .padding(.top, 12)
            .padding(.leading, 6)
        }
        
        TextEditor(text: $vm.currentEntryText)
          .focused($isInputFocused)
          .scrollContentBackground(.hidden)
          .font(.system(size: 18, design: .rounded))
          .frame(minHeight: 190)
      }
      .padding(12)
      .background(EtherealTheme.background)
      .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
      
      HStack(spacing: 12) {
        Button {
          isInputFocused = false
          vm.saveQuickCapture()
        } label: {
          Label("Quick Save", systemImage: "tray.and.arrow.down")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(SecondaryActionButtonStyle())
        .disabled(vm.currentEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isProcessing)
        
        Button {
          isInputFocused = false
          Task { await vm.analyzeAndSaveEntry() }
        } label: {
          Label(vm.isProcessing ? "Reflecting..." : "Reflect", systemImage: "sparkles")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryActionButtonStyle())
        .disabled(!vm.currentEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isMeaningful || vm.isProcessing)
      }
      
      Button {
        isInputFocused = false
        Task { await vm.generateImage() }
      } label: {
        Label("Create reflection image", systemImage: "photo.artframe")
          .font(.subheadline.weight(.semibold))
      }
      .buttonStyle(.plain)
      .foregroundStyle(EtherealTheme.primary)
      .disabled(!vm.currentEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isMeaningful || vm.isProcessing)
    }
    .padding(22)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    .shadow(color: Color.black.opacity(0.06), radius: 22, x: 0, y: 12)
  }
  
  private var siriCard: some View {
    VStack(alignment: .leading, spacing: 10) {
      Label("Siri and App Intents", systemImage: "waveform.and.mic")
        .font(.headline)
      Text("Try phrases like “Save a journal entry in JournalAI”, “Start reflecting in JournalAI”, or “What is my latest insight in JournalAI”.")
        .font(.subheadline)
        .foregroundStyle(EtherealTheme.textSecondary)
    }
    .padding(18)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      LinearGradient(
        colors: [Color.white, Color.blue.opacity(0.08)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    )
    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
  }
  
  @ViewBuilder
  private func latestInsightSection(entry: FormattedJournalEntry) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text("Latest insight")
          .font(.title3.bold())
        Spacer()
        Button {
          vm.selectedTab = .timeline
        } label: {
          Text("View timeline")
            .font(.subheadline.weight(.semibold))
        }
        .buttonStyle(.plain)
        .foregroundStyle(EtherealTheme.primary)
      }
      
      if entry.hasReflectionContent {
        FormattedEntryCard(entry: entry, alwaysExpanded: true, showExpansionButton: false)
      } else {
        VStack(alignment: .leading, spacing: 10) {
          Text("Quick capture")
            .font(.headline)
          Text(entry.originalText)
            .font(.body)
            .foregroundStyle(EtherealTheme.textMain)
          Text(entry.displayDate)
            .font(.caption)
            .foregroundStyle(EtherealTheme.textSecondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
      }
    }
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
