//
//  TableDataSource.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 24.02.2024.
//

import UIKit

final class TableDataSource: UITableViewDiffableDataSource<Section, FavouriteModel> {
    init(tableView: UITableView) {
        super.init(tableView: tableView, cellProvider: { tableView, indexPath, item in
            let cell = tableView.reuse(FavouriteCell.self, indexPath)
            cell.configure(with: item)
            return cell
        })
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
}
