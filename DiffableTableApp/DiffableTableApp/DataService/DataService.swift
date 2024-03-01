//
//  DataService.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 26.02.2024.
//

import Foundation
import SwiftData

protocol DataService: AnyObject {
    var photosToChange: Published<[String: Bool]>.Publisher { get }
    func fetchPhotos() -> [Photo]
    func add(_ photo: Photo)
    func delete(with id: String)
    func delete(_ photo: Photo)
    func deleteAll()
}

final class BaseDataService: DataService {
    private var container: ModelContainer?
    private var context: ModelContext?
    @Published private var changedPhotos: [String: Bool] = .init()
    
    init() {
        do {
            let schema = Schema([Photo.self])
            let modelConfigiration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfigiration])
            if let container {
                context = ModelContext(container)
            }
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
    
    var photosToChange: Published<[String: Bool]>.Publisher {
        $changedPhotos
    }

    func fetchPhotos() -> [Photo] {
        let desciptor = FetchDescriptor<Photo>(
            sortBy: [.init(\.savedDate)]
        )
        do {
            let photos = try context?.fetch(desciptor)
            return photos ?? []
        } catch {
            return []
        }
    }
    
    func add(_ photo: Photo) {
        let savedPhoto = photo
        photo.savedDate = Date()
        context?.insert(savedPhoto)
        changedPhotos = [savedPhoto.id: true]
    }
    
    func delete(with id: String) {
        let photos = fetchPhotos()
        if let photo = photos.first(where: { $0.id == id }) {
            context?.delete(photo)
            changedPhotos = [photo.id: false]
        }
    }
    
    func delete(_ photo: Photo) {
        context?.delete(photo)
        changedPhotos = [photo.id: false]
    }
    
    func deleteAll() {
        do {
            try context?.delete(model: Photo.self)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}
