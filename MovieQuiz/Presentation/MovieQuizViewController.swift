import UIKit

final class MovieQuizViewController: UIViewController, 
                                     QuestionFactoryDelegate {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers = 0
    private let presenter = MovieQuizPresenter()
    private var questionFactory: QuestionFactoryProtocol?
    //private var statisticService: StatisticServiceProtocol = StatisticService()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
        questionFactory?.loadData()
        presenter.viewController = self
        
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - @IBAction
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - private func
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
        changeStateButton(isEnabled: true)
    }
    
    // приватный метод, который обрабатывает результат ответа
    func showAnswerResult(isCorrect: Bool) {
        changeStateButton(isEnabled: false)
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }
    
//    // приватный метод, который содержит логику перехода в один из сценариев
//    private func showNextQuestionOrResults() {
//        if presenter.isLastQuestion() { // в состояние "Результат квиза"
//            let currentGame = GameResult(correct: correctAnswers, total: presenter.questionsAmount, date: Date())
//            statisticService.store(currentGame)
//            
//            let gamesCount = statisticService.gamesCount
//            let bestGame = statisticService.bestGame
//            let totalAccuracy = "\(String(format: "%.2f", statisticService.totalAccuracy))%"
//            let bestGameDate = bestGame.date.dateTimeString
//            
//            let resultText = """
//               Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
//               Количество сыгранных квизов: \(gamesCount)
//               Рекорд: \(bestGame.correct)/\(bestGame.total) ( \(bestGameDate) )
//               Средняя точность: \(totalAccuracy)
//               """
//            
//            let viewModelAlert = QuizResultsViewModel(
//                title: "Этот раунд окончен!",
//                text: resultText,
//                buttonText: "Сыграть еще раз")
//            
//            showResult(quiz: viewModelAlert)
//        } else { // в состояние "Вопрос показан"
//            presenter.switchToNextQuestion()
//            self.questionFactory?.requestNextQuestion()
//        }
//    }
    
    // приватный метод для показа результатов раунда квиза
    func showResult(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            guard let self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        let alertPresenter = AlertPresenter()
        alertPresenter.showAlert(alertModel: alertModel, controller: self)
    }
    
    private func changeStateButton(isEnabled: Bool){
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating() // выключаем анимацию
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.loadData()
            self.questionFactory?.requestNextQuestion()
        }
        
        let alertPresenter = AlertPresenter()
        alertPresenter.showAlert(alertModel: alertModel, controller: self)
    }
}
