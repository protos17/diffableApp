//
//  NetworkService.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 25.02.2024.
//

import Foundation

protocol NetworkService {
    func request<T: Decodable>(for route: NetworkRoute) async throws -> T
    func requestData(for route: NetworkRoute) async throws -> Data
}

struct BaseNetworkService: NetworkService {
    private let decoder = JSONDecoder()
    func request<T: Decodable>(for route: NetworkRoute) async throws -> T {
        guard let request = route.asURLRequest else {
            throw NetworkErrors.incorrectUrl
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
              200..<300 ~= statusCode else {
            throw NetworkErrors.responseError
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkErrors.decodingError
        }
    }
    
    func requestData(for route: NetworkRoute) async throws -> Data {
        guard let request = route.asURLRequest else {
            throw NetworkErrors.incorrectUrl
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
              200..<300 ~= statusCode else {
            throw NetworkErrors.responseError
        }
        return data
    }
}
