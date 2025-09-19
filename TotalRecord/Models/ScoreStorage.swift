import SwiftUI
import Foundation

class ScoreStorage: ObservableObject{
    static let shared = ScoreStorage()
    private let userDefaults = UserDefaults.standard
    
    private let statisticsManager = GameStatisticsManager.shared

    // Save complete game statistics
    func saveGameStats(_ stats: GameStats) {
        statisticsManager.recordGame(stats)
        
        saveScore(stats)
    }
    
    // Legacy method - now uses comprehensive system
    func saveScore(_ stats: GameStats){
        let key = "\(stats.gameType.rawValue)_\(stats.gameMode.rawValue)_best"
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(stats){
            userDefaults.set(encoded, forKey: key)
        }
    }
    
    func setBestScore(for gameType: GameType, mode: GameMode, score: Int){
        let stats = GameStats(score: score, timeTaken: 0, extraStat: 0, gameMode: mode, gameType: gameType, date: Date())
        statisticsManager.recordGame(stats)
    }
    
    func setBestTime(for gameType: GameType, mode: GameMode, time: TimeInterval){
        // Create a temporary GameStats object for the new system
        let stats = GameStats(score: 0, timeTaken: time, extraStat: 0, gameMode: mode, gameType: gameType, date: Date())
        statisticsManager.recordGame(stats)
    }
    
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
        return statisticsManager.getBestScore(for: gameType, mode: mode)
    }
    
    func getBestTime(for gameType: GameType, mode: GameMode) -> TimeInterval {
        return statisticsManager.getBestTime(for: gameType, mode: mode)
    }
    
    func getBestExtraStat(for gameType: GameType, mode: GameMode) -> Int {
        if let stats = statisticsManager.getStatistics(for: gameType, mode: mode) {
            return stats.bestExtraStat
        }
        return 0
    }
    
    func getTotalGamesPlayed(for gameType: GameType, mode: GameMode) -> Int {
        return statisticsManager.getTotalGamesPlayed(for: gameType, mode: mode)
    }
    
    func getGameStatistics(for gameType: GameType, mode: GameMode) -> GameStatistics? {
        return statisticsManager.getStatistics(for: gameType, mode: mode)
    }
    
    func printAllStatistics() {
        statisticsManager.printAllStatistics()
    }
    
    func clearAllStatistics() {
        statisticsManager.clearAllStatistics()
    }
}