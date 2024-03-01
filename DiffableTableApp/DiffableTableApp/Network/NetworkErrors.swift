//
//  NetworkErrors.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 25.02.2024.
//

import Foundation

enum NetworkErrors: Error {
    case incorrectUrl
    case responseError
    case decodingError
}
