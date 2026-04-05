//
//  ShelfPlank.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-05.
//
import SwiftUI

struct ShelfPlank: View {
  var body: some View {
    VStack(spacing: 0) {
      Rectangle()
        .fill(Color(red: 0.78, green: 0.68, blue: 0.52))
        .frame(height: 2)
      Rectangle()
        .fill(
          LinearGradient(
            colors: [
              Color(red: 0.62, green: 0.50, blue: 0.34),
              Color(red: 0.50, green: 0.40, blue: 0.26)
            ],
            startPoint: .top,
            endPoint: .bottom
          )
        )
        .frame(height: 10)
    }
    .clipShape(RoundedRectangle(cornerRadius: 2))
    .shadow(color: .black.opacity(0.22), radius: 5, x: 0, y: 4)
  }
}
