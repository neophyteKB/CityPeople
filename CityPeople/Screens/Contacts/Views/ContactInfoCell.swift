//
//  ContactInfoCell.swift
//  CityPeople
//
//  Created by Kamal Kishor on 31/05/22.
//

import UIKit
import RxSwift
import Stevia

class ContactInfoCell: UITableViewCell {

    var cellButtonTapped:(() -> Void)?
    
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
    
    private let primaryRightButton: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = .font(name: .regular, size: Constants.btnFontSize)
        btn.setTitleColor(.black, for: .normal)
        btn.setBorder(with: .cityGreen, cornerRadius: Constants.btnHeight/2)
        return btn
    }()
    
    private let secondaryRightButton: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = .font(name: .regular, size: Constants.btnFontSize)
        btn.setTitleColor(.black, for: .normal)
        btn.setBorder(with: .cityGreen, cornerRadius: Constants.btnHeight/2)
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
    
    func configure(with user: User) {
        title.text = user.name
        secondaryRightButton.isHidden = true
        if user.isFriend {
            primaryRightButton.isHidden = true 
        } else if user.isRegistered {
            primaryRightButton.setTitle(user.requestStatus.title, for: .normal)
            if user.requestStatus == .requestReceived {
                secondaryRightButton.isHidden = false
            }
        } else {
            primaryRightButton.setTitle(Constants.invite, for: .normal)
        }
    }
    
    // MARK: - Private Methods
    private func setupViewLayouts() {
        contentView.subviews {
            imageViewIcon
            title
            primaryRightButton
            secondaryRightButton
        }
        
        imageViewIcon
            .leading(Constants.viewPadding)
            .top(Constants.viewPadding)
            .centerVertically()
        
        title
            .centerVertically()
            .Leading == imageViewIcon.Trailing + Constants.viewPadding
         
        secondaryRightButton.Leading >= title.Trailing + Constants.viewPadding
        primaryRightButton.CenterY == title.CenterY
        
        primaryRightButton.right(Constants.viewPadding).height(Constants.btnHeight).width(Constants.btnWidth)
        primaryRightButton.Leading >= secondaryRightButton.Trailing + Constants.viewPadding
        primaryRightButton.CenterY == title.CenterY
    }
    
    private func setupViewBindings() {
        primaryRightButton
            .rx
            .tap
            .bind {
                self.cellButtonTapped?()
            }
            .disposed(by: disposeBag)
    }
    
    private enum Constants {
        static let viewPadding: CGFloat = 16.0
        static let titleFontSize: CGFloat = 16.0
        static let btnFontSize: CGFloat = 12.0
        static let btnHeight: CGFloat = 28.0
        static let btnWidth: CGFloat = 72.0
        static let unchecked = "unchecked"
        static let checked = "check"
        static let friendIcon = "friends"
        static let invite = "Invite"
    }
}
