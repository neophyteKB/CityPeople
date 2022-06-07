//
//  HomeScreenHeaderView.swift
//  CityPeople
//
//  Created by Kamal Kishor on 25/04/22.
//

import Stevia
import UIKit
import RxSwift
import CoreLocation
import RxRelay
import RxCocoa

protocol HomeScreenHeaderProtocol {
    var isLocationPermissionsDenied: PublishRelay<Void> { get }
    var pushView: PublishRelay<ViewType> { get }
}

class HomeScreenHeaderView: UIView, HomeScreenHeaderProtocol {
    
    static let headerHeight = Constants.cameraHeight
    
    // MARK: - UI Properties
    // Location
    private let locationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image("location")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let locationTitle: UILabel = {
        let locationTitle = UILabel()
        locationTitle.text = "Loading.."
        locationTitle.textAlignment = .center
        locationTitle.font = .font(name: .regular, size: Constants.fontSize)
        return locationTitle
    }()
    
    private lazy var locationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.iconStackViewSpacing
        [locationIcon, locationTitle].forEach(stackView.addArrangedSubview)
        return stackView
    }()
    // ------
    
    // Group
    private let groupIcon: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "add_group"), for: .normal)
        btn.contentMode = .scaleAspectFit
        return btn
    }()
    
    private let groupTitle: UILabel = {
        let groupTitle = UILabel()
        groupTitle.text = "Group"
        groupTitle.textAlignment = .center
        groupTitle.font = .font(name: .regular, size: Constants.fontSize)
        return groupTitle
    }()
    
    private lazy var groupStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.iconStackViewSpacing
        [groupIcon, groupTitle].forEach(stackView.addArrangedSubview)
        return stackView
    }()
    // ------
    
    // Friend
    private let friendIcon: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "add_friends"), for: .normal)
        btn.contentMode = .scaleAspectFit
        return btn
    }()
    
    private let friendTitle: UILabel = {
        let friendTitle = UILabel()
        friendTitle.text = "Friend"
        friendTitle.textAlignment = .center
        friendTitle.font = .font(name: .regular, size: Constants.fontSize)
        return friendTitle
    }()
    
    private lazy var friendStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.iconStackViewSpacing
        [friendIcon, friendTitle].forEach(stackView.addArrangedSubview)
        return stackView
    }()
    // ------
    
    // Horizontal Stack
    private lazy var horizontalMenuStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        [locationStackView, groupStackView, friendStackView].forEach(stackView.addArrangedSubview)
        return stackView
    }()
    
    // Search bar
    private let searchBar: SearchField = {
        let searchTextField = SearchField()
        searchTextField.font = .font(name: .regular, size: Constants.fontSize)
        searchTextField.placeholder = "Search"
        return searchTextField
    }()
    
    // Vertical menu
    private lazy var menuStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.menuStackSpacing
        [horizontalMenuStackView, searchBar].forEach(stackView.addArrangedSubview)
        return stackView
    }()
    
    // Camera
    private lazy var cameraView: CameraView = {
       let cameraView = CameraView(cameraViewModel: cameraViewModel)
        cameraView.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        return cameraView
    }()
    
    // MARK: - Private Properties
    var isLocationPermissionsDenied = PublishRelay<Void>()
    var pushView = PublishRelay<ViewType>()
    
    // MARK: - Private Properties
    private var locationManager = LocationManager.shared
    private var disposeBag = DisposeBag()
    private var location: CLLocation?
    private var cameraViewModel: CameraViewModelProtocol!
    
    // MARK: - Initilizers
    init(cameraViewModel: CameraViewModelProtocol) {
        super.init(frame: .zero)
        
        self.cameraViewModel = cameraViewModel
        setupViewLayouts()
        setupViewBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupViewLayouts() {
        backgroundColor = .white
        subviews {
            menuStackView
            cameraView
        }
        searchBar.height(Constants.searchFieldHeight)
        
        cameraView
            .top(Constants.viewPadding)
            .right(Constants.viewPadding)
            .height(Constants.cameraHeight)
            .width(Constants.cameraWidth)
        
        menuStackView
            .top(2 * Constants.viewPadding)
            .left(Constants.viewPadding)
            .Right == cameraView.Left - Constants.viewPadding
    }
    
    private func setupViewBindings() {
        locationManager
            .permissionDenied
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.locationTitle.text = "-NA-"
                self?.isLocationPermissionsDenied.accept(())
            })
            .disposed(by: disposeBag)
        
        locationManager
            .locality
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] locationName in
                self?.locationTitle.text = locationName
            })
            .disposed(by: disposeBag)
        
        locationManager
            .location
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] location in
                self?.location = location
            })
            .disposed(by: disposeBag)
        
        friendIcon
            .rx
            .tap
            .bind { [weak self] in
                self?.pushView.accept(.friends)
            }
            .disposed(by: disposeBag)
        
        groupIcon
            .rx
            .tap
            .bind { [weak self] _ in
                self?.pushView.accept(.group)
            }
            .disposed(by: disposeBag)
    }
    
    func video(state: VideoAction) {
        if state == .start {
            cameraView.setBorder(with: .cityGreen, of: 2.0, cornerRadius: 0.0)
        } else {
            cameraView.setBorder(with: .white, of: 2.0, cornerRadius: 0.0)
        }
    }
    
    private enum Constants {
        static let screenWidth = UIScreen.main.bounds.size.width
        static let cameraWidth = screenWidth * 0.25
        static let cameraHeight = cameraWidth * (16/9)
        static let fontSize = 12.0
        static let viewPadding = 16.0
        static let menuStackSpacing = 24.0
        static let iconStackViewSpacing = 4.0
        static let searchFieldHeight = 36.0
    }
}

enum ViewType {
    case friends, group
}
