import Foundation


final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correctAnswers
        case questionsCount
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
    }
    
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set{
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    
    private var questionsCount: Int {
        get {
            storage.integer(forKey: Keys.questionsCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.questionsCount.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey:  Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            guard gamesCount > 0 else {
                return 0
            }
            return Double(correctAnswers) / Double(questionsCount) * 100.0
        }
    }
    
    func store(_ currentGame: GameResult) {
        correctAnswers += currentGame.correct
        questionsCount += currentGame.total
        gamesCount += 1
        
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
    }
}
