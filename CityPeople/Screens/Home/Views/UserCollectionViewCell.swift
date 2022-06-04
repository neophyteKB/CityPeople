//
//  UserCollectionViewCell.swift
//  CityPeople
//
//  Created by Kamal Kishor on 23/05/22.
//

import UIKit
import RxSwift

class UserCollectionViewCell: UICollectionViewCell {
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: Constants.user)
        imageView.setBorder(with: .black)
        return imageView
    }()
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewLayouts()
        setupViewBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViewLayouts() {
        subviews {
            userImageView
        }
        
        userImageView
            .fillContainer()
    }
    
    func setupViewBindings() {
        
    }
    
    private enum Constants {
        static let user = "user"
    }
}


