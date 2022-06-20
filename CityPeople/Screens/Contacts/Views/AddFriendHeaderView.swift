//
//  AddFriendHeaderView.swift
//  CityPeople
//
//  Created by Kamal Kishor on 31/05/22.
//

import UIKit
import AVFoundation
import RxSwift
import Stevia

class AddFriendHeaderView: UITableViewHeaderFooterView {
    
    var showCameraPermissionAlert:(() -> ())?

    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: Constants.backIcon), for: .normal)
        return button
    }()
    
    let searchField: SearchField = {
        let textField = SearchField()
        textField.placeholder = Constants.searchPlaceholder
        textField.font = .font(name: .regular, size: Constants.textFieldFontSize)
        textField.textColor = .black
        return textField
    }()
    
    private let friendLabel: UILabel = {
       let label = UILabel()
        label.text = Constants.friendText
        label.font = .font(name: .semiBold, size: Constants.labelFontSize)
        label.textColor = .black
        return label
    }()
    
    private lazy var cameraView: CameraView = {
        let cameraView = CameraView(cameraViewModel: cameraViewModel)
        cameraView.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        return cameraView
    }()
    
    private let disposeBag = DisposeBag()
    private let cameraViewModel: CameraViewModelProtocol = CameraViewModel(cameraSide: .front)
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: CreateGroupHeaderView.reuseIdentifier)
        setupViewLayouts()
//        checkOrAskCameraPermissions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func checkOrAskCameraPermissions() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .notDetermined, .restricted:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] isGranted in
                guard let self = self else { return }
                if isGranted {
                    self.cameraViewModel.videoAction.accept(.show)
                } else {
                    self.showCameraPermissionAlert?()
                }
            }
        case .denied:
            self.showCameraPermissionAlert?()
        case .authorized:
            self.cameraViewModel.videoAction.accept(.show)
        @unknown default:
            fatalError()
        }
    }
    
    private func setupViewLayouts() {
        subviews {
            backButton
            searchField
            friendLabel
            cameraView
        }
        
        backButton
            .leading(Constants.viewPadding)
            .top(Constants.zeroValue)
        
        searchField
            .fillHorizontally(padding: Constants.viewPadding)
            .height(Constants.searchFieldHeight)
            .Bottom == friendLabel.Top - Constants.viewPadding
           
        friendLabel
            .leading(Constants.viewPadding)
            .Bottom == cameraView.Bottom
        
        cameraView
            .top(Constants.viewPadding)
            .right(Constants.viewPadding)
            .height(Constants.cameraHeight)
            .width(Constants.cameraWidth)
            .bottom(Constants.viewPadding)
            .Leading == searchField.Trailing + Constants.viewPadding
    }
    
    private enum Constants {
        static let createGroupNameLabel = "Create Group"
        static let groupNamePlaceholder  = "Enter group name"
        static let searchPlaceholder  = "Search"
        static let friendText = "Friend"
        static let backIcon = "circle_back_button"
        static let screenWidth = UIScreen.main.bounds.size.width
        static let cameraWidth = screenWidth * 0.22
        static let cameraHeight = cameraWidth * (16/9)
        static let fieldHeight = 44
        static let textFieldFontSize = 14.0
        static let labelFontSize = 18.0
        static let extraSpaceConstant = 80.0
        static let viewPadding = 16.0
        static let zeroValue = 0.0
        static let searchFieldHeight = 36.0
    }

}
