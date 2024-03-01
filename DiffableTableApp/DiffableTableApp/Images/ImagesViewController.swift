//
//  ImagesViewController.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 23.02.2024.
//

import UIKit
import Combine

final class ImagesViewController: UIViewController {
    private let viewModel: ImagesViewModel
    private let router: BaseRouter
    private var collectionView: UICollectionView?
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Введите запрос"
        return searchController
    }()
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Пожалуйста, подождите, данные загружаются"
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Photo>?
    private var snapshot = NSDiffableDataSourceSnapshot<Section, Photo>()
    private var cancellables: Set<AnyCancellable> = .init()
    
    init(viewModel: ImagesViewModel, router: BaseRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        viewModel.getUnsplashAccessKey()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGray4
        navigationItem.title = "Images"
        navigationItem.searchController = searchController
        view.addSubview(emptyLabel)
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.topAnchor.constraint(equalTo: emptyLabel.bottomAnchor, constant: 16),
            activityIndicator.centerXAnchor.constraint(equalTo: emptyLabel.centerXAnchor)
        ])
        activityIndicator.startAnimating()
    }
    
    private func bind() {
        viewModel.setupModels
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    self.activityIndicator.stopAnimating()
                    self.showError(with: error.localizedDescription)
                }
            }, receiveValue: { [weak self] models in
                guard let self, !models.isEmpty else { return }
                self.createCollectionView(for: models)
                self.setupData(with: models)
                self.activityIndicator.stopAnimating()
            })
            .store(in: &cancellables)
        
        viewModel.appendModels
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    self.showError(with: error.localizedDescription)
                }
            }, receiveValue: { [weak self] models in
                guard let self, !models.isEmpty else { return }
                self.updateData(with: models)
            })
            .store(in: &cancellables)
        
        viewModel.reloadPhotosIds
            .receive(on: RunLoop.main)
            .sink { [weak self] ids in
                guard let self else { return }
                self.updateCell(with: ids)
            }
            .store(in: &cancellables)
    }
    
    private func createCollectionView(for models: [ImagesSectionData]) {
        let topSafeAreaHeight: CGFloat = view.safeAreaInsets.top
        collectionView = nil
        dataSource = nil
        collectionView = UICollectionView(
            frame: .init(x: view.bounds.origin.x,
                         y: view.bounds.origin.y + topSafeAreaHeight + 8,
                         width: view.bounds.width,
                         height: view.bounds.height - topSafeAreaHeight - 8),
            collectionViewLayout: createCompositionalLayout(with: models))
        collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView?.register(ImagesCell.self, forCellWithReuseIdentifier: ImagesCell.reuseIdentifier)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .darkGray
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        collectionView?.delegate = self
        if let collectionView {
            view.addSubview(collectionView)
            dataSource = CollectionDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
                let cell = collectionView.reuse(ImagesCell.self, indexPath)
                cell.configure(with: item)
                cell.didTapButton = { [weak self] in
                    guard let self else { return }
                    self.viewModel.toggleImage(for: item)
                }
                return cell
            })
        }
    }
    
    private func createCompositionalLayout(with models: [ImagesSectionData]) -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self, let section = models[safe: sectionIndex] else { return nil }
            switch section.key {
            case .images:
                return createImagesSection()
            default:
                return nil
            }
        }
        return layout
    }
    
    private func createImagesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets.init(top: .zero, leading: 0, bottom: 8, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(154))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let interItemSpacing = NSCollectionLayoutSpacing.fixed(8)
        group.interItemSpacing = interItemSpacing
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 8, bottom: 16, trailing: 8)
        return section
    }
    
    private func setupData(with models: [ImagesSectionData]) {
        emptyLabel.isHidden = models.first?.values.isEmpty == false
        collectionView?.isHidden = models.first?.values.isEmpty == true
        snapshot.deleteAllItems()
        for item in models {
            snapshot.appendSections([item.key])
            snapshot.appendItems(item.values, toSection: item.key)
        }
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateData(with models: [ImagesSectionData]) {
        for item in models {
            if !snapshot.sectionIdentifiers.contains(item.key) {
                snapshot.appendSections([item.key])
            }
            snapshot.appendItems(item.values, toSection: item.key)
        }
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateCell(with favouriteIds: [String: Bool]) {
        guard var snapshot = dataSource?.snapshot() else { return }
        var reconfigureItems: [Photo] = .init()
        for item in snapshot.itemIdentifiers {
            if favouriteIds.keys.contains(item.id) {
                item.isFavourite = favouriteIds[item.id] ?? false
                reconfigureItems.append(item)
            }
        }
        snapshot.reconfigureItems(reconfigureItems)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func showError(with text: String) {
        navigationController?.showError(with: text, completion: { [unowned viewModel] in
            viewModel.getImages()
        })
    }
    
    @objc
    private func didPullToRefresh() {
        activityIndicator.startAnimating()
        viewModel.getImages()
    }
}

extension ImagesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text,
              !text.isEmpty,
              text.count > 2 else { return }
        viewModel.getSearched(for: text)
    }
}

extension ImagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if snapshot.numberOfSections - 1 == indexPath.section {
            let currentSection = snapshot.sectionIdentifiers[indexPath.section]
            if snapshot.numberOfItems(inSection: currentSection) - 10 == indexPath.row {
                viewModel.loadMore()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = snapshot.sectionIdentifiers[safe: indexPath.section],
              let imageData = snapshot.itemIdentifiers(inSection: section)[safe: indexPath.row]?.image,
              let image = UIImage(data: imageData) else {
            return
        }
        router.viewController = self
        router.openDetailsViewController(with: image)
    }
}
