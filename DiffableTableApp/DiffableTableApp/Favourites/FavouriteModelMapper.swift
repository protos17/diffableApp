//
//  FavouriteModelMapper.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 27.02.2024.
//

import UIKit

protocol FavouriteModelMapper {
    func map(photos: [Photo]) -> [FavouriteModel]
}

struct BaseFavouriteModelMapper: FavouriteModelMapper {
    func map(photos: [Photo]) -> [FavouriteModel] {
        return photos.map { .init(id: $0.id,
                                  image: UIImage(data: $0.image) ?? UIImage(),
                                  title: $0.userName,
                                  subtitle: $0.itemDescription)
        }
    }
}
