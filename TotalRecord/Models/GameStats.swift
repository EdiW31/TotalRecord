import SwiftUI

struct GameStats: Codable {
    let score: Int
    let timeTaken: TimeInterval
    let extraStat: Int
    let gameMode: GameMode
    let gameType: GameType
    let date: Date
    
    init(score: Int, timeTaken: TimeInterval, extraStat: Int, gameMode: GameMode, gameType: GameType, date: Date = Date()) {
        self.score = score
        self.timeTaken = timeTaken
        self.extraStat = extraStat
        self.gameMode = gameMode
        self.gameType = gameType
        self.date = date
    }
}

