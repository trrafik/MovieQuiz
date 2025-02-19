import UIKit


final class AlertPresenter {
    func showAlert(alertModel: AlertModel, controller: UIViewController) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        alert.view.accessibilityIdentifier = "Game results"
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }

        alert.addAction(action)
        controller.present(alert, animated: true, completion: nil)
    }
}
