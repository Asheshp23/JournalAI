//
//  BookshelfView.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-03.
//
import SwiftUI

@available(iOS 26.0, *)
struct BookshelfView: View {
    let entries: [FormattedJournalEntry]
    let onSelect: (FormattedJournalEntry) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Past Chapters")
                    .font(.system(.largeTitle, design: .serif))
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                LazyVGrid(columns: columns, spacing: 25) {
                    ForEach(entries) { entry in
                        BookSpineCard(entry: entry)
                        .onTapGesture {

                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 30)
        }
        .background(EtherealTheme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Individual Book Spine
@available(iOS 26.0, *)
struct BookSpineCard: View {
    let entry: FormattedJournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // The "Cover" Preview
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(EtherealTheme.surface)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                
                // If there's an image, show a tiny preview
                if let imageData = entry.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 140)
                        .clipped()
                        .opacity(0.4)
                } else {
                    // Geometric abstract pattern for empty images
                    Circle()
                        .stroke(EtherealTheme.primary.opacity(0.1), lineWidth: 1)
                        .frame(width: 100)
                        .offset(x: 40, y: 40)
                }
                
                // Small Date Badge
                Text(entry.displayDate)
                    .font(.system(size: 10, weight: .bold))
                    .padding(6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(10)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Title Below
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.heroTitle)
                    .font(.system(.subheadline, design: .serif))
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                Text(entry.supportingInsight)
                    .font(.caption2)
                    .foregroundStyle(EtherealTheme.textSecondary)
                    .lineLimit(2)
            }
            .padding(.horizontal, 4)
        }
    }
}
