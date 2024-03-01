//
//  FavouriteViewController.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 24.02.2024.
//

import UIKit
import Combine

final class FavouriteViewController: UIViewController {
    private let viewModel: FavouriteViewModel
    private let router: BaseRouter
    private var cancellables: Set<AnyCancellable> = .init()
    private lazy var dataSource: UITableViewDiffableDataSource<Section, FavouriteModel> = {
        TableDataSource(tableView: tableView)
    }()
    private lazy var snapshot = NSDiffableDataSourceSnapshot<Section, FavouriteModel>()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FavouriteCell.self)
        tableView.rowHeight = 96
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "В избранном пока отсутствуют элементы"
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(viewModel: FavouriteViewModel, router: BaseRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getModels()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    private func setupUI() {
        navigationItem.title = "Favourites"
        view.backgroundColor = .systemGray2
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        tableView.delegate = self
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bind() {
        viewModel.setupModels
            .receive(on: RunLoop.main)
            .sink { [weak self] models in
                guard let self else { return }
                emptyLabel.isHidden = models.first?.values.isEmpty == false
                snapshot.deleteAllItems()
                for item in models {
                    if !snapshot.sectionIdentifiers.contains(item.key) {
                        snapshot.appendSections([item.key])
                    }
                    snapshot.appendItems(item.values, toSection: item.key)
                }
                UIView.performWithoutAnimation {
                    self.dataSource.apply(self.snapshot, animatingDifferences: false)
                }
            }
            .store(in: &cancellables)
    }
}

extension FavouriteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [unowned viewModel] (action, sourceView, completionHandler) in
            tableView.beginUpdates()
            viewModel.deleteModel(at: indexPath)
            tableView.endUpdates()
            completionHandler(true)
        }
        delete.title = "Delete"
        
        let swipeAction = UISwipeActionsConfiguration(actions: [delete])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = snapshot.sectionIdentifiers[safe: indexPath.section],
              let image = snapshot.itemIdentifiers(inSection: section)[safe: indexPath.row]?.image else {
            return
        }
        router.viewController = self
        router.openDetailsViewController(with: image)
    }
}
