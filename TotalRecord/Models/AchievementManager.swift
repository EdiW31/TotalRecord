import SwiftUI

class AchievementManager {
    static let shared = AchievementManager()

    @Published var currentRoom: TrophyRoom?
    @Published var achievements: [Achievement] = []

    func trackGameCompletion(gameType: GameType, score: Int, timeTaken: TimeInterval, accuracy: Double, extraStat: Int){
        let achievement = Achievement(gameType: gameType, score: score, timeTaken: timeTaken, accuracy: accuracy, extraStat: extraStat)
    }
}