//
//  FavouriteViewModel.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 24.02.2024.
//

import UIKit

protocol FavouriteViewModel: AnyObject {
    var setupModels: Published<[FavouritesSectionData]>.Publisher { get }
    func getModels()
    func deleteModel(at indexPath: IndexPath)
}

final class BaseFavouriteViewModel {
    private let dataService: DataService
    private let modelMapper: FavouriteModelMapper
    @Published private var _setupModels: [FavouritesSectionData] = .init()
    
    init(dataService: DataService, modelMapper: FavouriteModelMapper) {
        self.dataService = dataService
        self.modelMapper = modelMapper
    }
    
    func getModels() {
        let photoModels = dataService.fetchPhotos()
        let favouritesModels = modelMapper.map(photos: photoModels)
        _setupModels = [.init(key: .favourites, values: favouritesModels)]
    }
    
    func deleteModel(at indexPath: IndexPath) {
        let deletedPhoto = _setupModels[indexPath.section].values.remove(at: indexPath.row)
        dataService.delete(with: deletedPhoto.id)
        getModels()
    }
}

extension BaseFavouriteViewModel: FavouriteViewModel {
    var setupModels: Published<[FavouritesSectionData]>.Publisher {
        $_setupModels
    }
}
