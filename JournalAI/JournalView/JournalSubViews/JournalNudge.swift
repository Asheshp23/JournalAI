//
//  JournalNudge.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-05.
//


//
//  NudgeCard.swift
//  JournalAI
//
//  Apple Journal-style gentle nudges — time-aware, non-intrusive,
//  contextually relevant prompts that invite without demanding.
//

import SwiftUI

// MARK: - Nudge Model

struct JournalNudge: Identifiable {
    let id = UUID()
    let icon: String
    let headline: String
    let subtext: String
    let action: NudgeAction

    enum NudgeAction {
        case openThrowback
        case suggestPrompt(String)
        case weeklyReflection
        case streakCelebration(Int)
    }
}

// MARK: - Nudge Provider

@available(iOS 26.0, *)
enum NudgeProvider {
    static func nudge(for vm: JournalVM) -> JournalNudge? {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())

        // Priority 1: Throwback entry exists
        if let throwback = vm.throwbackEntry {
            let days = calendar.dateComponents([.day], from: throwback.timestamp, to: Date()).day ?? 0
            return JournalNudge(
                icon: "clock.arrow.circlepath",
                headline: "A moment from \(days) days ago",
                subtext: "\(throwback.heroTitle) does it still feel true?",
                action: .openThrowback
            )
        }

        // Priority 2: "On this day" in another year
        if vm.onThisDayEntry != nil {
            return JournalNudge(
                icon: "calendar.badge.clock",
                headline: "On this day, last year",
                subtext: "You wrote something that might resonate today.",
                action: .openThrowback
            )
        }

        // Priority 3: Time-of-day prompt nudge
        let prompts: [Int: (String, String, String)] = [
            6:  ("sunrise.fill",  "Good morning.",          "What intention do you want to carry into today?"),
            8:  ("cup.and.saucer","Still morning.",          "A good time to write before the day begins."),
            12: ("sun.max",       "Midday check-in.",        "What's one thing that's been quietly good so far?"),
            18: ("sun.horizon",   "The day is winding down.","What moment deserves to be remembered?"),
            21: ("moon.stars",    "Evening stillness.",      "How do you want to close today?"),
        ]

        let matchHour = prompts.keys.sorted().last { $0 <= hour } ?? 6
        if let (icon, headline, subtext) = prompts[matchHour] {
            return JournalNudge(
                icon: icon,
                headline: headline,
                subtext: subtext,
                action: .suggestPrompt(subtext)
            )
        }

        return nil
    }
}

// MARK: - Nudge Card View

@available(iOS 26.0, *)
struct NudgeCard: View {
    let nudge: JournalNudge
    let onDismiss: () -> Void
    let onTap: (JournalNudge.NudgeAction) -> Void

    @State private var appeared = false

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(EtherealTheme.elevatedSurface)
                    .frame(width: 36, height: 36)
                Image(systemName: nudge.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(EtherealTheme.secondary)
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(nudge.headline)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(EtherealTheme.textMain)
                Text(nudge.subtext)
                    .font(.caption)
                    .foregroundStyle(EtherealTheme.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 4)

            // Dismiss
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(EtherealTheme.tertiaryText)
                    .padding(6)
                    .background(EtherealTheme.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(EtherealTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(EtherealTheme.divider, lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        .scaleEffect(appeared ? 1 : 0.95)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75).delay(0.1)) {
                appeared = true
            }
        }
        .onTapGesture {
            onTap(nudge.action)
        }
    }
}
