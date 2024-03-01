//
//  UICollectionViewCell.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 24.02.2024.
//

import UIKit

extension UICollectionViewCell {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}
