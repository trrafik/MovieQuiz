import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
        presenter = MovieQuizPresenter(viewController: self)
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
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    // приватный метод для показа результатов раунда квиза
    func showResult(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            guard let self else { return }
            self.presenter.restartGame()
        }
        
        let alertPresenter = AlertPresenter()
        alertPresenter.showAlert(alertModel: alertModel, controller: self)
    }
    
    private func changeStateButton(isEnabled: Bool){
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating() // выключаем анимацию
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self else { return }
            
            self.presenter.restartGame()
            //self.presenter.questionFactory?.loadData()
        }
        
        let alertPresenter = AlertPresenter()
        alertPresenter.showAlert(alertModel: alertModel, controller: self)
    }
}
