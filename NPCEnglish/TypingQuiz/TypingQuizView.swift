//
//  TypingQuizView.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 12.08.2026.
//

import SwiftUI

struct TypingQuizView: View {
    @StateObject private var viewModel: TypingQuizViewModel
    @FocusState private var isInputFocused: Bool

    init(wordSet: WordSet, category: WordCategory? = nil, favoritesManager: FavoritesManaging, statsManager: StatsManaging) {
        _viewModel = StateObject(wrappedValue: TypingQuizViewModel(wordSet: wordSet, category: category, favoritesManager: favoritesManager, statsManager: statsManager))
    }

    var body: some View {
        if viewModel.isSessionFinished {
            sessionResultView
        } else {
            quizContent
        }
    }

    private var quizContent: some View {
        VStack(spacing: 32) {
            header

            Spacer()

            if let word = viewModel.currentWord {
                Text(viewModel.questionText)
                    .font(.system(size: 40, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 16) {
                    TextField("Введи перевод", text: $viewModel.userInput)
                        .font(.title2.weight(.medium))
                        .multilineTextAlignment(.center)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .disabled(viewModel.isAnswered)
                        .focused($isInputFocused)
                        .onSubmit {
                            viewModel.submitAnswer()
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.secondarySystemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(borderColor, lineWidth: 2)
                        )
                        .padding(.horizontal)

                    if viewModel.isAnswered {
                        feedbackView
                    } else {
                        HStack(spacing: 12) {
                            Button("Не знаю") {
                                viewModel.revealAnswer()
                            }
                            .buttonStyle(.bordered)

                            Button("Проверить") {
                                viewModel.submitAnswer()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(viewModel.userInput.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        .padding(.horizontal)
                    }
                }
                .onChange(of: word) { _, _ in
                    isInputFocused = true
                }
                .onAppear {
                    isInputFocused = true
                }
            } else {
                Text("Недостаточно слов в этом наборе")
                    .foregroundStyle(.secondary)
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
            }
        }
        .padding(.vertical)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isAnswered)
        .animation(.easeInOut(duration: 0.2), value: isInputFocused)
        .navigationTitle("\(viewModel.wordSet.title) · Напиши перевод")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var feedbackView: some View {
        VStack(spacing: 8) {
            Label(
                viewModel.wasCorrect ? "Верно!" : "Неверно",
                systemImage: viewModel.wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
            )
            .font(.headline)
            .foregroundStyle(viewModel.wasCorrect ? .green : .red)

            if !viewModel.wasCorrect {
                Text("Правильный ответ: \(viewModel.correctAnswerText)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal)
    }

    private var header: some View {
        HStack {
            Text("\(viewModel.score) / \(viewModel.total)")
                .font(.subheadline.weight(.semibold))
            Spacer()
            Text("\(viewModel.total)/\(viewModel.plannedQuestions)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

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

    private var borderColor: Color {
        if viewModel.isAnswered {
            return viewModel.wasCorrect ? .green : .red
        }
        return isInputFocused ? Color.accentColor : Color.clear
    }
}
