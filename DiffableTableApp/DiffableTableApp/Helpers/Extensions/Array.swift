//
//  Array.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 24.02.2024.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        indices ~=  index ? self[index] : nil
    }
}
