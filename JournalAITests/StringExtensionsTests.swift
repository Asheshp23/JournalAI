import Testing
@testable import JournalAI

@Suite("String helpers")
struct StringExtensionsTests {
  @Test(
    "Meaningful text detection",
    arguments: [
      ("  hello world  ", true),
      ("123456", false),
      ("hi", false),
      ("     ", false)
    ]
  )
  func detectsMeaningfulText(input: String, expected: Bool) {
    #expect(input.isMeaningful == expected)
  }
  
  @Test("Preview truncates and keeps shorter text intact")
  func previewBehavior() {
    #expect("short note".preview(limit: 20) == "short note")
    #expect("this is a longer note for testing".preview(limit: 10) == "this is a .…")
  }
  
  @Test("Grounding tokens normalize punctuation and remove common filler words")
  func groundingTokens() {
    let tokens = "Today, I felt calmer after coffee with my sister!".groundingTokens
    
    #expect(tokens.contains("calmer"))
    #expect(tokens.contains("coffee"))
    #expect(tokens.contains("sister"))
    #expect(tokens.contains("today") == false)
    #expect(tokens.contains("with") == false)
  }
}
