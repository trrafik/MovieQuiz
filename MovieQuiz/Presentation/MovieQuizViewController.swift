import UIKit

final class MovieQuizViewController: UIViewController,
                                        MovieQuizViewControllerProtocol {
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
    
    // MARK: - actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - functions
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
        changeStateButton(isEnabled: true)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        changeStateButton(isEnabled: false)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
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
