//
//  Pgoto.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 26.02.2024.
//

import Foundation
import SwiftData

@Model
final class Photo {
    @Attribute(.unique)
    let id: String
    var image: Data
    var userName: String
    var itemDescription: String
    var savedDate: Date
    var isFavourite: Bool
    
    init(id: String, image: Data, userName: String, itemDescription: String, savedDate: Date, isFavourite: Bool) {
        self.id = id
        self.image = image
        self.userName = userName
        self.itemDescription = itemDescription
        self.savedDate = savedDate
        self.isFavourite = isFavourite
    }
}
