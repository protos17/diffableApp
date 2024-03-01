//
//  FavouriteCell.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 24.02.2024.
//

import UIKit

final class FavouriteCell: UITableViewCell, Configurable {
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var descriptionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    
    private let subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.numberOfLines = 0
        return subtitleLabel
    }()
    
    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: FavouriteModel) {
        photoImageView.image = model.image
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
    }
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(photoImageView)
        contentView.addSubview(descriptionStackView)
        descriptionStackView.addArrangedSubview(titleLabel)
        descriptionStackView.addArrangedSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoImageView.trailingAnchor.constraint(equalTo: descriptionStackView.leadingAnchor, constant: -8),
            photoImageView.heightAnchor.constraint(equalToConstant: 88),
            photoImageView.widthAnchor.constraint(equalToConstant: 88),
            descriptionStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            descriptionStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            descriptionStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
