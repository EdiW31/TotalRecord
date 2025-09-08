import SwiftUI

import Foundation

class ScoreStorage: ObservableObject{
    static let shared = ScoreStorage()
    private let userDefaults = UserDefaults.standard

    func saveScore(_ stats: GameStats){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(stats){
            userDefaults.set(encoded, forKey: "gameStats")
        }
    }

    func getBestScore(for gameType: GameType, mode: GameMode) -> Int{
        let decoder = JSONDecoder()
        if let savedStats = userDefaults.data(forKey: "gameStats"){
            if let decodedStats = try? decoder.decode(GameStats.self, from: savedStats){
                return decodedStats.score
            }
        }
        return 0
    }

    func getBestTime(for gameType: GameType, mode: GameMode) -> TimeInterval{
        let decoder = JSONDecoder()
        if let savedStats = userDefaults.data(forKey: "gameStats"){
            if let decodedStats = try? decoder.decode(GameStats.self, from: savedStats){
                return decodedStats.timeTaken
            }
        }
        return 0
    }

    func getBestExtraStat(for gameType: GameType, mode: GameMode) -> Int{
        let decoder = JSONDecoder()
        if let savedStats = userDefaults.data(forKey: "gameStats"){
            if let decodedStats = try? decoder.decode(GameStats.self, from: savedStats){
                return decodedStats.extraStat
            }
        }
        return 0
    }
}