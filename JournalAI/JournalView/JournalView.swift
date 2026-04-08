import SwiftUI

@available(iOS 26.0, *)
struct JournalView: View {
  @ObservedObject var vm: JournalVM
  @FocusState private var isInputFocused: Bool
  
  @State private var currentPageIndex = 0
  @State private var coverOpenProgress = 0.0
  @State private var hasOpenedCover = false
  @State private var showCloseConfirm = false
  @State private var showBookshelf = false
  @State private var nudgeDismissed = false
  
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
          
          // 2b. Nudge card (contextual, dismissable)
          if !nudgeDismissed && !isInputFocused,
             let nudge = NudgeProvider.nudge(for: vm) {
            NudgeCard(nudge: nudge) {
              withAnimation(.easeOut(duration: 0.25)) { nudgeDismissed = true }
            } onTap: { action in
              switch action {
              case .openThrowback:
                showBookshelf = true
              case .suggestPrompt(let prompt):
                vm.applyPrompt(prompt)
              }
              withAnimation { nudgeDismissed = true }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 4)
            .transition(.move(edge: .top).combined(with: .opacity))
          }
          
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
      .ignoresSafeArea(.keyboard, edges: .bottom)
      .toolbar {
        ToolbarItemGroup(placement: .keyboard) {
          Spacer()
          Button("Done") {
            isInputFocused = false
          }
        }
      }
      .navigationDestination(isPresented: $showBookshelf) {
        BookshelfView(entries: vm.journalEntries)
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
        ZStack(alignment: .topTrailing) {
          Image(systemName: "book.closed")
            .font(.system(size: 20, weight: .light))
          if vm.journalEntries.count > 0 {
            Text("\(min(vm.journalEntries.count, 99))")
              .font(.system(size: 8, weight: .bold))
              .foregroundStyle(.white)
              .padding(2)
              .frame(minWidth: 14)
              .background(EtherealTheme.primary)
              .clipShape(Capsule())
              .offset(x: 8, y: -6)
          }
        }
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
    Task {
      try? await Task.sleep(for: .seconds(1.2))
      hasOpenedCover = true
    }
  }
}
