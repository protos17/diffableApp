//
//  PhotoModel.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 25.02.2024.
//

import Foundation

struct PhotoModel: Codable {
    let id: String
    let createdAt: String?
    let description: String?
    let urls: UrlModel
    let user: User
    let downloads: Int?
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case id, urls, user, downloads, description
    }
}

struct UrlModel: Codable {
    let small: String?
}

struct User: Codable {
    let name: String?
    let location: String?
}

struct SearchPhotoModel: Codable {
    let results: [PhotoModel]
}
