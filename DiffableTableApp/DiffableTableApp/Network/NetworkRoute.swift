//
//  NetworkRoute.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 25.02.2024.
//

import Foundation

protocol NetworkRoute {
    var baseUrl: String { get }
    var path: String { get }
    var method: APIMethod { get }
    var accessKey: String { get }
    var bodyParameters: [String: Any]? { get }
    var queryItems: [URLQueryItem] { get }
    var asURLRequest: URLRequest? { get }
}

extension NetworkRoute {
    var baseUrl: String {
        Constants.unsplashURL
    }
    
    var method: APIMethod {
        .get
    }
    
    var bodyParameters: [String: Any]? {
        nil
    }
    
    var queryItems: [URLQueryItem] {
        []
    }
    
    var accessKey: String {
        Constants.unsplashAccessKey
    }
    
    var asURLRequest: URLRequest? {
        guard var urlBuilder = URLComponents(string: baseUrl + path) else {
            return nil
        }
        
        if !queryItems.isEmpty {
            urlBuilder.queryItems = queryItems
        }
        
        guard let url = urlBuilder.url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = method.rawValue.uppercased()
        
        if let bodyParameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters)
            } catch {
                return nil
            }
        }
        
        return urlRequest
    }
}

enum APIMethod: String {
    case get, post, put, delete
}
