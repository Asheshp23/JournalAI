# JournalAI

JournalAI is a mindful iOS journaling app that treats each day like a chapter instead of a checklist.
It combines calm, story-based writing with Apple's on-device Foundation Models so reflection can stay private, gentle, and lightweight.

## Product Direction

Most journal apps fall into one of a few buckets:
- life logging
- prompt-heavy habit tracking
- mood dashboards
- AI summaries

JournalAI aims for a different feeling:
- one quiet screen
- one page at a time
- a story-first writing flow
- optional AI shaping only when the user asks for it

## Current Experience

- Story-based daily writing with chapter framing
- Guided rituals like `3 Good Things`, `Morning Reset`, and `Evening Reflection`
- Time-and-day-aware mindful nudges
- Local persistence for saved entries
- Memory resurfacing through rewind and "on this day" moments
- Siri/App Intents support for quick capture and opening the app into reflection
- Optional `Mindful Prism` shaping instead of always-on AI output

## Tech Stack

- SwiftUI
- Swift
- App Intents
- UserNotifications
- Apple's Foundation Models
- Image Playground

## Project Notes

- The app currently targets iOS 26.
- Journal entries are stored locally with `UserDefaults`.
- AI struct generation is powered by `FoundationModels` in [JournalAI/Models/JournalReflection.swift](JournalAI/Models/JournalReflection.swift).

## Local Build Caveat

In this environment, builds are blocked by the `FoundationModels` macro/plugin pipeline rather than the app UI code itself.
The failing area is the macro-backed schema in `JournalReflection.swift`.

## Getting Started

1. Open `JournalAI.xcodeproj` in Xcode.
2. Build on a compatible iPhone or supported iOS runtime.
3. Start with a ritual, write a page, and only ask `Mindful Prism` if you want the extra shaping.

## Next Good Improvements

- Replace the current generated reflection schema with a fallback path for environments where Foundation Models macros are unavailable
- Add export/share for saved chapters
- Add richer chapter browsing without losing the minimal, mindful feel
