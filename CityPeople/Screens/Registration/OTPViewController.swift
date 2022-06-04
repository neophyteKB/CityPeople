//
//  OTPViewController.swift
//  CityPeople
//
//  Created by Kamal Kishor on 24/05/22.
//

import UIKit
import RxSwift
import Stevia
import CountryPicker

class OTPViewController: UIViewController {

    // MARK: - UI Components
    private let backButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: Constants.backButtonIcon), for: .normal)
        return button
    }()
    private let navigationTitleView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.logoIcon)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.whatNumberTitle
        label.textColor = .black
        label.textAlignment = .center
        label.font = .font(name: .semiBold, size: Constants.titleFontSize)
        return label
    }()
    private let topSubTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.topSubTitle
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .font(name: .regular, size: Constants.bodyFontSize)
        return label
    }()
    private let mobileNumberLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.mobileNumber
        label.textColor = .lightGray
        label.font = .font(name: .regular, size: Constants.fieldsFontSize)
        return label
    }()
    private let mobileNumberField: UITextField  = {
        let textField = UITextField()
        textField.textColor = .black
        textField.font = .font(name: .regular, size: Constants.fieldsFontSize)
        textField.placeholder = Constants.enterMobileNumber
        textField.keyboardType = .numberPad
        return textField
    }()
    private let dropdownImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.dropDownIcon)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let countryCodeButton: UIButton = {
       let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .font(name: .regular, size: Constants.fieldsFontSize)
        button.imageEdgeInsets = Constants.countryCodeImageInsets
        return button
    }()
    private let mobileNumberLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    private lazy var bottomDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.bottomDescription
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .font(name: .regular, size: Constants.bodyFontSize)
        return label
    }()
    private lazy var continueButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.continueTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .cityGreen
        button.titleLabel?.font = .font(name: .semiBold, size: Constants.continueFontSize)
        button.contentEdgeInsets = Constants.continueButtonEdgeInsets
        button.roundCorners(radius: Constants.continueButtonHeight / 2)
        return button
    }()
    
    // MARK: - Private Properties
    private let viewModel: OTPViewModelProtocol
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Initializers
    init(viewModel: OTPViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewLayouts()
        setupViewBindings()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Private Methods
    private func setupViewLayouts() {
        view.backgroundColor = .white
        
        view.subviews {
            backButton
            navigationTitleView
            titleLabel
            topSubTitleLabel
            mobileNumberLabel
            countryCodeButton
            dropdownImageView
            mobileNumberField
            mobileNumberLine
            bottomDescriptionLabel
            continueButton
        }
        
        navigationTitleView
            .fillHorizontally()
            .height(Constants.navigationLabelHeight)
            .Top == view.safeAreaLayoutGuide.Top + Constants.viewPadding
        backButton
            .leading(Constants.viewPadding)
            .CenterY == navigationTitleView.CenterY
        titleLabel
            .fillHorizontally(padding: Constants.viewPadding)
            .Top == navigationTitleView.Bottom + Constants.viewVerticalSpacing
        topSubTitleLabel
            .fillHorizontally(padding: Constants.viewPadding)
            .Top == titleLabel.Bottom + Constants.viewVerticalSpacing
        mobileNumberLabel
            .leading(Constants.viewPadding)
            .Top == topSubTitleLabel.Bottom + Constants.viewVerticalSpacing
        countryCodeButton
            .leading(Constants.viewPadding)
            .width(Constants.countryCodeWidth)
            .height(Constants.countryCodeHeight)
            .Top == mobileNumberLabel.Bottom + Constants.fieldSpacing
        dropdownImageView.CenterY == countryCodeButton.CenterY
        dropdownImageView.Leading == countryCodeButton.Trailing + Constants.dropdownIconLeading
        dropdownImageView.CenterY == countryCodeButton.CenterY
        mobileNumberField.trailing(Constants.viewPadding)
        mobileNumberField.Leading == dropdownImageView.Trailing + Constants.viewPadding
        mobileNumberField.CenterY == countryCodeButton.CenterY
        mobileNumberLine
            .height(Constants.unitValue)
            .fillHorizontally(padding: Constants.viewPadding)
            .Top == countryCodeButton.Bottom + Constants.unitValue
        bottomDescriptionLabel
            .fillHorizontally(padding: Constants.viewPadding)
            .Top == mobileNumberLine.Bottom + Constants.viewVerticalSpacing
        continueButton
            .centerHorizontally()
            .height(Constants.continueButtonHeight)
            .Top == bottomDescriptionLabel.Bottom + Constants.viewVerticalSpacing
    }
    
    private func setupViewBindings() {
        countryCodeButton
            .rx
            .tap
            .bind { [weak self] in
                self?.showCountryPicker()
            }
            .disposed(by: disposeBag)
        
        backButton
            .rx
            .tap
            .bind {
                Router.popVC()
            }
            .disposed(by: disposeBag)
        
        viewModel
            .country
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] country in
                self?.countryCodeButton.setImage(country.flag, for: .normal)
                self?.countryCodeButton.setTitle(country.dialingCode, for: .normal)
            })
            .disposed(by: disposeBag)
        
        mobileNumberField
            .rx
            .text
            .orEmpty
            .map { String($0.prefix(10))}
            .bind(to: mobileNumberField.rx.text)
            .disposed(by: disposeBag)
        
        continueButton
            .rx
            .tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.viewModel.validate(phone: self.mobileNumberField.text!)
            }
            .disposed(by: disposeBag)
        
        viewModel
            .toastMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] messageType in
                self?.view.makeToast(messageType.message)
        }).disposed(by: disposeBag)
        
        viewModel
            .userRequestModel
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { model in
                Router.pushVerifyOtpViewController(userModel: model)
            })
            .disposed(by: disposeBag)
    }
    
    private func showCountryPicker() {
        CountryPickerWithSectionViewController.presentController(on: self, configuration: { countryController in
            countryController.configuration.flagStyle = .circular
            countryController.favoriteCountriesLocaleIdentifiers = ["IN", "US"]
        }) { [weak self] country in
            self?.viewModel.country.accept(country)
        }
    }
    
    private enum Constants {
        static let titleFontSize: CGFloat = 24.0
        static let fieldsFontSize: CGFloat = 18.0
        static let continueFontSize: CGFloat = 16.0
        static let bodyFontSize: CGFloat = 12.0
        static let continueButtonHeight: CGFloat = 44.0
        static let unitValue: CGFloat = 1.0
        static let viewPadding: CGFloat = 16.0
        static let fieldSpacing: CGFloat = 8.0
        static let dropdownIconLeading: CGFloat = -4.0
        static let viewVerticalSpacing: CGFloat = 40.0
        static let navigationLabelHeight = 24.0
        static let countryCodeHeight = 28.0
        static let countryCodeWidth = 88.0
        static let continueButtonEdgeInsets = UIEdgeInsets(top: 8, left: 32, bottom: 8, right: 32)
        static let countryCodeImageInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 52)
        static let logoIcon = "citypeople_logo_splash"
        static let dropDownIcon = "dropdown_arrow"
        static let backButtonIcon = "black_back_arrow"
        static let whatNumberTitle = "What's your number"
        static let topSubTitle = "We protect our community by making sure everyone on citypeople is real"
        static let mobileNumber = "MOBILE NUMBER"
        static let enterMobileNumber = "Enter Mobile Number"
        static let bottomDescription = "Citypeople will send you a text with a verification code Message and data rates may apply."
        static let continueTitle = "Continue"
    }

}
