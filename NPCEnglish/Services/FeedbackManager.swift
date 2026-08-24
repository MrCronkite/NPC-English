//
//  FeedbackManager.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 28.07.2026.
//

import AudioToolbox
import UIKit


enum FeedbackManager {
    private static let correctSoundID: SystemSoundID = 1035
    private static let incorrectSoundID: SystemSoundID = 1053

    static func playCorrect() {
        if UserDefaults.standard.bool(forKey: "soundEnabled") {
            AudioServicesPlaySystemSound(correctSoundID)
        }
        if UserDefaults.standard.object(forKey: "hapticsEnabled") == nil || UserDefaults.standard.bool(forKey: "hapticsEnabled") {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    static func playIncorrect() {
        if UserDefaults.standard.bool(forKey: "soundEnabled") {
            AudioServicesPlaySystemSound(incorrectSoundID)
        }
        if UserDefaults.standard.object(forKey: "hapticsEnabled") == nil || UserDefaults.standard.bool(forKey: "hapticsEnabled") {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}
