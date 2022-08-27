//
//  VideoPlayerViewController.swift
//  CityPeople
//
//  Created by Kamal Kishor on 08/06/22.
//

import AVKit
import UIKit
import Stevia
import RxSwift
import RxCocoa

class VideoPlayerViewController: UIViewController {

    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: Constants.backIcon), for: .normal)
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .font(name: .regular, size: Constants.fontSize)
        return label
    }()
    
    private let locationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image(Constants.locationIcon)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let locationTitle: UILabel = {
        let locationTitle = UILabel()
        locationTitle.textAlignment = .center
        locationTitle.textColor = .white
        locationTitle.font = .font(name: .regular, size: Constants.fontSize)
        return locationTitle
    }()
    
    private lazy var cameraView: CameraView = {
       let cameraView = CameraView(cameraViewModel: cameraViewModel)
        cameraView.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        return cameraView
    }()
    
    private let collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.itemSize = CGSize(width: Constants.screenWidth, height: Constants.videoViewHeight)
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(UserVideoViewCell.self, forCellWithReuseIdentifier: UserVideoViewCell.reuseIdentifier)
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    private let rearCameraVideoRecordingButton = UIButton()
    private let frontCameraVideoRecordingButton = UIButton()
    
    private let viewModel: VideoPlayerViewModelProtocol
    private var cameraViewModel: CameraViewModelProtocol
    private let disposeBag = DisposeBag()
    
    init(viewModel: VideoPlayerViewModelProtocol, side: CameraSide) {
        self.viewModel = viewModel
        cameraViewModel = CameraViewModel(cameraSide: side)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewLayouts()
        setupViewBindings()
        viewModel.onViewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    private func setupViewLayouts() {
        view.backgroundColor = .white
        
        view.subviews {
            collectionView
            locationIcon
            locationTitle
            nameLabel
            backButton
            cameraView
            frontCameraVideoRecordingButton
            rearCameraVideoRecordingButton
        }
        
        
        resetControls()
        locationTitle.text = LocationManager.shared.locationString
        
        collectionView
            .fillHorizontally()
            .height(Constants.videoViewHeight)
            .Top == view.safeAreaLayoutGuide.Top
        
        locationIcon
            .leading(Constants.viewPadding)
            .Top == view.safeAreaLayoutGuide.Top + Constants.viewPadding
        
        nameLabel.Leading == locationIcon.Trailing + Constants.viewPadding
        nameLabel.CenterY == locationIcon.CenterY
        
        locationTitle.Top == locationIcon.Bottom + Constants.viewPadding
        locationTitle.CenterX == locationIcon.CenterX
        
        cameraView
            .right(Constants.viewPadding)
            .width(Constants.cameraWidth)
            .height(Constants.cameraHeight)
            .Top == view.safeAreaLayoutGuide.Top + Constants.viewPadding
        
        backButton.Top == locationIcon.Top
        backButton.Trailing == cameraView.Leading - Constants.viewPadding
        
        rearCameraVideoRecordingButton
            .centerHorizontally()
            .size(Constants.rearCameraButtonSizeDimension)
            .Bottom == frontCameraVideoRecordingButton.Top + Constants.recordingButtonIntersectionsSpacing
        
        frontCameraVideoRecordingButton
            .centerHorizontally()
            .size(Constants.frontEndCameraButtonSizeDimension)
            .Bottom == view.safeAreaLayoutGuide.Bottom
    }
    
    private func resetControls() {
        DispatchQueue.main.async {
            self.frontCameraVideoRecordingButton.animate(duration: 0, color: .cityGreen)
            self.rearCameraVideoRecordingButton.animate(duration: 0, color: .cityGreen)
        }
    }
    
    private func setupViewBindings() {
        
        frontCameraVideoRecordingButton.addTarget(self, action: #selector(btnPressed(_:)), for: .touchDown)
        frontCameraVideoRecordingButton.addTarget(self, action: #selector(btnReleased(_:)), for: .touchUpInside)
        rearCameraVideoRecordingButton.addTarget(self, action: #selector(btnPressed(_:)), for: .touchDown)
        rearCameraVideoRecordingButton.addTarget(self, action: #selector(btnReleased(_:)), for: .touchUpInside)
        
        backButton
            .rx
            .tap
            .bind {
                Router.popVC()
            }
            .disposed(by: disposeBag)
        
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
        
        viewModel
            .allVideos
            .bind(to: collectionView.rx.items(cellIdentifier: UserVideoViewCell.reuseIdentifier,
                                              cellType: UserVideoViewCell.self)) { [weak self] (row, element, cell) in
                guard let self = self else { return }
                cell.configure(userVideo: element)
                cell.errorMessage = { [weak self] error in
                    self?.view.makeToast(error.message)
                }
                cell.show = { toward in
                    self.move(to: toward)
                }
                self.nameLabel.text = element.name
            }
            .disposed(by: disposeBag)
        
        viewModel
            .showLoader
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] showLoader in
                self?.makeToast(isVisible: showLoader)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .toastMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] toast in
                self?.view.makeToast(toast.message)
            })
            .disposed(by: disposeBag)
        
        cameraViewModel
            .video
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] videoLink in
                self?.viewModel.sendVideo(videoLink)
            })
            .disposed(by: disposeBag)
        
        cameraViewModel
            .stopped
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.resetControls()
            })
            .disposed(by: disposeBag)
    }
    
    private func showCamera() {
        cameraViewModel.videoAction.accept(.show)
    }
    
    private func makeToast(isVisible: Bool) {
        view.isUserInteractionEnabled = !isVisible
        if isVisible {
            view.makeToastActivity(.center)
        } else {
            view.hideToastActivity()
        }
    }
    
    private func move(to side: MoveTo) {
        if side == .next {
            let next = viewModel.selectedIndex + 1
            if next < viewModel.allVideosCount {
                collectionView.scrollToItem(at: IndexPath(item: next, section: 0), at: .centeredHorizontally, animated: true)
            }
        } else {
            let previous = viewModel.selectedIndex - 1
            if previous < viewModel.allVideosCount {
                collectionView.scrollToItem(at: IndexPath(item: previous, section: 0), at: .centeredHorizontally, animated: true)
            } 
        }
    }
    
    @objc private func btnPressed(_ sender: UIButton) {
        sender.animate(duration: Constants.videoRecordingLength, color: .white)
        let cameraSide: CameraSide = sender == frontCameraVideoRecordingButton ? .front : .rear
        cameraViewModel.flipCamera(to: cameraSide)
        cameraViewModel.videoAction.accept(.start)
        cameraView.setBorder(with: .cityGreen, of: 4.0, cornerRadius: 0.0)
    }
    
    @objc private func btnReleased(_ sender: UIButton) {
        cameraViewModel.videoAction.accept(.stop)
        cameraView.setBorder(with: .white, of: 4.0, cornerRadius: 0.0)
        sender.animate(duration: 0.0, color: .cityGreen)
    }

    private enum Constants {
        static let locationIcon = "location"
        static let backIcon = "circle_back_button"
        static let cameraPermissionMessage = "You have denied the camera permissions, to continue please enable camera permissions from Settings."
        
        static let screenWidth = UIScreen.main.bounds.size.width
        static let cameraWidth = screenWidth * 0.25
        static let cameraHeight = cameraWidth * (16/9)
        static let videoViewHeight = screenWidth * (16/9)
        static let fontSize = 12.0
        static let viewPadding = 16.0
        static let rearCameraButtonSizeDimension: CGFloat = 72
        static let frontEndCameraButtonSizeDimension: CGFloat = 100
        static let recordingButtonIntersectionsSpacing: CGFloat = 20.0
        static let recordingButtonsBorderWidth: CGFloat = 8.0
        static let videoRecordingLength: CGFloat = 10.0
    }
}
