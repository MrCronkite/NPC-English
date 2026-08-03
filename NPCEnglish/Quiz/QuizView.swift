//
//  QuizView.swift
//  CombineApp
//
//  Created by Влад Шимченко on 27.07.2026.
//


import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel: QuizViewModel

    init(
        wordSet: WordSet,
        category: WordCategory? = nil,
        favoritesManager: FavoritesManaging,
        statsManager: StatsManaging
    ) {
        _viewModel = StateObject(
            wrappedValue: QuizViewModel(
                wordSet: wordSet,
                category: category,
                favoritesManager: favoritesManager,
                statsManager: statsManager
            )
        )
    }

    init(
        favoritesManager: FavoritesManaging,
        statsManager: StatsManaging
    ) {
        _viewModel = StateObject(
            wrappedValue: QuizViewModel(
                favoritesManager: favoritesManager,
                statsManager: statsManager
            )
        )
    }

    var body: some View {
        if viewModel.isSessionFinished {
            sessionResultView
        } else {
            quizContent
        }
    }
}

extension QuizView {
    private var sessionResultView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            Text("Сессия завершена!")
                .font(.title.bold())
            Text("Результат: \(viewModel.score)/\(viewModel.total)")
                .font(.title2)
                .foregroundStyle(.secondary)
            Spacer()
            Button(action: viewModel.restartSession) {
                Text("Начать заново")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .navigationTitle(viewModel.wordSet.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension QuizView {
    private var quizContent: some View {
        VStack(spacing: 32) {
            header

            Spacer()

            Text(viewModel.questionText)
                .font(.system(size: 40, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 14) {
                ForEach(viewModel.options) { option in
                    optionButton(for: option)
                }
            }
            .padding(.horizontal)

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
        .toolbar {
            if viewModel.currentWord != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.toggleFavorite()
                    } label: {
                        Image(systemName: viewModel.isCurrentFavorite
                              ? "heart.fill"
                              : "heart"
                        )
                        .foregroundStyle(.red)
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            HStack {
                Label {
                    Text("\(viewModel.score) / \(viewModel.total)")
                        .font(.subheadline.weight(.semibold))
                } icon: {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                }

                Spacer()

                if viewModel.isLimited {
                    Text("\(viewModel.total)/\(viewModel.plannedQuestions)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }

            if viewModel.isLimited {
                ProgressView(value: Double(viewModel.total), total: Double(viewModel.plannedQuestions))
                    .tint(.accentColor)
            }
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
            Text(viewModel.optionText(for: option))
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

