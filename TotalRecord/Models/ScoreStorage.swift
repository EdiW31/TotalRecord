import SwiftUI
import Foundation


class ScoreStorage: ObservableObject{
    static let shared = ScoreStorage()
    private let userDefaults = UserDefaults.standard

    func saveScore(_ stats: GameStats){
        let key = "\(stats.gameType.rawValue)_\(stats.gameMode.rawValue)_best"
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(stats){
            userDefaults.set(encoded, forKey: key)
        }
    }
    func setBestScore(for gameType: GameType, mode: GameMode, score: Int){
        let key = "\(gameType.rawValue)_\(mode.rawValue)_best"
        let currentBest = getBestScore(for: gameType, mode: mode)
        if score > currentBest {
            let stats = GameStats(score: score, timeTaken: 0, extraStat: 0, gameMode: mode, gameType: gameType, date: Date())
            saveScore(stats)
        }
    }
    func setBestTime(for gameType: GameType, mode: GameMode, time: TimeInterval){
        let key = "\(gameType.rawValue)_\(mode.rawValue)_best"
        let currentBest = getBestTime(for: gameType, mode: mode)
        if time < currentBest || currentBest == 0 {
            let stats = GameStats(score: 0, timeTaken: time, extraStat: 0, gameMode: mode, gameType: gameType, date: Date())
            saveScore(stats)
        }
    }
    
    // GET functions

    private func getSavedStats(for gameType: GameType, mode: GameMode) -> GameStats? {
        let key = "\(gameType.rawValue)_\(mode.rawValue)_best"
        let decoder = JSONDecoder()
        if let savedStats = userDefaults.data(forKey: key) {
            if let decodedStats = try? decoder.decode(GameStats.self, from: savedStats) {
                return decodedStats
            }
        }
        return nil
    }
    func getBestScore(for gameType: GameType, mode: GameMode) -> Int {
        return getSavedStats(for: gameType, mode: mode)?.score ?? 0
    }
    func getBestTime(for gameType: GameType, mode: GameMode) -> TimeInterval {
        return getSavedStats(for: gameType, mode: mode)?.timeTaken ?? 0
    }
    func getBestExtraStat(for gameType: GameType, mode: GameMode) -> Int {
        return getSavedStats(for: gameType, mode: mode)?.extraStat ?? 0
    }
}