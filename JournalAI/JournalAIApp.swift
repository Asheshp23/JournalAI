//
//  JournalAIApp.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2025-06-11.
//
import SwiftUI
import AppIntents

@available(iOS 26.0, *)
@main
struct QuietPagesApp: App {
  init() {
    JournalAppShortcuts.updateAppShortcutParameters()
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .tint(EtherealTheme.primary)
    }
  }
}
