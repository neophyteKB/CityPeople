//
//  HomeViewController.swift
//  CityPeople
//
//  Created by Kamal Kishor on 25/04/22.
//

import UIKit
import Stevia
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    private let navigationTitleView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.logoIcon)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var headerView: HomeScreenHeaderView = {
        let headerView = HomeScreenHeaderView(cameraViewModel: viewModel.cameraViewModel)
        return headerView
    }()
    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: Constants.collectionViewPadding,
                                           left: Constants.collectionViewPadding,
                                           bottom: Constants.collectionViewPadding,
                                           right: Constants.collectionViewPadding)
        layout.itemSize = CGSize(width: Constants.userCellWidth,
                                 height: Constants.userCellHeight)
        layout.minimumInteritemSpacing = Constants.collectionViewCellSpacing
        layout.minimumLineSpacing = Constants.collectionViewPadding
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: UserCollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    private let loadingTitle: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.font = .font(name: .italic, size: Constants.loadingTextFontSize)
        return label
    }()
    private let rearCameraVideoRecordingButton = UIButton()
    private let frontCameraVideoRecordingButton = UIButton()
    
    // Private Properties
    private let viewModel: HomeViewModelProtocol = HomeViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewLayouts()
        setupViewBindings()
        viewModel.onViewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.frontCameraVideoRecordingButton.animate(duration: 0, color: .cityGreen)
            self.rearCameraVideoRecordingButton.animate(duration: 0, color: .cityGreen)
        }
    }

    private func setupViewLayouts() {
        view.backgroundColor = .white
        view.subviews {
            navigationTitleView
            headerView
            collectionView
            loadingTitle
            rearCameraVideoRecordingButton
            frontCameraVideoRecordingButton
        }
        
        navigationTitleView
            .fillHorizontally()
            .height(Constants.titleViewHeight)
            .Top == view.safeAreaLayoutGuide.Top + Constants.viewPadding
        
        headerView
            .fillHorizontally()
            .height(HomeScreenHeaderView.headerHeight)
            .Top == navigationTitleView.Bottom
        
        collectionView
            .fillHorizontally()
            .bottom(Constants.zeroValue)
            .Top == headerView.Bottom
        
        loadingTitle
            .centerInContainer()
        
        rearCameraVideoRecordingButton
            .centerHorizontally()
            .size(Constants.rearCameraButtonSizeDimension)
            .Bottom == frontCameraVideoRecordingButton.Top + Constants.recordingButtonIntersectionsSpacing
        
        frontCameraVideoRecordingButton
            .centerHorizontally()
            .size(Constants.frontEndCameraButtonSizeDimension)
            .Bottom == view.safeAreaLayoutGuide.Bottom
    }
    
    private func setupViewBindings() {
        viewModel
            .isCameraPermissionGranted
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isGranted in
                guard let self = self else { return }
                if isGranted {
                    self.showCamera()
                } else {
                    self.alert(message: Constants.cameraPermissionMessage)
                }
            })
            .disposed(by: disposeBag)
        
        frontCameraVideoRecordingButton
            .rx
            .tap
            .bind { [weak self] in
                self?.viewModel.camera(action: .start)
                self?.frontCameraVideoRecordingButton.animate(duration: Constants.videoRecordingLength, color: .white)
            }
            .disposed(by: disposeBag)
        
        rearCameraVideoRecordingButton
            .rx
            .tap
            .bind { [weak self] in
                self?.viewModel.camera(action: .stop)
//                self?.frontCameraVideoRecordingButton.animate(duration: Constants.videoRecordingLength, color: .white)
            }
            .disposed(by: disposeBag)
        
        viewModel
            .cameraViewModel
            .video
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] url in
                guard let self = self else { return }
                Router.pushSendVideo(with: url, contacts: self.viewModel.contacts.value)
            })
            .disposed(by: disposeBag)
        
        headerView
            .isLocationPermissionsDenied
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isDenied in
                self?.alert(message: Constants.locationPermissionMessage)
            })
            .disposed(by: disposeBag)
        
        headerView
            .pushView
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewType in
                self?.push(to: viewType)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .users
            .bind(to: collectionView.rx.items(cellIdentifier: UserCollectionViewCell.reuseIdentifier,
                                              cellType: UserCollectionViewCell.self)) { (collectionView, row, element) in
                print(element)
            }
            .disposed(by: disposeBag)
        
        viewModel
            .users
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] users in
                self?.loadingTitle.isHidden = !users.isEmpty
            })
            .disposed(by: disposeBag)
        
    }
    
    private func showCamera() {
        viewModel.cameraViewModel.videoAction.accept(.show)
    }
    
    private func push(to viewType: ViewType) {
        switch viewType {
        case .friends:
            // Push to friends
            Router.pushContactsViewController(contacts: viewModel.contacts.value)
        case .group:
            // Push to Group
            Router.pushCreateGroupViewController(contacts: viewModel.contacts.value)
        }
    }
    
    private func alert(message: String) {
        let alert = UIAlertController(title: "Settings", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { _ in
            Router.showAppSettings()
        }))
        present(alert, animated: true)
    }
}

private enum Constants {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let zeroValue: CGFloat = 0.0
    static let rearCameraButtonSizeDimension: CGFloat = 72
    static let frontEndCameraButtonSizeDimension: CGFloat = 100
    static let recordingButtonIntersectionsSpacing: CGFloat = 20.0
    static let recordingButtonsBorderWidth: CGFloat = 8.0
    static let collectionViewPadding: CGFloat = 8.0
    static let collectionViewCellSpacing: CGFloat = 8.0
    static let userCellWidth: CGFloat = (screenWidth - (2 * collectionViewPadding) - (2 * collectionViewCellSpacing)) / 3
    static let userCellHeight: CGFloat = userCellWidth * (16/9)
    static let viewPadding: CGFloat = 16.0
    static let loadingTextFontSize: CGFloat = 16.0
    static let titleViewHeight: CGFloat = 24.0
    static let videoRecordingLength: CGFloat = 10.0
    
    static let logoIcon = "citypeople_logo_splash"
    static let cameraOptionsIcon = "circle_img_green"
    
    static let settings = "Settings"
    static let cancel = "Cancel"
    static let gotoSettings = "Go to Settings"
    static let cameraPermissionMessage = "You have denied the camera permissions, to continue please enable camera permissions from Settings."
    static let locationPermissionMessage = "You have denied the location permission, to continue please enable the location permissions from Settings."
}

private extension UIButton {
    func animate(duration: CGFloat, color: UIColor) {
        let storkeLayer = CAShapeLayer()
        storkeLayer.fillColor = UIColor.clear.cgColor
        storkeLayer.strokeColor = color.cgColor
        storkeLayer.lineWidth = Constants.recordingButtonsBorderWidth
        
        // Create a rounded rect path using button's bounds.
        let startAngle = -Double.pi/2.0
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.width/2),
                                      radius: (self.bounds.size.width - Constants.recordingButtonsBorderWidth)/2,
                                      startAngle: -Double.pi/2.0,
                                      endAngle: CGFloat((Double.pi) - startAngle),
                                      clockwise: true)
        storkeLayer.path = circlePath.cgPath
        // same path like the empty one ...
        // Add layer to the button
        layer.addSublayer(storkeLayer)
        
        if duration != 0 {
            // Create animation layer and add it to the stroke layer.
            let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
            animation.fromValue = CGFloat(0.0)
            animation.toValue = CGFloat(1.0)
            animation.duration = duration
            animation.fillMode = .forwards
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            storkeLayer.add(animation, forKey: "circleAnimation")
        }
    }
}
