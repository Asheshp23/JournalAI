import Testing
@testable import JournalAI

@available(iOS 26.0, *)
@Suite("Journal grounding")
struct JournalGroundingTests {
  @Test("Grounded gratitude keeps details supported by the original entry")
  func keepsGroundedDetails() {
    let originalText = "I had coffee with my sister after our walk in the park and felt calmer afterward."
    let gratitude = GratitudeItems(
      needsMet: "coffee with my sister",
      momentsShared: "walk in the park",
      quietBlessings: "a promotion at work"
    )
    
    let details = JournalGrounding.groundedGratitudeDetails(
      gratitude: gratitude,
      originalText: originalText
    )
    
    #expect(details == ["coffee with my sister", "walk in the park"])
  }
  
  @Test("Grounded gratitude drops unsupported generated details")
  func dropsInventedDetails() {
    let originalText = "I stayed home, made tea, and read for a while before bed."
    let gratitude = GratitudeItems(
      needsMet: "tea before bed",
      momentsShared: "dinner with friends",
      quietBlessings: "reading for a while"
    )
    
    let details = JournalGrounding.groundedGratitudeDetails(
      gratitude: gratitude,
      originalText: originalText
    )
    
    #expect(details == ["tea before bed", "reading for a while"])
  }
}
