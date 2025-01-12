import UIKit


class AlertPresenter {
    func showAlert(alertModel: AlertModel, controller: UIViewController) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)

        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }

        alert.addAction(action)
        controller.present(alert, animated: true, completion: nil)
    }
}
