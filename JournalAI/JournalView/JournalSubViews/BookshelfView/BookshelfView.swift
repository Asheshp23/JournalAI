//
//  BookshelfView.swift
//  JournalAI
//
//  Redesigned: Books as vertical spines on a horizontal shelf,
//  grouped by month, with mood filter chips and rich entry detail.
//
import SwiftUI

struct BookshelfView: View {
  let entries: [FormattedJournalEntry]
  let onSelect: (FormattedJournalEntry) -> Void
  
  @State private var selectedFilter: MoodFilter = .all
  @State private var selectedEntry: FormattedJournalEntry? = nil
  
  private var groupedEntries: [(String, [FormattedJournalEntry])] {
    let fmt = DateFormatter()
    fmt.dateFormat = "MMMM yyyy"
    let filtered = filteredEntries
    let grouped = Dictionary(grouping: filtered) { fmt.string(from: $0.timestamp) }
    return grouped.sorted { a, b in
      let df = DateFormatter(); df.dateFormat = "MMMM yyyy"
      let da = df.date(from: a.0) ?? .distantPast
      let db = df.date(from: b.0) ?? .distantPast
      return da > db
    }
  }
  
  private var filteredEntries: [FormattedJournalEntry] {
    guard selectedFilter != .all else { return entries }
    return entries.filter { entry in
      let bucket = abs(entry.id.hashValue) % 4
      switch selectedFilter {
      case .warm:  return bucket == 0
      case .calm:  return bucket == 1
      case .deep:  return bucket == 2
      case .light: return bucket == 3
      case .all:   return true
      }
    }
  }
  
  private var currentStreak: Int {
    let calendar = Calendar.current
    var streak = 0
    var dayCursor = calendar.startOfDay(for: Date())
    let entryDays = Set(entries.map { calendar.startOfDay(for: $0.timestamp) })
    while entryDays.contains(dayCursor) {
      streak += 1
      guard let prev = calendar.date(byAdding: .day, value: -1, to: dayCursor) else { break }
      dayCursor = prev
    }
    return streak
  }
  
  var body: some View {
    ZStack {
      EtherealTheme.background.ignoresSafeArea()
      
      VStack(spacing: 0) {
        shelfHeader
        moodFilterRow
        
        if groupedEntries.isEmpty {
          emptyState
        } else {
          ScrollView {
            VStack(spacing: 32) {
              ForEach(groupedEntries, id: \.0) { monthLabel, monthEntries in
                ShelfMonthSection(
                  monthLabel: monthLabel,
                  entries: monthEntries
                ) { entry in
                  selectedEntry = entry
                }
              }
            }
            .padding(.top, 12)
            .padding(.bottom, 40)
          }
        }
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .sheet(item: $selectedEntry) { entry in
      EntryDetailSheet(entry: entry) {
        selectedEntry = nil
      }
    }
  }
  
  // MARK: Subviews
  
  private var shelfHeader: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text("Your Shelf")
          .font(.system(.largeTitle, design: .serif))
          .fontWeight(.semibold)
          .foregroundStyle(EtherealTheme.textMain)
        Text("\(entries.count) chapter\(entries.count == 1 ? "" : "s") written")
          .font(.caption)
          .foregroundStyle(EtherealTheme.tertiaryText)
      }
      Spacer()
      if currentStreak > 0 {
        HStack(spacing: 5) {
          Image(systemName: "flame.fill")
            .font(.caption)
            .foregroundStyle(Color(red: 0.85, green: 0.45, blue: 0.20))
          Text("\(currentStreak)d streak")
            .font(.caption.weight(.semibold))
            .foregroundStyle(EtherealTheme.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(EtherealTheme.surface)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(EtherealTheme.divider, lineWidth: 0.5))
      }
    }
    .padding(.horizontal, 20)
    .padding(.top, 16)
    .padding(.bottom, 8)
  }
  
  private var moodFilterRow: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(MoodFilter.allCases, id: \.self) { filter in
          MoodFilterChip(filter: filter, isSelected: selectedFilter == filter) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
              selectedFilter = filter
            }
          }
        }
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 10)
    }
  }
  
  private var emptyState: some View {
    VStack(spacing: 16) {
      Spacer()
      Image(systemName: "books.vertical")
        .font(.system(size: 48))
        .foregroundStyle(EtherealTheme.tertiaryText)
      Text("No entries in this mood")
        .font(.system(.subheadline, design: .serif))
        .foregroundStyle(EtherealTheme.textSecondary)
      Spacer()
    }
  }
}
