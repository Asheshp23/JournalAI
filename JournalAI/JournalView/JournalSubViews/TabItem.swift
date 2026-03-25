//
//  TabItem.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-03-25.
//
import SwiftUI

struct TabItem: View {
    let icon: String
    let label: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
            Text(label)
                .font(.system(size: 10, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(isActive ? EtherealTheme.primary : Color.clear)
        .foregroundColor(isActive ? .white : EtherealTheme.textSecondary.opacity(0.6))
        .cornerRadius(20)
        .padding(.horizontal, 6)
    }
}
