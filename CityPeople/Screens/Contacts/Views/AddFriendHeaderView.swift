//
//  AddFriendHeaderView.swift
//  CityPeople
//
//  Created by Kamal Kishor on 31/05/22.
//

import UIKit
import RxSwift
import Stevia

class AddFriendHeaderView: UITableViewHeaderFooterView {

    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: Constants.backIcon), for: .normal)
        return button
    }()
    
    let searchField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.searchPlaceholder
        textField.font = .font(name: .regular, size: Constants.textFieldFontSize)
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let friendLabel: UILabel = {
       let label = UILabel()
        label.text = Constants.friendText
        label.font = .font(name: .semiBold, size: Constants.labelFontSize)
        label.textColor = .black
        return label
    }()
    
    private let disposeBag = DisposeBag()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: CreateGroupHeaderView.reuseIdentifier)
        setupViewLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViewLayouts() {
        subviews {
            backButton
            searchField
            friendLabel
        }
        
        backButton
            .leading(Constants.viewPadding)
            .top(Constants.zeroValue)
        
        searchField
            .fillHorizontally(padding: Constants.viewPadding)
            .Top == backButton.Bottom + Constants.viewPadding
           
        friendLabel
            .leading(Constants.viewPadding)
            .bottom(Constants.viewPadding)
            .Top == searchField.Bottom + Constants.viewPadding
    }
    
    private enum Constants {
        static let createGroupNameLabel = "Create Group"
        static let groupNamePlaceholder  = "Enter group name"
        static let searchPlaceholder  = "Search"
        static let friendText = "Friend"
        static let backIcon = "circle_back_button"
        static let fieldHeight = 44
        static let textFieldFontSize = 14.0
        static let labelFontSize = 18.0
        static let extraSpaceConstant = 80.0
        static let viewPadding = 16.0
        static let zeroValue = 0.0
    }

}
