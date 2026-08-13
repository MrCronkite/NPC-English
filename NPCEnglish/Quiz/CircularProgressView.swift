//
//  CircularProgressView.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 13.08.2026.
//

import SwiftUI

struct CircularProgressView: View {
    let current: Int
    let total: Int
    let score: Int

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(current) / Double(total)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 12)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.accentColor,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)

            VStack(spacing: 2) {
                Text("\(current)/\(total)")
                    .font(.title3.weight(.bold))
                    .contentTransition(.numericText())

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.yellow)

                    Text("\(score)")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: 100, height: 100)
        .animation(.easeInOut(duration: 0.3), value: score)
    }
}

#Preview {
    CircularProgressView(current: 6, total: 10, score: 5)
}
