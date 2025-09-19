import SwiftUI
import Foundation

struct GameStatistics: Codable {
    let gameType: GameType
    let gameMode: GameMode
    
    var bestScore: Int = 0
    var bestTime: TimeInterval = 0
    var bestExtraStat: Int = 0
    var worstTime: TimeInterval = 0
    
    var firstPlayDate: Date?
    var latestPlayDate: Date?
    
    var totalGamesPlayed: Int = 0
    
    var bestGameStats: GameStats?
    
    init(gameType: GameType, gameMode: GameMode) {
        self.gameType = gameType
        self.gameMode = gameMode
    }
    
    mutating func updateWithNewGame(_ gameStats: GameStats) {
        totalGamesPlayed += 1
        
        if firstPlayDate == nil {
            firstPlayDate = gameStats.date
        }
        latestPlayDate = gameStats.date
        
        if gameStats.score > bestScore {
            bestScore = gameStats.score
        }
        
        if gameStats.timeTaken < bestTime || bestTime == 0 {
            bestTime = gameStats.timeTaken
        }
        
        if gameStats.timeTaken > worstTime {
            worstTime = gameStats.timeTaken
        }
        
        if gameStats.extraStat > bestExtraStat {
            bestExtraStat = gameStats.extraStat
        }
        
        if bestGameStats == nil || 
           gameStats.score > bestGameStats!.score || 
           (gameStats.score == bestGameStats!.score && gameStats.timeTaken < bestGameStats!.timeTaken) {
            bestGameStats = gameStats
        }
    }
}

class GameStatisticsManager: ObservableObject {
    static let shared = GameStatisticsManager()
    private let userDefaults = UserDefaults.standard
    
    private var statistics: [String: GameStatistics] = [:]
    
    private init() {
        loadStatistics()
    }
    
    private func getKey(for gameType: GameType, mode: GameMode) -> String {
        return "\(gameType.rawValue)_\(mode.rawValue)_stats"
    }
    
    private func loadStatistics() {
        let allKeys = userDefaults.dictionaryRepresentation().keys
        let statsKeys = allKeys.filter { $0.hasSuffix("_stats") }
        
        for key in statsKeys {
            if let data = userDefaults.data(forKey: key),
               let stats = try? JSONDecoder().decode(GameStatistics.self, from: data) {
                statistics[key] = stats
            }
        }
    }
    
    // save stats to user default
    private func saveStatistics(_ stats: GameStatistics) {
        let key = getKey(for: stats.gameType, mode: stats.gameMode)
        if let data = try? JSONEncoder().encode(stats) {
            userDefaults.set(data, forKey: key)
        }
    }
    
    // Record a new game and update statistics
    func recordGame(_ gameStats: GameStats) {
        let key = getKey(for: gameStats.gameType, mode: gameStats.gameMode)
        
        if var existingStats = statistics[key] {
            existingStats.updateWithNewGame(gameStats)
            statistics[key] = existingStats
        } else {
            var newStats = GameStatistics(gameType: gameStats.gameType, gameMode: gameStats.gameMode)
            newStats.updateWithNewGame(gameStats)
            statistics[key] = newStats
        }
        
        saveStatistics(statistics[key]!)
    }
    
    func getStatistics(for gameType: GameType, mode: GameMode) -> GameStatistics? {
        let key = getKey(for: gameType, mode: mode)
        return statistics[key]
    }
    
    func getBestScore(for gameType: GameType, mode: GameMode) -> Int {
        return getStatistics(for: gameType, mode: mode)?.bestScore ?? 0
    }
    
    func getBestTime(for gameType: GameType, mode: GameMode) -> TimeInterval {
        return getStatistics(for: gameType, mode: mode)?.bestTime ?? 0
    }
    
    func getTotalGamesPlayed(for gameType: GameType, mode: GameMode) -> Int {
        return getStatistics(for: gameType, mode: mode)?.totalGamesPlayed ?? 0
    }
    
    func clearAllStatistics() {
        let allKeys = userDefaults.dictionaryRepresentation().keys
        let statsKeys = allKeys.filter { $0.hasSuffix("_stats") }
        
        for key in statsKeys {
            userDefaults.removeObject(forKey: key)
        }
        
        statistics.removeAll()
        print("🗑️ All game statistics cleared")
    }
    
    func printAllStatistics() {
        //print("📊 ALL GAME STATISTICS:")
    }
}
