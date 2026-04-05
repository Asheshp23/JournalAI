//
//  MoodFilter.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-05.
//
import Foundation
import SwiftUI

enum MoodFilter: String, CaseIterable {
  case all   = "All"
  case warm  = "Warm"
  case calm  = "Calm"
  case deep  = "Deep"
  case light = "Light"
  
  var color: Color {
    switch self {
    case .all:   return EtherealTheme.textSecondary
    case .warm:  return Color(red: 0.85, green: 0.50, blue: 0.25)
    case .calm:  return Color(red: 0.35, green: 0.58, blue: 0.78)
    case .deep:  return Color(red: 0.52, green: 0.38, blue: 0.72)
    case .light: return Color(red: 0.32, green: 0.62, blue: 0.42)
    }
  }
}
