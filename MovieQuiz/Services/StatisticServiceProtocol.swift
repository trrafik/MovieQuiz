import Foundation


protocol StatisticServiceProtocol {
    var gamesCount: Int {get}
    var bestGame: GameResult {get}
    var totalAccuracy: Double {get}
    
    func store(_ currentGame: GameResult)
}
