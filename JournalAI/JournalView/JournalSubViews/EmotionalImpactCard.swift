//
//  EmotionalImpactCard.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-03-25.
//
import SwiftUI

// MARK: - Emotional Impact Card with Logic
struct EmotionalImpactCard: View {
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Spacer()
                Text("EMOTIONAL IMPACT").font(.system(size: 10, weight: .bold)).foregroundColor(.gray)
            }
            
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 8) {
                HStack {
                    Text("TURBULENCE").font(.caption2).bold().foregroundColor(.gray)
                    Spacer()
                    Text("STILLNESS").font(.caption2).bold().foregroundColor(.gray)
                }
                Capsule()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 8)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(EtherealTheme.primary)
                            .frame(width: title.contains("Serene") ? 250 : 100) // Simple logic mapping
                    }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(28)
    }
}

// MARK: - Affirmation Card
struct AffirmationCard: View {
    let text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.seal.fill").foregroundColor(EtherealTheme.primary)
                Text("DAILY AFFIRMATION").font(.caption2).bold().foregroundColor(EtherealTheme.primary)
            }
            Text("\"\(text)\"")
                .font(.system(size: 26, weight: .bold, design: .rounded))
            
            HStack {
                Spacer()
                Button("Save to Library") {}
                    .font(.caption).bold()
                    .padding(.vertical, 8).padding(.horizontal, 16)
                    .background(EtherealTheme.divider)
                    .cornerRadius(12)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(32)
    }
}

// MARK: - Poetic Card
struct PoeticCard: View {
    let text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Poetic Reflection", systemImage: "book.pages")
                .font(.subheadline.bold())
            Text(text)
                .font(.system(size: 19, weight: .medium, design: .serif))
                .italic()
                .lineSpacing(6)
                .foregroundColor(EtherealTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(EtherealTheme.primary.opacity(0.05))
        .cornerRadius(28)
    }
}
