import UIKit


final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var statisticService: StatisticServiceProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - private functions
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else {
            return
        }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }

    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() { // в состояние "Результат квиза"
            guard let statisticService else {return}
            let currentGame = GameResult(correct: self.correctAnswers, total: self.questionsAmount, date: Date())
            statisticService.store(currentGame)
            
            let gamesCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let totalAccuracy = "\(String(format: "%.2f", statisticService.totalAccuracy))%"
            let bestGameDate = bestGame.date.dateTimeString
            
            let resultText = """
               Ваш результат: \(self.correctAnswers)/\(self.questionsAmount)
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
    // MARK: - QuestionFactoryDelegate
    func didLoadDataFromServer() {
           viewController?.hideLoadingIndicator()
           questionFactory?.requestNextQuestion()
       }
       
    func didFailToLoadData(with error: Error) {
       let message = error.localizedDescription
       viewController?.showNetworkError(message: message)
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
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
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
}
