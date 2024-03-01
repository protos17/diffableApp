//
//  BaseRouter.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 29.02.2024.
//

import UIKit

protocol Router: AnyObject {
    var viewController: UIViewController? { get set }
    func startApp()
    func openDetailsViewController(with image: UIImage)
}

final class BaseRouter: Router {
    weak var viewController: UIViewController?

    private let networkService: NetworkService = BaseNetworkService()
    private let dataService: DataService = BaseDataService()
    
    
    func startApp() {
        (viewController as? UITabBarController)?.viewControllers = [
            createImagesViewController(),
            createFavouritesViewController()
        ]
    }
    
    func openDetailsViewController(with image: UIImage) {
        let detailViewController = DetailViewController()
        detailViewController.setup(with: image)
        viewController?.navigationController?.present(detailViewController, animated: true)
    }
    
    private func createImagesViewController() -> UIViewController {
        let imagesModelMapper: ImagesModelMapper = BaseImagesModelMapper(networkService: networkService, dataService: dataService)
        let imagesViewModel: ImagesViewModel = BaseImagesViewModel(
            networkService: networkService,
            dataService: dataService,
            modelMapper: imagesModelMapper)
        let imagesViewController = UINavigationController(rootViewController: ImagesViewController(viewModel: imagesViewModel, router: self))
        imagesViewController.tabBarItem.image = UIImage(systemName: "house.fill")
        return imagesViewController
    }
    
    private func createFavouritesViewController() -> UIViewController {
        let favouritesModelMapper: FavouriteModelMapper = BaseFavouriteModelMapper()
        let favouritesViewModel: FavouriteViewModel = BaseFavouriteViewModel(dataService: dataService, modelMapper: favouritesModelMapper)
        let favouritesViewController = UINavigationController(rootViewController: FavouriteViewController(viewModel: favouritesViewModel, router: self))
        favouritesViewController.tabBarItem.image = UIImage(systemName: "star.fill")
        return favouritesViewController
    }
}
