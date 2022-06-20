//
//  UserCollectionViewCell.swift
//  CityPeople
//
//  Created by Kamal Kishor on 23/05/22.
//

import UIKit
import RxSwift
import RxCocoa

class UserCollectionViewCell: UICollectionViewCell {
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.setBorder(with: .black)
        return imageView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        activity.hidesWhenStopped = true
        activity.style = .medium
        return activity
    }()
    
    private let thumbnailTitle: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .font(name: .italic, size: Constants.tileNameFontSize)
        return label
    }()
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: Any) {
        
        if let item = item as? UserVideo {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let url = item.videos.first?.url {
                    self.activityIndicator.startAnimating()
                    url.getThumbnailFromUrl({ [weak self] image in
                        guard let imageSelf = self else { return }
                        imageSelf.userImageView.image = image
                        imageSelf.activityIndicator.stopAnimating()
                    })
                } else {
                    self.userImageView.image = UIImage(named: Constants.userIcon)
                }
            }
            thumbnailTitle.text = item.name
        } else {
            userImageView.image = UIImage(named: Constants.userIcon)
            thumbnailTitle.text = Constants.invite
        }
    }
    
    func setupViewLayouts() {
        contentView.subviews {
            userImageView
            activityIndicator
            thumbnailTitle
        }
        
        userImageView
            .fillContainer()
        
        activityIndicator
            .centerInContainer()
        
        thumbnailTitle
            .left(Constants.padding)
            .bottom(Constants.padding)
    }
    
    private enum Constants {
        static let userIcon = "user"
        static let invite = "Invite"
        
        static let padding: CGFloat = 8.0
        static let tileNameFontSize: CGFloat = 12
    }
}


