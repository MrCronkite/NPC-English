//
//  SupportView.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 03.08.2026.
//

import SwiftUI


private struct SupportOption: Identifiable {
    let id = UUID()
    let title: String
    let emoji: String
    let price: String
}


struct SupportView: View {
    private let supportOptions = [
        SupportOption(title: "Маленькое спасибо", emoji: "☕️", price: "$0.99"),
        SupportOption(title: "Хорошая поддержка", emoji: "🍰", price: "$2.99"),
        SupportOption(title: "Щедрый жест", emoji: "🎁", price: "$4.99")
    ]

    @State private var selectedOption: SupportOption?

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                header

                VStack(spacing: 12) {
                    ForEach(supportOptions) { option in
                        supportButton(option)
                    }
                }
                .padding(.horizontal)

                footer
            }
            .padding(.vertical, 24)
        }
        .navigationTitle("Поддержать проект")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 48))
                .foregroundStyle(.red)

            Text("Приложение полностью бесплатное")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)

            Text("Все функции приложения доступны бесплатно и без ограничений — сейчас и в будущем. Если приложение помогает тебе учить английский и ты хочешь поддержать его развитие, можешь угостить разработчика чашкой кофе ☕️ \nЭто полностью добровольно и никак не влияет на возможности приложения. Спасибо за поддержку! ❤️")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    private func supportButton(_ option: SupportOption) -> some View {
        Button {
            selectedOption = option
            // TODO: интеграция с StoreKit / In-App Purchase, когда решишь её добавить
        } label: {
            HStack {
                Text(option.emoji)
                    .font(.title2)

                Text(option.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)

                Spacer()

                Text(option.price)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var footer: some View {
        Text("Спасибо, что учишь английский вместе с нами! ✨")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.top, 8)
    }
}

