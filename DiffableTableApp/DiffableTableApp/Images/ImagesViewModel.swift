//
//  ImagesViewModel.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 24.02.2024.
//

import UIKit
import Combine

protocol ImagesViewModel: AnyObject {
    var setupModels: AnyPublisher<[ImagesSectionData], Error> { get }
    var appendModels: AnyPublisher<[ImagesSectionData], Error> { get }
    var reloadPhotosIds: Published<[String: Bool]>.Publisher { get }
    func getUnsplashAccessKey()
    func getImages()
    func getSearched(for text: String)
    func toggleImage(for photo: Photo)
    func loadMore()
}

final class BaseImagesViewModel: ImagesViewModel {
    private var _setupModels = CurrentValueSubject<[ImagesSectionData], Error>([])
    private var _appendModels = PassthroughSubject<[ImagesSectionData], Error>()
    @Published private var _reloadPhotosIds: [String: Bool] = .init()
    private let networkService: NetworkService
    private let dataService: DataService
    private let modelMapper: ImagesModelMapper
    private var pageNumber: Int = 1
    
    init(networkService: NetworkService,
         dataService: DataService,
         modelMapper: ImagesModelMapper) {
        self.networkService = networkService
        self.dataService = dataService
        self.modelMapper = modelMapper
    }
    
    func getUnsplashAccessKey() {
        guard Constants.unsplashAccessKey.isEmpty else {
            getImages()
            return
        }
        Task(priority: .utility) {
            do {
                let route = AccessKeyRoute()
                let accessKeyLink: AccessKeyLink = try await networkService.request(for: route)
                Constants.accessKeyPath = accessKeyLink.href
                let data = try await networkService.requestData(for: route)
                if let accessKey = String(data: data, encoding: .utf8) {
                    Constants.unsplashAccessKey = accessKey
                }
                getImages()
            } catch {
                getUnsplashAccessKey()
            }
        }
    }
    
    func getImages() {
        Task(priority: .utility) {
            do {
                let route = DefaultNetworkRoute(
                    path: Constants.randomPhotoPath,
                    queryItems: [URLQueryItem(name: "count", value: "30")])
                let response: [PhotoModel] = try await networkService.request(for: route)
                let models = await modelMapper.map(photos: response)
                _setupModels.send([.init(key: .images, values: models)])
            } catch {
                _setupModels.send(completion: .failure(error))
            }
        }
    }
    
    func getSearched(for text: String) {
        Task(priority: .utility) {
            do {
                let route = DefaultNetworkRoute(
                    path: Constants.searchedPhotoPath,
                    queryItems: [
                        URLQueryItem(name: "query", value: text),
                        URLQueryItem(name: "per_page", value: "30"),
                    ])
                let response: SearchPhotoModel = try await networkService.request(for: route)
                let models = await modelMapper.map(photos: response.results)
                _setupModels.send([.init(key: .images, values: models)])
            } catch {
                _setupModels.send(completion: .failure(error))
            }
        }
    }
    
    func loadMore() {
        Task(priority: .utility) {
            do {
                let route = DefaultNetworkRoute(
                    path: Constants.photoPath,
                    queryItems: [
                        URLQueryItem(name: "page", value: "\(pageNumber)"),
                        URLQueryItem(name: "per_page", value: "20")
                    ])
                let response: [PhotoModel] = try await networkService.request(for: route)
                let models = await modelMapper.map(photos: response)
                _appendModels.send([.init(key: .images, values: models)])
                pageNumber += 1
            } catch {
                _appendModels.send(completion: .failure(error))
            }
        }
    }
    
    func toggleImage(for photo: Photo) {
        if dataService.fetchPhotos().contains(where: { $0.id == photo.id }) {
            dataService.delete(photo)
        } else {
            dataService.add(photo)
        }
    }
}

extension BaseImagesViewModel {
    var setupModels: AnyPublisher<[ImagesSectionData], Error>  {
        _setupModels.eraseToAnyPublisher()
    }
    
    var appendModels: AnyPublisher<[ImagesSectionData], Error> {
        _appendModels.eraseToAnyPublisher()
    }
    
    var reloadPhotosIds: Published<[String: Bool]>.Publisher {
        dataService.photosToChange
    }
}
