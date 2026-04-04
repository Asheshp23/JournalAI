import SwiftUI
import UIKit

@available(iOS 26.0, *)
struct JournalView: View {
  @ObservedObject var vm: JournalVM
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @FocusState private var isInputFocused: Bool
  
  @State private var currentPageIndex = 0
  @State private var pageTurnProgress = 0.0
  @State private var coverOpenProgress = 0.0
  @State private var hasOpenedCover = false
  @State private var showCloseConfirm = false
  @State private var showBookshelf = false
  
  // Logic to determine what the user is looking at
  private var pages: [DiaryPage] {
    [.draft] + vm.journalEntries.map(DiaryPage.entry)
  }
  
  var body: some View {
    NavigationStack {
      ZStack {
        // 1. Immersive Background
        EtherealTheme.background.ignoresSafeArea()
        backgroundTexture
        
        VStack(spacing: 0) {
          // 2. Refined Top Bar
          journalTopBar
          
          // 3. The Main Writing Surface
          ZStack {
            bookStage
            
            // 4. Floating Magic Bar (AI Tools)
            if !isInputFocused {
              magicActionToolbar
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
          }
        }
        
        // 5. Opening Animation Cover
        if !hasOpenedCover {
          DiaryCover(openProgress: coverOpenProgress)
            .padding(20)
        }
      }
      .navigationDestination(isPresented: $showBookshelf) {
        BookshelfView(entries: vm.journalEntries) { _ in showBookshelf = false }
      }
      .onAppear(perform: openCoverIfNeeded)
      .alert("Close Diary?", isPresented: $showCloseConfirm) {
        Button("Save & Close") { vm.saveQuickCapture(); showBookshelf = true }
        Button("Discard", role: .destructive) { vm.currentEntryText = ""; showBookshelf = true }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("Would you like to save your progress before closing?")
      }
    }
  }
  
  // MARK: - Subviews
  
  private var backgroundTexture: some View {
    Canvas { context, size in
      // Subtle paper grain or dots can be drawn here for high-end feel
    }
    .opacity(0.05)
    .ignoresSafeArea()
  }
  
  private var journalTopBar: some View {
    HStack {
      Button {
        if vm.currentEntryText.isMeaningful { showCloseConfirm = true }
        else { showBookshelf = true }
      } label: {
        Image(systemName: "book.closed")
          .font(.system(size: 20, weight: .light))
      }
      
      Spacer()
      
      VStack(spacing: 2) {
        Text(Date.now.formatted(.dateTime.day().month().attributedStyle))
          .font(.caption2.weight(.bold).italic())
          .foregroundStyle(EtherealTheme.tertiaryText)
        Text(vm.storyTitle)
          .font(.system(.subheadline, design: .serif))
          .fontWeight(.semibold)
      }
      
      Spacer()
      
      Button { vm.saveQuickCapture() } label: {
        Text("Done")
          .font(.subheadline.weight(.bold))
          .foregroundStyle(vm.currentEntryText.isMeaningful ? EtherealTheme.primary : EtherealTheme.tertiaryText)
      }
      .disabled(!vm.currentEntryText.isMeaningful)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .background(.ultraThinMaterial.opacity(0.5))
  }
  
  private var bookStage: some View {
    GeometryReader { proxy in
      let pageWidth = proxy.size.width * 0.92
      
      DiaryPageView(
        page: pages[currentPageIndex],
        vm: vm,
        isInputFocused: $isInputFocused
      )
      .frame(width: pageWidth)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 10)
    }
  }
  
  private var magicActionToolbar: some View {
    VStack {
      Spacer()
      HStack(spacing: 15) {
        MagicButton(icon: "sparkles.rectangle.stack", label: "Prism", color: EtherealTheme.secondary) {
          vm.askForMindfulPrism()
          Task { await vm.analyzeAndSaveEntry() }
        }
        
        MagicButton(icon: "photo.artframe", label: "Illustrate", color: EtherealTheme.accent) {
          Task { await vm.generateImage() }
        }
        
        MagicButton(icon: "wand.and.stars", label: "Refine", color: EtherealTheme.primary) {
          Task { await vm.analyzeAndSaveEntry() }
        }
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 12)
      .background(.ultraThinMaterial)
      .clipShape(Capsule())
      .overlay(Capsule().stroke(Color.white.opacity(0.5), lineWidth: 0.5))
      .padding(.bottom, 30)
      .disabled(!vm.currentEntryText.isMeaningful || vm.isProcessing)
      .opacity(vm.currentEntryText.isMeaningful ? 1 : 0.6)
    }
  }
  
  private func openCoverIfNeeded() {
    guard !hasOpenedCover else { return }
    withAnimation(.easeInOut(duration: 1.2)) { coverOpenProgress = 1 }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { hasOpenedCover = true }
  }
}

// MARK: - Refined Supporting Components

private struct MagicButton: View {
  let icon: String
  let label: String
  let color: Color
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        Image(systemName: icon)
          .font(.system(size: 18, weight: .medium))
        Text(label)
          .font(.system(size: 10, weight: .bold))
      }
      .foregroundStyle(color)
      .frame(width: 65)
    }
  }
}

@available(iOS 26.0, *)
private struct DiaryPageView: View {
  let page: DiaryPage
  @ObservedObject var vm: JournalVM
  var isInputFocused: FocusState<Bool>.Binding
  
  var body: some View {
    ZStack {
      DiaryPaper(cornerRadius: 20)
      
      VStack(alignment: .leading, spacing: 0) {
        // Ritual Switcher (Horizontal & Slim)
        if case .draft = page {
          ritualMiniPicker
            .padding(.top, 40) // Align with paper lines
        }
        
        ScrollView(showsIndicators: false) {
          VStack(alignment: .leading, spacing: 20) {
            headerSection
            
            switch page {
            case .draft:
              draftEditor
            case .entry(let entry):
              SavedDiaryPage(entry: entry)
            }
          }
          .padding(.horizontal, 40) // Align text with paper margin
          .padding(.top, 10)
        }
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: 20))
  }
  
  private var headerSection: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(page.headerTitle)
        .font(.custom("Snell Roundhand", size: 28))
        .foregroundStyle(EtherealTheme.textMain)
      Text(page.headerSubtitle(for: vm))
        .font(.system(.caption, design: .serif))
        .foregroundStyle(EtherealTheme.textSecondary)
    }
  }
  
  private var ritualMiniPicker: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        ForEach(JournalRitualTemplate.allCases, id: \.self) { ritual in
          Toggle(ritual.title, isOn: Binding(
            get: { vm.selectedRitual == ritual },
            set: { if $0 { vm.applyRitual(ritual) } }
          ))
          .toggleStyle(RitualPillStyle(icon: ritual.systemImage))
        }
      }
      .padding(.horizontal, 40)
    }
    .frame(height: 40)
  }
  
  private var draftEditor: some View {
    ZStack(alignment: .topLeading) {
      if vm.currentEntryText.isEmpty {
        Text(vm.chapterPrompt)
          .font(.custom("Noteworthy", size: 20))
          .foregroundStyle(EtherealTheme.tertiaryText)
          .padding(.top, 8)
      }
      
      TextEditor(text: $vm.currentEntryText)
        .focused(isInputFocused)
        .scrollContentBackground(.hidden)
        .font(.custom("Noteworthy", size: 20))
        .lineSpacing(12) // Crucial: Match this to the background line height
        .foregroundStyle(EtherealTheme.textMain)
        .frame(minHeight: 400)
    }
  }
}

// MARK: - Professional Styles

struct RitualPillStyle: ToggleStyle {
  let icon: String
  func makeBody(configuration: Configuration) -> some View {
    Button { configuration.isOn = true } label: {
      HStack(spacing: 4) {
        Image(systemName: icon)
        configuration.label
      }
      .font(.system(size: 12, weight: .medium))
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(configuration.isOn ? EtherealTheme.secondary : Color.clear)
      .foregroundStyle(configuration.isOn ? .white : EtherealTheme.textSecondary)
      .clipShape(Capsule())
      .overlay(Capsule().stroke(EtherealTheme.divider, lineWidth: configuration.isOn ? 0 : 1))
    }
  }
}

// MARK: - Helper Data Models

@available(iOS 26.0, *)
enum DiaryPage: Identifiable {
  case draft
  case entry(FormattedJournalEntry)
  
  var id: String {
    switch self {
    case .draft: return "draft"
    case .entry(let entry): return entry.id.uuidString
    }
  }
  
  var headerTitle: String {
    switch self {
    case .draft: return "A fresh page"
    case .entry(let entry): return entry.displayDate
    }
  }
  
  func headerSubtitle(for vm: JournalVM) -> String {
    switch self {
    case .draft: return vm.adaptiveNudge
    case .entry(let entry): return entry.supportingInsight
    }
  }
}

// MARK: - Refined Paper Component

struct DiaryPaper: View {
  let cornerRadius: CGFloat
  
  var body: some View {
    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
      .fill(EtherealTheme.paper)
      .overlay(alignment: .topLeading) {
        // The Margin Line (Vertical)
        Rectangle()
          .fill(EtherealTheme.destructive.opacity(0.15))
          .frame(width: 1.5)
          .padding(.leading, 32)
      }
      .overlay {
        // The Horizontal Lines
        VStack(spacing: 31.5) { // Adjusted to match Noteworthy font height
          ForEach(0..<22, id: \.self) { _ in
            Rectangle()
              .fill(EtherealTheme.line.opacity(0.4))
              .frame(height: 0.5)
          }
        }
        .padding(.top, 48)
        .allowsHitTesting(false)
      }
      .overlay {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .strokeBorder(EtherealTheme.divider.opacity(0.4))
      }
  }
}

// MARK: - Refined Saved Page View

@available(iOS 26.0, *)
struct SavedDiaryPage: View {
  let entry: FormattedJournalEntry
  
  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      // Content
      Text(entry.originalText)
        .font(.custom("Noteworthy", size: 20))
        .lineSpacing(12)
        .foregroundStyle(EtherealTheme.textMain)
      
      // AI Insights "Sticky Notes"
      if let impact = entry.emotionalImpact {
        VStack(alignment: .leading, spacing: 8) {
          Label("THE ESSENCE", systemImage: "sparkles")
            .font(.system(size: 10, weight: .black))
            .foregroundStyle(EtherealTheme.secondary)
          
          Text(impact)
            .font(.system(.subheadline, design: .serif))
            .italic()
            .padding(.leading, 12)
            .overlay(alignment: .leading) {
              Rectangle().fill(EtherealTheme.secondary.opacity(0.3)).frame(width: 2)
            }
        }
        .padding(.vertical, 10)
      }
      
      if let imageData = entry.imageData, let uiImage = UIImage(data: imageData) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFit()
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .shadow(radius: 5)
      }
    }
    .padding(.bottom, 100) // Space for the toolbar
  }
}
