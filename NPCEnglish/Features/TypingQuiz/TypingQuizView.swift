//
//  TypingQuizView.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 12.08.2026.
//

import SwiftUI

struct TypingQuizView: View {
    @StateObject private var viewModel: TypingQuizViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputFocused: Bool

    init(wordSet: WordSet, category: WordCategory? = nil, favoritesManager: FavoritesManaging, statsManager: StatsManaging, progressTracker: WordProgressTracking) {
        _viewModel = StateObject(wrappedValue: TypingQuizViewModel(wordSet: wordSet, category: category, favoritesManager: favoritesManager, statsManager: statsManager, progressTracker: progressTracker))
    }

    var body: some View {
        if viewModel.isSessionFinished {
            sessionResultView
        } else {
            quizContent
        }
    }

    // MARK: - Quiz content

    private var quizContent: some View {
        VStack(spacing: 32) {
            header

            ScrollView {
                VStack(spacing: 32) {
                    progressRing

                    if viewModel.currentWord != nil {
                        VStack(spacing: 12) {
                            Text(viewModel.questionText)
                                .font(.system(size: 40, weight: .heavy))
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                                .minimumScaleFactor(0.4)
                                .fixedSize(horizontal: false, vertical: true)

                            if viewModel.isCurrentWordReview {
                                Label("Повторение", systemImage: "arrow.clockwise")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.orange)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)

                        Spacer()

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
                                .padding(.vertical, 18)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.secondarySystemGroupedBackground))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(borderColor, lineWidth: 2)
                                )
                                .animation(.easeInOut(duration: 0.2), value: viewModel.isAnswered)
                                .animation(.easeInOut(duration: 0.2), value: isInputFocused)

                            if viewModel.isAnswered {
                                feedbackView
                            } else {
                                HStack(spacing: 12) {
                                    Button {
                                        viewModel.revealAnswer()
                                    } label: {
                                        Label("Не знаю", systemImage: "questionmark.circle")
                                            .font(.subheadline.weight(.semibold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                    }
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .foregroundStyle(.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))

                                    Button {
                                        viewModel.submitAnswer()
                                    } label: {
                                        Label("Проверить", systemImage: "checkmark.circle")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                    }
                                    .background(viewModel.userInput.trimmingCharacters(in: .whitespaces).isEmpty ? Color(.systemGray4) : Color.accentColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .disabled(viewModel.userInput.trimmingCharacters(in: .whitespaces).isEmpty)
                                }
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        Spacer()
                        Text("Недостаточно слов в этом наборе")
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
                .padding(.top, 16)
            }
            .scrollDismissesKeyboard(.interactively)

            Button(action: viewModel.nextQuestion) {
                Text("Дальше")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(viewModel.isAnswered ? Color.accentColor : Color(.systemGray4))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(!viewModel.isAnswered)
            .padding(.horizontal)
        }
        .padding(.top, 16)
        .padding(.bottom, 24)
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 16) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                viewModel.toggleFavorite()
            } label: {
                Image(systemName: viewModel.isCurrentFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.red)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Progress ring

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 8)

            Circle()
                .trim(from: 0, to: viewModel.plannedQuestions > 0 ? Double(viewModel.total) / Double(viewModel.plannedQuestions) : 0)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: viewModel.total)

            VStack(spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(viewModel.total)")
                        .font(.system(size: 28, weight: .heavy))
                    Text("/\(viewModel.plannedQuestions)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.yellow)
                    Text("\(viewModel.score)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: 140, height: 140)
    }

    // MARK: - Feedback

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
    }

    private var borderColor: Color {
        if viewModel.isAnswered {
            return viewModel.wasCorrect ? .green : .red
        }
        return isInputFocused ? Color.accentColor : Color.clear
    }

    // MARK: - Session result

    private var sessionResultView: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)

            Spacer()

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 140, height: 140)

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.green)
            }

            VStack(spacing: 8) {
                Text("Сессия завершена!")
                    .font(.title.bold())

                Text("Отличная работа")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 24)

            HStack(spacing: 16) {
                resultStat(icon: "star.fill", color: .yellow, value: "\(viewModel.score)", label: "Правильно")
                resultStat(icon: "list.bullet", color: .blue, value: "\(viewModel.total)", label: "Всего")
                resultStat(icon: "percent", color: .green, value: accuracyText, label: "Точность")
            }
            .padding(.top, 32)
            .padding(.horizontal)

            Spacer()

            Button(action: viewModel.restartSession) {
                Text("Начать заново")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }

    private var accuracyText: String {
        guard viewModel.total > 0 else { return "0%" }
        let percent = Int((Double(viewModel.score) / Double(viewModel.total)) * 100)
        return "\(percent)%"
    }

    private func resultStat(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
