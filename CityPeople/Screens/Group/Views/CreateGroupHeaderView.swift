//
//  CreateGroupHeaderView.swift
//  CityPeople
//
//  Created by Kamal Kishor on 06/05/22.
//

import UIKit
import AVFoundation
import RxRelay
import RxSwift
import Stevia

class CreateGroupHeaderView: UIView {
    
    var showCameraPermissionAlert:(() -> ())?
    
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: Constants.backIcon), for: .normal)
        return button
    }()
    
    private let createGroupLabel: UILabel = {
       let label = UILabel()
        label.text = Constants.createGroupNameLabel
        label.font = .font(name: .semiBold, size: Constants.labelFontSize)
        label.textColor = .black
        return label
    }()
    
    let groupNameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.groupNamePlaceholder
        textField.font = .font(name: .regular, size: Constants.textFieldFontSize)
        textField.textColor = .black
        return textField
    }()
    
    let searchField: SearchField = {
        let textField = SearchField()
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
    
    private lazy var cameraView: CameraView = {
        let cameraView = CameraView(cameraViewModel: cameraViewModel)
        cameraView.backgroundColor = .clear
        return cameraView
    }()
    
    private let disposeBag = DisposeBag()
    private let cameraViewModel: CameraViewModelProtocol = CameraViewModel(cameraSide: .front)
    
    init() {
        super.init(frame: .zero)
        setupViewLayouts()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.checkOrAskCameraPermissions()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func disappear() {
        cameraViewModel.videoAction.accept(.remove)
    }
    
    private func setupViewLayouts() {
        backgroundColor = .white
        subviews {
            backButton
            createGroupLabel
            groupNameField
            searchField
            friendLabel
            cameraView
        }
        
        backButton
            .leading(Constants.viewPadding)
            .top(Constants.zeroValue)
        
        createGroupLabel
            .leading(Constants.viewPadding)
            .top(Constants.extraSpaceConstant)
        
        groupNameField
            .fillHorizontally(padding: Constants.viewPadding)
            .Top == createGroupLabel.Bottom + Constants.viewPadding
            
        searchField
            .fillHorizontally(padding: Constants.viewPadding)
            .height(Constants.searchFieldHeight)
            .Top == groupNameField.Bottom + Constants.viewPadding
           
        friendLabel
            .leading(Constants.viewPadding)
            .bottom(Constants.viewPadding)
            .Top == searchField.Bottom + Constants.viewPadding
        
        cameraView
            .top(Constants.viewPadding)
            .right(Constants.viewPadding)
            .height(Constants.cameraHeight)
            .width(Constants.cameraWidth)
            .Bottom == searchField.Top - Constants.viewPadding
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
