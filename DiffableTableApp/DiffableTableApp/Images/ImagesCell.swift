//
//  ImagesCell.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 24.02.2024.
//

import UIKit

final class ImagesCell: UICollectionViewCell, Configurable {
    var didTapButton: (() -> Void)?
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var likeButton: UIButton = {
        let likeButton = UIButton(frame: .init(origin: .zero, size: .init(width: 24, height: 24)))
        likeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
        likeButton.tintColor = .red
        likeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .selected)
        likeButton.addTarget(self, action: #selector(didLikeButtonSelected), for: .touchUpInside)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        return likeButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: Photo) {
        imageView.image = UIImage(data: model.image)
        likeButton.isSelected = model.isFavourite
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.frame
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        likeButton.isSelected = false
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(likeButton)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            likeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4)
        ])
    }
    
    @objc
    private func didLikeButtonSelected() {
        likeButton.isSelected.toggle()
        didTapButton?()
    }
}
