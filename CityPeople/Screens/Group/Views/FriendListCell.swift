//
//  FriendListCell.swift
//  CityPeople
//
//  Created by Kamal Kishor on 06/05/22.
//

import UIKit
import Stevia
import RxSwift
import RxRelay
import SwiftyContacts

class FriendListCell: UITableViewCell {
    
    var btnSelectFriendTapped:(() -> Void)?
    
    private let imageViewIcon: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: Constants.friendIcon)
        return imageView
    }()
    
    private let title: UILabel = {
        let label = UILabel()
        label.font = .font(name: .regular, size: Constants.titleFontSize)
        label.textColor = .black
        return label
    }()
    
    private let btnSelect: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: Constants.unchecked), for: .normal)
        btn.setImage(UIImage(named: Constants.checked), for: .selected)
        return btn
    }()
    
    private let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViewLayouts()
        setupViewBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupViewLayouts() {
        contentView.subviews {
            imageViewIcon
            title
            btnSelect
        }
        
        imageViewIcon
            .leading(Constants.viewPadding)
            .top(Constants.viewPadding)
            .centerVertically()
        
        title
            .centerVertically()
            .Leading == imageViewIcon.Trailing + Constants.viewPadding
        
        btnSelect.right(Constants.viewPadding)
        btnSelect.Leading >= title.Trailing + Constants.viewPadding
        btnSelect.CenterY == title.CenterY
    }
    
    private func setupViewBindings() {
        btnSelect
            .rx
            .tap
            .bind {
                self.btnSelectFriendTapped?()
            }
            .disposed(by: disposeBag)
    }
    
    func configure(with friend: Friend, isSelected: Bool) {
        title.text = friend.name
        btnSelect.isSelected = isSelected
    }
    
    private enum Constants {
        static let viewPadding: CGFloat = 16.0
        static let titleFontSize: CGFloat = 16.0
        static let unchecked = "unchecked"
        static let checked = "check"
        static let friendIcon = "friends"
    }
}
