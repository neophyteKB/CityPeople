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
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .black
        label.font = .font(name: .italic, size: Constants.loadingTextFontSize)
        return label
    }()
    private let rearCameraVideoRecordingButton = UIButton()
    private let frontCameraVideoRecordingButton = UIButton()
    private var timer: Timer?
    
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
        viewModel.requestVideos()
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
            timeLabel
            collectionView
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
        
        timeLabel
            .right(Constants.viewPadding)
            .height(Constants.timeLabelHeight)
            .Top == headerView.Bottom + Constants.viewPadding
        
        collectionView
            .fillHorizontally()
            .bottom(Constants.zeroValue)
            .Top == timeLabel.Bottom + Constants.viewPadding
        
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
        frontCameraVideoRecordingButton.addTarget(self, action: #selector(btnPressed(_:)), for: .touchDown)
        frontCameraVideoRecordingButton.addTarget(self, action: #selector(btnReleased), for: .touchUpInside)
        rearCameraVideoRecordingButton.addTarget(self, action: #selector(btnPressed(_:)), for: .touchDown)
        rearCameraVideoRecordingButton.addTarget(self, action: #selector(btnReleased), for: .touchUpInside)
        
        viewModel
            .isCameraPermissionGranted
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isGranted in
                guard let self = self else { return }
                if isGranted {
                    self.showCamera()
                } else {
                    self.alert(message: AppConstants.cameraPermissionMessage)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel
            .toastMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.view.makeToast(message.message)
            })
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
            .items
            .bind(to: collectionView.rx.items(cellIdentifier: UserCollectionViewCell.reuseIdentifier,
                                              cellType: UserCollectionViewCell.self)) { (row, element, cell) in
                cell.configure(with: element)
            }
            .disposed(by: disposeBag)
        
        collectionView
            .rx
            .modelSelected(UserVideo.self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] item in
                guard let self = self else { return }
                Router.pushVideoPlayerViewController(self.viewModel.videos, selected: item,
                                                     cameraSide: self.viewModel.cameraViewModel.cameraSide)
            }).disposed(by: disposeBag)
        
    }
    
    @objc private func btnPressed(_ sender: UIButton) {
        sender.animate(duration: Constants.videoRecordingLength, color: .white)
        let cameraSide: CameraSide = sender == frontCameraVideoRecordingButton ? .front : .rear
        viewModel.cameraViewModel.flipCamera(to: cameraSide)
        viewModel.camera(action: .start)
        headerView.video(state: .start)
        showTimer()
    }
    
    @objc private func btnReleased() {
        viewModel.camera(action: .stop)
        headerView.video(state: .stop)
        timer?.invalidate()
        timeLabel.text = ""
    }
    
    private func showTimer() {
        var timePassed = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }
            timePassed += 1
            let minutes = timePassed / 60
            let seconds = timePassed % 60
            self.timeLabel.text = String(format:"%02d:%02d", minutes, seconds)
            if timePassed == Int(Constants.videoRecordingLength) {
                self.btnReleased()
            }
        })
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
            Router.pushCreateGroupViewController(contacts: viewModel.contacts.value,
                                                 side: viewModel.cameraViewModel.cameraSide)
        }
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
    static let timeLabelHeight: CGFloat = 20.0
    static let videoRecordingLength: CGFloat = 10.0
    
    static let logoIcon = "citypeople_logo_splash"
    static let cameraOptionsIcon = "circle_img_green"
    
    static let settings = "Settings"
    static let cancel = "Cancel"
    static let gotoSettings = "Go to Settings"
    static let locationPermissionMessage = "You have denied the location permission, to continue please enable the location permissions from Settings."
}

enum AppConstants {
    static let cameraPermissionMessage = "You have denied the camera permissions, to continue please enable camera permissions from Settings."
}

extension UIButton {
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
