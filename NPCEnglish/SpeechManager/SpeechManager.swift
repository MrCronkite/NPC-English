//
//  SpeechManager.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 04.08.2026.
//

import Foundation
import AVFoundation


protocol SpeechSynthesizing {
    func speak(_ text: String)
}

final class SpeechManager: SpeechSynthesizing {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {
        guard !text.isEmpty else { return }

        // Останавливаем предыдущую фразу, если она ещё звучит — иначе быстрые повторные тапы
        // будут накладываться друг на друга.
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: accentLanguageCode)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.95 // чуть медленнее для разборчивости

        synthesizer.speak(utterance)
    }

    private var accentLanguageCode: String {
        UserDefaults.standard.string(forKey: "speechAccent") ?? "en-US"
    }
}

/// Для превью и тестов — ничего не произносит, просто фиксирует вызов
final class MockSpeechManager: SpeechSynthesizing {
    private(set) var lastSpokenText: String?

    func speak(_ text: String) {
        lastSpokenText = text
    }
}
