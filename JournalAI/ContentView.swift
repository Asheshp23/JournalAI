//
//  ContentView.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2025-06-11.
//
import SwiftUI

struct ContentView: View {
  var body: some View {
    NavigationStack {
      JournalView()
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
