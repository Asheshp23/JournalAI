//
//  JournalView.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2025-06-06.
//
import SwiftUI

@available(iOS 26.0, *)
struct JournalView: View {
  @State private var vm = JournalVM()
  @FocusState private var isTextEditorFocused: Bool
  
  var body: some View {
    ZStack {
      LinearGradient(
        colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()
      
      ZStack {
        ScrollViewReader { proxy in
          ScrollView {
            inputSection
            
            if vm.journalEntries.isEmpty && vm.streamingEntry == nil {
              Spacer()
              ContentUnavailableView(
                "No Entries Yet",
                systemImage: "book.closed.fill",
                description: Text("Your analyzed journal entries will appear here")
              )
              .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
              .padding()
            } else {
              entriesList
                .padding()
                .id("entriesList")
            }
          }
          .onChange(of: vm.streamingEntry) { _, newValue in
            if newValue != nil {
              withAnimation(.easeInOut) {
                proxy.scrollTo("entriesList", anchor: .bottom)
              }
            }
          }
        }
      }
      .navigationTitle("Journal Entry Analyzer")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
  
  private var inputSection: some View {
    VStack(spacing: 8) {
      TextEditor(text: $vm.currentEntryText)
        .focused($isTextEditorFocused)
        .frame(minHeight: 120)
        .overlay(
          Text("What's on your mind?")
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(20)
            .allowsHitTesting(false)
            .opacity(vm.currentEntryText.isEmpty ? 1 : 0)
        )
      HStack {
        if !vm.currentEntryText.isEmpty {
          Text("\(vm.currentEntryText.count) characters")
            .font(.caption)
            .foregroundStyle(.primary)
          Spacer()
          Button {
            withAnimation {
              vm.currentEntryText = ""
            }
          } label: {
            Image(systemName: "xmark.circle.fill")
              .foregroundColor(.secondary.opacity(0.8))
              .font(.title3)
              .padding(12)
          }
          .buttonStyle(.plain)
          .accessibilityLabel("Clear entry text")
        }
      }
      HStack {
        Spacer()
        
        Button {
          Task {
            await vm.analyzeAndSaveEntry()
          }
        } label: {
          HStack(spacing: 8) {
            if vm.isProcessing {
              ProcessingIndicator()
            } else {
              Image(systemName: "sparkles")
            }
            Text(vm.isProcessing ? "Enhancing..." : "Enhance this entry")
              .fontWeight(.semibold)
          }
          .padding(.horizontal, 20)
          .padding(.vertical, 12)
          .background(
            vm.isProcessing ?
            LinearGradient(colors: [Color.purple.opacity(0.8), Color.purple.opacity(0.8)], startPoint: .top, endPoint: .bottom) :
              LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing),
            in: Capsule()
          )
          .foregroundColor(.white)
          .scaleEffect(vm.isProcessing ? 1.05 : 1.0)
          .animation(.spring(), value: vm.isProcessing)
        }
        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
        .disabled(vm.currentEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isProcessing)
        .opacity(vm.currentEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
      }
    }
    .padding(.all)
  }
  
  private var entriesList: some View {
    LazyVStack(spacing: 16) {
      if let streaming = vm.streamingEntry {
        ZStack(alignment: .topTrailing) {
          FormattedEntryCard(entry: streaming, alwaysExpanded: false)
            .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
          HStack(spacing: 8) {
            ProcessingIndicator()
            Text("Generating...")
              .font(.caption)
              .foregroundStyle(.primary)
          }
          .padding(12)
        }
      }
      ForEach(Array(vm.journalEntries.enumerated()), id: \.element.id) { (offset, element) in
        FormattedEntryCard(entry: element, alwaysExpanded: offset == 0)
          .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
      }
    }
    .padding(.vertical)
  }
}

#Preview {
  if #available(iOS 26.0, *) {
    JournalView()
  } else {
    // Fallback on earlier versions
  }
}
