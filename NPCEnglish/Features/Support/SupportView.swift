//
//  SupportView.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 03.08.2026.
//

import SwiftUI

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss

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

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.12))
                            .frame(width: 100, height: 100)

                        Image(systemName: "heart.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.red)
                    }

                    Text("Приложение полностью бесплатное")
                        .font(.title3.weight(.bold))
                        .multilineTextAlignment(.center)

                    Text("Все функции доступны без ограничений и всегда будут такими. Если приложение оказалось полезным — можешь угостить разработчика чашкой кофе. Это ни на что не влияет и совершенно необязательно 🙂")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }
                .padding(.top, 8)

                VStack(spacing: 12) {
                    ForEach(supportOptions) { option in
                        supportRow(option)
                    }
                }
                .padding(.horizontal)

                Text("Спасибо, что учишь английский вместе с нами! ✨")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack(spacing: 16) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(Circle())
            }

            Text("Поддержать проект")
                .font(.largeTitle.bold())

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }

    private func supportRow(_ option: SupportOption) -> some View {
        let isSelected = selectedOption?.id == option.id

        return Button {
            selectedOption = option
            // TODO: интеграция с StoreKit / In-App Purchase
        } label: {
            HStack(spacing: 16) {
                Text(option.emoji)
                    .font(.system(size: 32))
                    .frame(width: 52, height: 52)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                Text(option.title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer()

                Text(option.price)
                    .font(.body.weight(.bold))
                    .foregroundStyle(Color.accentColor)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct SupportOption: Identifiable {
    let id = UUID()
    let title: String
    let emoji: String
    let price: String
}

#Preview {
    SupportView()
}
