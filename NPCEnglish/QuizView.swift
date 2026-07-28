//
//  QuizView.swift
//  CombineApp
//
//  Created by Влад Шимченко on 27.07.2026.
//


import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel: QuizViewModel

    init(wordSet: WordSet) {
        _viewModel = StateObject(wrappedValue: QuizViewModel(wordSet: wordSet))
    }

    var body: some View {
        VStack(spacing: 32) {
            header

            Spacer()

            if let word = viewModel.currentWord {
                Text(word.english)
                    .font(.system(size: 40, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 14) {
                    ForEach(viewModel.options) { option in
                        optionButton(for: option)
                    }
                }
                .padding(.horizontal)
            } else {
                Text("Недостаточно слов в словаре (нужно минимум 4)")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            Spacer()

            if viewModel.isAnswered {
                Button(action: viewModel.nextQuestion) {
                    Text("Дальше")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)
                .transition(.opacity)
            }
        }
        .padding(.vertical)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isAnswered)
        .navigationTitle(viewModel.wordSet.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack {
            Text("Счёт: \(viewModel.score)/\(viewModel.total)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func optionButton(for option: Word) -> some View {
        let isSelected = viewModel.selectedOption?.id == option.id
        let isCorrectOption = option.id == viewModel.currentWord?.id

        Button {
            viewModel.select(option)
        } label: {
            Text(option.translation)
                .font(.body.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor(isSelected: isSelected, isCorrectOption: isCorrectOption))
                .foregroundStyle(foregroundColor(isSelected: isSelected, isCorrectOption: isCorrectOption))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                )
        }
        .disabled(viewModel.isAnswered)
    }

    private func backgroundColor(isSelected: Bool, isCorrectOption: Bool) -> Color {
        guard viewModel.isAnswered else { return Color(.secondarySystemBackground) }

        if isCorrectOption {
            return Color.green.opacity(0.85)
        } else if isSelected {
            return Color.red.opacity(0.85)
        } else {
            return Color(.secondarySystemBackground)
        }
    }

    private func foregroundColor(isSelected: Bool, isCorrectOption: Bool) -> Color {
        guard viewModel.isAnswered else { return .primary }
        return (isCorrectOption || isSelected) ? .white : .primary
    }
}

