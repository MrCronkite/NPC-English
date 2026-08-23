//
//  QuizView.swift
//  CombineApp
//
//  Created by Влад Шимченко on 27.07.2026.
//


import SwiftUI

import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel: QuizViewModel
    @Environment(\.dismiss) private var dismiss

    init(wordSet: WordSet, category: WordCategory? = nil, favoritesManager: FavoritesManaging, statsManager: StatsManaging, speechManager: SpeechSynthesizing, progressTracker: WordProgressTracking) {
        _viewModel = StateObject(wrappedValue: QuizViewModel(wordSet: wordSet, category: category, favoritesManager: favoritesManager, statsManager: statsManager, speechManager: speechManager, progressTracker: progressTracker))
    }

    init(favoritesManager: FavoritesManaging, statsManager: StatsManaging, speechManager: SpeechSynthesizing, progressTracker: WordProgressTracking) {
        _viewModel = StateObject(wrappedValue: QuizViewModel(favoritesManager: favoritesManager, statsManager: statsManager, speechManager: speechManager, progressTracker: progressTracker))
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

            progressRing

            if viewModel.currentWord != nil {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Text(viewModel.questionText)
                            .font(.system(size: 40, weight: .heavy))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.4)
                            .fixedSize(horizontal: false, vertical: true)

                        if viewModel.isQuestionInEnglish {
                            Button {
                                viewModel.speakCurrentWord()
                            } label: {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }

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

                VStack(spacing: 12) {
                    ForEach(viewModel.options) { option in
                        optionRow(for: option)
                    }
                }
                .padding(.horizontal)
            } else {
                Spacer()
                Text("Недостаточно слов в этом наборе")
                    .foregroundStyle(.secondary)
                    .padding()
                Spacer()
            }

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
        .animation(.easeInOut(duration: 0.2), value: viewModel.isAnswered)
        .navigationBarHidden(true)
    }

    // MARK: - Header (close, linear progress, settings)

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

    // MARK: - Circular progress + score ring

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 10)

            Circle()
                .trim(from: 0, to: viewModel.plannedQuestions > 0 ? Double(viewModel.total) / Double(viewModel.plannedQuestions) : 0)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: viewModel.total)

            VStack(spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(viewModel.total)")
                        .font(.system(size: 42, weight: .heavy))
                    Text("/\(viewModel.plannedQuestions)")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.yellow)
                    Text("\(viewModel.score)")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: 140, height: 140)
    }

    // MARK: - Option row

    private func optionRow(for option: Word) -> some View {
        let isSelected = viewModel.selectedOption?.id == option.id
        let isCorrectOption = option.id == viewModel.currentWord?.id

        return Button {
            viewModel.select(option)
        } label: {
            HStack {
                Text(viewModel.optionText(for: option))
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)

                Spacer()

                statusIcon(isSelected: isSelected, isCorrectOption: isCorrectOption)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(rowBackground(isSelected: isSelected, isCorrectOption: isCorrectOption))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(rowBorderColor(isSelected: isSelected, isCorrectOption: isCorrectOption), lineWidth: 2.5)
            )
        }
        .disabled(viewModel.isAnswered)
    }

    @ViewBuilder
    private func statusIcon(isSelected: Bool, isCorrectOption: Bool) -> some View {
        if viewModel.isAnswered && isCorrectOption {
            Image(systemName: "checkmark")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(Color.green)
                .clipShape(Circle())
        } else if viewModel.isAnswered && isSelected {
            Image(systemName: "xmark")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(Color.red)
                .clipShape(Circle())
        } else {
            Circle()
                .stroke(Color(.systemGray4), lineWidth: 1.5)
                .frame(width: 26, height: 26)
        }
    }

    private func rowBackground(isSelected: Bool, isCorrectOption: Bool) -> Color {
        guard viewModel.isAnswered else { return Color(.secondarySystemGroupedBackground) }

        if isCorrectOption {
            return Color.green.opacity(0.18)
        } else if isSelected {
            return Color.red.opacity(0.18)
        }
        return Color(.secondarySystemGroupedBackground)
    }

    private func rowBorderColor(isSelected: Bool, isCorrectOption: Bool) -> Color {
        guard viewModel.isAnswered else { return Color.clear }

        if isCorrectOption {
            return Color.green
        } else if isSelected {
            return Color.red
        }
        return Color.clear
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
