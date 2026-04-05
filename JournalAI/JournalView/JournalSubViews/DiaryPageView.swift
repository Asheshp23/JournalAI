//
//  DiaryPageView.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-04.
//
import SwiftUI

@available(iOS 26.0, *)
struct DiaryPageView: View {
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
