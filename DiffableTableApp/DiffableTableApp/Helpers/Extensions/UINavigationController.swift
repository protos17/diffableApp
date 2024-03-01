//
//  UINavigationController.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 28.02.2024.
//

import UIKit

extension UINavigationController {
    func showError(with text: String, completion: (() -> Void)?) {
        let alertController = UIAlertController(title: "Ошибка", message: text, preferredStyle: .alert)
        alertController.addAction(.init(title: "Ok", style: .default, handler: { _ in
            completion?()
        }))
        present(alertController, animated: true)
    }
}
