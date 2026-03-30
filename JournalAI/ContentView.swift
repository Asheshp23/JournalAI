//
//  ContentView.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2025-06-11.
//
import SwiftUI

@available(iOS 26.0, *)
struct ContentView: View {
  @StateObject private var vm = JournalVM()
  
  var body: some View {
    TabView(selection: binding(for: \.selectedTab)) {
      JournalView(vm: vm)
        .tag(AppTab.reflect)
        .tabItem {
          Label(AppTab.reflect.title, systemImage: AppTab.reflect.systemImage)
        }
      
      JournalTimelineView(vm: vm)
        .tag(AppTab.timeline)
        .tabItem {
          Label(AppTab.timeline.title, systemImage: AppTab.timeline.systemImage)
        }
      
      JournalInsightsView(vm: vm)
        .tag(AppTab.insights)
        .tabItem {
          Label(AppTab.insights.title, systemImage: AppTab.insights.systemImage)
        }
    }
    .tint(EtherealTheme.primary)
    .task {
      vm.consumePendingIntentState()
    }
    .safeAreaInset(edge: .top) {
      if let statusMessage = vm.statusMessage {
        StatusBanner(message: statusMessage) {
          vm.dismissStatus()
        }
        .padding(.horizontal)
        .padding(.top, 8)
      }
    }
  }
  
  private func binding<Value>(for keyPath: ReferenceWritableKeyPath<JournalVM, Value>) -> Binding<Value> {
    Binding(
      get: { vm[keyPath: keyPath] },
      set: { vm[keyPath: keyPath] = $0 }
    )
  }
}

@available(iOS 26.0, *)
private struct JournalTimelineView: View {
  @ObservedObject var vm: JournalVM
  
  var body: some View {
    NavigationStack {
      Group {
        if vm.journalEntries.isEmpty {
          ContentUnavailableView(
            "No entries yet",
            systemImage: "book.closed",
            description: Text("Use Reflect or Siri quick capture to start building your timeline.")
          )
        } else {
          List {
            Section {
              ForEach(vm.journalEntries) { entry in
                VStack(alignment: .leading, spacing: 16) {
                  HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                      Text(entry.heroTitle)
                        .font(.title3.bold())
                        .foregroundStyle(EtherealTheme.textMain)
                      Text(entry.supportingInsight)
                        .font(.subheadline)
                        .foregroundStyle(EtherealTheme.textSecondary)
                        .lineLimit(2)
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
                  
                  HStack {
                    Label(entry.reflectionStatus, systemImage: entry.isProcessed ? "sparkles" : "tray.full")
                    Spacer()
                    Text(entry.displayDate)
                  }
                  .font(.caption)
                  .foregroundStyle(EtherealTheme.textSecondary)
                  
                  if entry.hasReflectionContent {
                    FormattedEntryCard(entry: entry, alwaysExpanded: true, showExpansionButton: false)
                  } else {
                    Text(entry.originalText)
                      .font(.body)
                      .foregroundStyle(EtherealTheme.textMain)
                      .padding(16)
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .background(Color.white)
                      .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                  }
                }
                .listRowInsets(EdgeInsets(top: 18, leading: 20, bottom: 18, trailing: 20))
                .listRowBackground(Color.clear)
              }
              .onDelete(perform: vm.deleteEntries)
            } header: {
              VStack(alignment: .leading, spacing: 8) {
                Text("Your timeline")
                  .font(.title.bold())
                Text("Every note, reflection, and visual memory in one place.")
                  .font(.subheadline)
                  .foregroundStyle(EtherealTheme.textSecondary)
              }
              .textCase(nil)
            }
          }
          .listStyle(.plain)
          .scrollContentBackground(.hidden)
          .background(EtherealTheme.background.ignoresSafeArea())
        }
      }
      .navigationTitle("Timeline")
    }
  }
}

@available(iOS 26.0, *)
private struct JournalInsightsView: View {
  @ObservedObject var vm: JournalVM
  
  var body: some View {
    NavigationStack {
      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 24) {
          VStack(alignment: .leading, spacing: 8) {
            Text("Insight dashboard")
              .font(.largeTitle.bold())
              .foregroundStyle(EtherealTheme.textMain)
            Text("A product-owner view of momentum, consistency, and the emotional signal emerging from your writing.")
              .font(.subheadline)
              .foregroundStyle(EtherealTheme.textSecondary)
          }
          
          LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            InsightMetricCard(title: "Entries", value: "\(vm.metrics.totalEntries)", detail: "Total captures")
            InsightMetricCard(title: "Reflected", value: "\(vm.metrics.reflectedEntries)", detail: "AI-shaped notes")
            InsightMetricCard(title: "This Week", value: "\(vm.metrics.weeklyEntries)", detail: "Weekly rhythm")
            InsightMetricCard(title: "Streak", value: "\(vm.metrics.streakDays)", detail: "Days in a row")
          }
          
          VStack(alignment: .leading, spacing: 12) {
            Text("Reflection completion")
              .font(.headline)
            ProgressView(value: vm.reflectionCompletionRatio)
              .tint(EtherealTheme.primary)
            Text("\(Int(vm.reflectionCompletionRatio * 100))% of your entries have been fully reflected.")
              .font(.subheadline)
              .foregroundStyle(EtherealTheme.textSecondary)
          }
          .padding(20)
          .background(Color.white)
          .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
          
          if let affirmation = vm.latestAffirmation {
            VStack(alignment: .leading, spacing: 12) {
              Text("Latest affirmation")
                .font(.headline)
              Text("“\(affirmation)”")
                .font(.title3.weight(.semibold))
                .foregroundStyle(EtherealTheme.textMain)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
              LinearGradient(
                colors: [Color.white, EtherealTheme.primary.opacity(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
          }
          
          if let entry = vm.latestEntry {
            VStack(alignment: .leading, spacing: 12) {
              Text("Latest highlighted insight")
                .font(.headline)
              Text(entry.heroTitle)
                .font(.title2.bold())
              Text(entry.supportingInsight)
                .font(.body)
                .foregroundStyle(EtherealTheme.textSecondary)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
          }
        }
        .padding(20)
      }
      .background(EtherealTheme.background.ignoresSafeArea())
      .navigationTitle("Insights")
    }
  }
}

private struct InsightMetricCard: View {
  let title: String
  let value: String
  let detail: String
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title.uppercased())
        .font(.caption.weight(.semibold))
        .foregroundStyle(EtherealTheme.textSecondary)
      Text(value)
        .font(.system(size: 32, weight: .bold, design: .rounded))
        .foregroundStyle(EtherealTheme.textMain)
      Text(detail)
        .font(.subheadline)
        .foregroundStyle(EtherealTheme.textSecondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
  }
}

private struct StatusBanner: View {
  let message: String
  let dismiss: () -> Void
  
  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: "sparkles")
        .foregroundStyle(.white)
      Text(message)
        .font(.subheadline.weight(.medium))
        .foregroundStyle(.white)
      Spacer()
      Button("Dismiss", action: dismiss)
        .font(.caption.bold())
        .foregroundStyle(.white.opacity(0.9))
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
    .background(
      LinearGradient(
        colors: [EtherealTheme.primary, Color.blue.opacity(0.9)],
        startPoint: .leading,
        endPoint: .trailing
      )
    )
    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    .shadow(color: EtherealTheme.primary.opacity(0.25), radius: 16, x: 0, y: 8)
  }
}
