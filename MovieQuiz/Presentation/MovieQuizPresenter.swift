import UIKit


final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel (
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else {
            return
        }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    var correctAnswers: Int = 0
    private var statisticService: StatisticServiceProtocol = StatisticService()
    var questionFactory: QuestionFactoryProtocol?
    func showNextQuestionOrResults() {
        if self.isLastQuestion() { // в состояние "Результат квиза"
            let currentGame = GameResult(correct: correctAnswers, total: self.questionsAmount, date: Date())
            statisticService.store(currentGame)
            
            let gamesCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let totalAccuracy = "\(String(format: "%.2f", statisticService.totalAccuracy))%"
            let bestGameDate = bestGame.date.dateTimeString
            
            let resultText = """
               Ваш результат: \(correctAnswers)/\(self.questionsAmount)
               Количество сыгранных квизов: \(gamesCount)
               Рекорд: \(bestGame.correct)/\(bestGame.total) ( \(bestGameDate) )
               Средняя точность: \(totalAccuracy)
               """
            
            let viewModelAlert = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: resultText,
                buttonText: "Сыграть еще раз")
            
                viewController?.showResult(quiz: viewModelAlert)
        } else { // в состояние "Вопрос показан"
            self.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
    }
}
