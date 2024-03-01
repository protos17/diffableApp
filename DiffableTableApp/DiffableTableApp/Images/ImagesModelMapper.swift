//
//  ImagesModelMapper.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 25.02.2024.
//

import UIKit

protocol ImagesModelMapper: AnyObject {
    func map(photos: [PhotoModel]) async -> [Photo]
}

final class BaseImagesModelMapper: ImagesModelMapper {
    private let networkService: NetworkService
    private let dataService: DataService
    init(networkService: NetworkService, dataService: DataService) {
        self.networkService = networkService
        self.dataService = dataService
    }
    
    func map(photos: [PhotoModel]) async -> [Photo] {
        let savedPhotosIds: Set<String> = Set(dataService.fetchPhotos().map { $0.id })
        return await withTaskGroup(of: Photo?.self, returning: [Photo].self) { [weak self] group in
            guard let self else { return [] }
            for item in photos {
                group.addTask {
                    let imageRoute = ImagesNetworkRoute(baseUrl: item.urls.small ?? "", path: String())
                    do {
                        let imageData = try await self.networkService.requestData(for: imageRoute)
                        let photo = Photo(id: item.id,
                                          image: imageData,
                                          userName: item.user.name ?? "",
                                          itemDescription: item.description ?? "",
                                          savedDate: Date(),
                                          isFavourite: savedPhotosIds.contains(item.id))
                        return photo
                    } catch {
                        return nil
                    }
                }
            }
            var models: [Photo] = .init()
            for await model in group {
                if let model {
                    models.append(model)
                }
            }
            return models
        }
    }
}
