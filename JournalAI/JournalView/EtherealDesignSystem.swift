import SwiftUI

struct EtherealTheme {
  static let background = Color(red: 0.96, green: 0.95, blue: 0.92)
  static let surface = Color(red: 0.99, green: 0.985, blue: 0.97)
  static let primary = Color(red: 0.36, green: 0.42, blue: 0.39)
  static let secondary = Color(red: 0.55, green: 0.60, blue: 0.56)
  static let accent = Color(red: 0.83, green: 0.79, blue: 0.70)
  static let textMain = Color(red: 0.18, green: 0.20, blue: 0.19)
  static let textSecondary = Color(red: 0.43, green: 0.46, blue: 0.44)
  static let divider = Color(red: 0.87, green: 0.86, blue: 0.82)
  
  static let heroGradient = LinearGradient(
    colors: [
      Color(red: 0.90, green: 0.90, blue: 0.86),
      Color(red: 0.82, green: 0.84, blue: 0.80)
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )
  
  static let cardGradient = LinearGradient(
    colors: [
      Color.white.opacity(0.96),
      Color(red: 0.97, green: 0.965, blue: 0.95)
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )
}
