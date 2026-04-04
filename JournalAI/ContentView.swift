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
    JournalView(vm: vm)
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
}

private struct StatusBanner: View {
  let message: String
  let dismiss: () -> Void
  
  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: "sparkles")
        .foregroundStyle(EtherealTheme.primary)
      Text(message)
        .font(.subheadline.weight(.medium))
        .foregroundStyle(EtherealTheme.textMain)
      Spacer()
      Button("Dismiss", action: dismiss)
        .font(.caption.bold())
        .foregroundStyle(EtherealTheme.primary)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
  }
}
