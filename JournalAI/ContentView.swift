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
        colors: [EtherealTheme.primary, EtherealTheme.secondary],
        startPoint: .leading,
        endPoint: .trailing
      )
    )
    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    .shadow(color: EtherealTheme.primary.opacity(0.25), radius: 16, x: 0, y: 8)
  }
}
