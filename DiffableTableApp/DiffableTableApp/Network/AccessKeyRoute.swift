//
//  AccessKeyRoute.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 1.03.2024.
//

import Foundation

struct AccessKeyRoute: NetworkRoute {
    var path: String {
        Constants.accessKeyPath
    }
    var asURLRequest: URLRequest? {
        guard let url = URL(string: path) else { return nil }
        let urlRequest = URLRequest(url: url)
        return urlRequest
    }
}
