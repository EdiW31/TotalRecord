import SwiftUI
import Foundation

class ScoreStorage: ObservableObject{
    static let shared = ScoreStorage()
    private let userDefaults = UserDefaults.standard
    
    // Use the new comprehensive statistics system
    private let statisticsManager = GameStatisticsManager.shared

    // Save complete game statistics
    func saveGameStats(_ stats: GameStats) {
        print("💾 SAVING GAME STATS:")
        print("   Game: \(stats.gameType.rawValue) (\(stats.gameMode.rawValue))")
        print("   Score: \(stats.score)")
        print("   Time: \(stats.timeTaken)s")
        print("   Extra Stat: \(stats.extraStat)")
        
        // Record the game in the comprehensive statistics system
        statisticsManager.recordGame(stats)
        
        // Also save individual best records for backward compatibility
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
    
    // Legacy method - now uses comprehensive system
    func setBestScore(for gameType: GameType, mode: GameMode, score: Int){
        // Create a temporary GameStats object for the new system
        let stats = GameStats(score: score, timeTaken: 0, extraStat: 0, gameMode: mode, gameType: gameType, date: Date())
        statisticsManager.recordGame(stats)
    }
    
    // Legacy method - now uses comprehensive system
    func setBestTime(for gameType: GameType, mode: GameMode, time: TimeInterval){
        // Create a temporary GameStats object for the new system
        let stats = GameStats(score: 0, timeTaken: time, extraStat: 0, gameMode: mode, gameType: gameType, date: Date())
        statisticsManager.recordGame(stats)
    }
    
    // GET functions - now use comprehensive system
    
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
    
    // Get best score using comprehensive system
    func getBestScore(for gameType: GameType, mode: GameMode) -> Int {
        return statisticsManager.getBestScore(for: gameType, mode: mode)
    }
    
    // Get best time using comprehensive system
    func getBestTime(for gameType: GameType, mode: GameMode) -> TimeInterval {
        return statisticsManager.getBestTime(for: gameType, mode: mode)
    }
    
    // Get best extra stat using comprehensive system
    func getBestExtraStat(for gameType: GameType, mode: GameMode) -> Int {
        if let stats = statisticsManager.getStatistics(for: gameType, mode: mode) {
            return stats.bestExtraStat
        }
        return 0
    }
    
    // NEW: Get total games played
    func getTotalGamesPlayed(for gameType: GameType, mode: GameMode) -> Int {
        return statisticsManager.getTotalGamesPlayed(for: gameType, mode: mode)
    }
    
    // NEW: Get comprehensive statistics
    func getGameStatistics(for gameType: GameType, mode: GameMode) -> GameStatistics? {
        return statisticsManager.getStatistics(for: gameType, mode: mode)
    }
    
    // NEW: Print all statistics for debugging
    func printAllStatistics() {
        statisticsManager.printAllStatistics()
    }
    
    // NEW: Clear all statistics (for testing)
    func clearAllStatistics() {
        statisticsManager.clearAllStatistics()
    }
    
    // NEW: Test the statistics system
    func testStatisticsSystem() {
        print("🧪 TESTING STATISTICS SYSTEM:")
        
        // Create test game stats
        let testStats1 = GameStats(score: 100, timeTaken: 45.5, extraStat: 5, gameMode: .timed, gameType: .memoryMatch, date: Date())
        let testStats2 = GameStats(score: 150, timeTaken: 35.2, extraStat: 7, gameMode: .timed, gameType: .memoryMatch, date: Date())
        let testStats3 = GameStats(score: 80, timeTaken: 55.1, extraStat: 3, gameMode: .timed, gameType: .memoryMatch, date: Date())
        
        // Save test stats
        saveGameStats(testStats1)
        saveGameStats(testStats2)
        saveGameStats(testStats3)
        
        // Print results
        printAllStatistics()
        
        print("✅ Statistics system test completed!")
    }
}