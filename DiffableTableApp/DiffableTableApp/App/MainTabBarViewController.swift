//
//  MainTabBarViewController.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 23.02.2024.
//

import UIKit

final class MainTabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .lightGray
        tabBar.isTranslucent = false
        tabBar.unselectedItemTintColor = .darkGray
    }
}
