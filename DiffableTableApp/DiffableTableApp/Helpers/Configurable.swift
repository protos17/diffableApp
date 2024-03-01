//
//  Configurable.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 24.02.2024.
//

import Foundation

protocol Configurable: AnyObject {
    associatedtype Model
    func configure(with: Model)
}
