//
//  HeaderBar.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-03-25.
//
import SwiftUI


struct HeaderBar: View {
    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
                .font(.title2)
                .foregroundColor(EtherealTheme.primary)
            
            Text("The Mindful Prism")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(EtherealTheme.primary)
                .padding(.leading, 8)
            
            Spacer()
            
            Image("profile_placeholder") // Replace with actual image
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .background(Color.gray.opacity(0.3))
                .clipShape(Circle())
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(EtherealTheme.background)
    }
}

struct InsightCard: View {
    let icon: String
    let category: String
    let title: String
    let detail: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color)
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .foregroundColor(EtherealTheme.primary)
                }
                
                Spacer()
                
                Text(category)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundColor(EtherealTheme.textSecondary.opacity(0.6))
            }
            
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(EtherealTheme.primary)
            
            Text(detail)
                .font(.system(size: 15))
                .foregroundColor(EtherealTheme.textSecondary)
                .lineSpacing(4)
        }
        .padding(24)
        .background(EtherealTheme.background)
        .cornerRadius(28)
    }
}


struct WeeklyFlowView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Weekly Reflection Flow")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                Text("5 / 7 Days")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(EtherealTheme.primary)
            }
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(EtherealTheme.divider)
                    .frame(height: 10)
                
                Capsule()
                    .fill(LinearGradient(colors: [.blue.opacity(0.3), EtherealTheme.primary], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 250, height: 10)
            }
        }
        .padding(.vertical)
    }
}

struct CustomTabBar: View {
    var body: some View {
        HStack(spacing: 0) {
            TabItem(icon: "square.and.pencil", label: "JOURNAL", isActive: true)
            TabItem(icon: "sparkles", label: "INSIGHTS", isActive: false)
            TabItem(icon: "book.closed", label: "LIBRARY", isActive: false)
            TabItem(icon: "gearshape", label: "SETTINGS", isActive: false)
        }
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(35)
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}
