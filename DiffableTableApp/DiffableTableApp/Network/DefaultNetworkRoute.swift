//
//  DefaultNetworkRoute.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 25.02.2024.
//

import Foundation

struct DefaultNetworkRoute: NetworkRoute {
    let path: String
    var queryItems: [URLQueryItem] = []
}
