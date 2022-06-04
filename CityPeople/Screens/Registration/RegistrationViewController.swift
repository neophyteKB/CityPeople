//
//  RegistrationViewController.swift
//  CityPeople
//
//  Created by Kamal Kishor on 24/05/22.
//

import UIKit
import RxSwift
import Stevia
import Toast

class RegistrationViewController: UIViewController {

    // MARK: - UI Components
    private let navigationTitleView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.logoIcon)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.whatNameTitle
        label.textColor = .black
        label.textAlignment = .center
        label.font = .font(name: .semiBold, size: Constants.titleFontSize)
        return label
    }()
    private lazy var firstNameLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.firstName.uppercased()
        label.textColor = .lightGray
        label.font = .font(name: .regular, size: Constants.fieldsFontSize)
        return label
    }()
    private lazy var firstNameField: UITextField  = {
        let textField = UITextField()
        textField.textColor = .black
        textField.font = .font(name: .regular, size: Constants.fieldsFontSize)
        textField.placeholder = Constants.firstName
        return textField
    }()
    private let firstNameLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    private lazy var lastNameLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.lastName.uppercased()
        label.textColor = .lightGray
        label.font = .font(name: .regular, size: Constants.fieldsFontSize)
        return label
    }()
    private lazy var lastNameField: UITextField  = {
        let textField = UITextField()
        textField.textColor = .black
        textField.font = .font(name: .regular, size: Constants.fieldsFontSize)
        textField.placeholder = Constants.lastName
        return textField
    }()
    private let lastNameLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    private let termsTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .black
        return textView
    }()
    private lazy var continueButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.continueAccept, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .cityGreen
        button.titleLabel?.font = .font(name: .semiBold, size: Constants.continueFontSize)
        button.contentEdgeInsets = Constants.continueButtonEdgeInsets
        button.roundCorners(radius: Constants.continueButtonHeight / 2)
        return button
    }()
    
    // MARK: - Private Properties
    private let viewModel: RegistrationViewModelProtocol
    private let disposeBag = DisposeBag()
    
    init(viewModel: RegistrationViewModelProtocol) {
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
    
    private func setupViewLayouts() {
        view.backgroundColor = .white
        
        view.subviews {
            navigationTitleView
            titleLabel
            firstNameLabel
            firstNameField
            firstNameLine
            lastNameLabel
            lastNameField
            lastNameLine
            termsTextView
            continueButton
        }
        
        navigationTitleView
            .fillHorizontally()
            .height(Constants.navigationLabelHeight)
            .Top == view.safeAreaLayoutGuide.Top + Constants.viewPadding
        
        titleLabel
            .fillHorizontally(padding: Constants.viewPadding)
            .height(Constants.titleLabelHeight)
            .Top == navigationTitleView.Bottom + Constants.viewVerticalSpacing
        
        firstNameLabel
            .leading(Constants.viewPadding)
            .height(Constants.fieldLabelHeight)
            .Top == titleLabel.Bottom + Constants.viewVerticalSpacing
        
        firstNameField
            .fillHorizontally(padding: Constants.viewPadding)
            .height(Constants.textFieldHeight)
            .Top == firstNameLabel.Bottom + Constants.fieldSpacing
        
        firstNameLine
            .fillHorizontally(padding: Constants.viewPadding)
            .height(Constants.unitValue)
            .Top == firstNameField.Bottom + Constants.unitValue
        
        lastNameLabel
            .leading(Constants.viewPadding)
            .height(Constants.fieldLabelHeight)
            .Top == firstNameLine.Bottom + Constants.lastNameLabelTopMargin
        
        lastNameField
            .fillHorizontally(padding: Constants.viewPadding)
            .height(Constants.textFieldHeight)
            .Top == lastNameLabel.Bottom + Constants.fieldSpacing
        
        lastNameLine
            .fillHorizontally(padding: Constants.viewPadding)
            .height(Constants.unitValue)
            .Top == lastNameField.Bottom + Constants.unitValue
        
        termsTextView
            .fillHorizontally(padding: Constants.viewPadding)
            .height(Constants.termsViewHeight)
            .Top == lastNameLine.Bottom + Constants.viewVerticalSpacing
        
        continueButton
            .centerHorizontally()
            .height(Constants.continueButtonHeight)
            .Top == termsTextView.Bottom + Constants.viewVerticalSpacing
    }
    
    private func setupViewBindings() {
        addAttributesToTerms()
        
        continueButton
            .rx
            .tap
            .bind { [weak self] in
                guard let self = self else { return }
                let firstName = self.firstNameField.text ?? ""
                let lastName = self.lastNameField.text ?? ""
                if self.viewModel.isValidated(firstName: firstName,
                                              lastName: lastName) {
                    Router.pushOtpViewController(firstName: firstName, lastName: lastName)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel
            .toastMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] messageType in
                guard let self = self else { return }
                self.view.makeToast(messageType.message)
            })
            .disposed(by: disposeBag)
    }
    
    private func addAttributesToTerms() {
        let attributedString = NSMutableAttributedString(string: Constants.termsText)
        let privacyPolicyRange = (Constants.termsText as NSString).range(of: Constants.privacyPolicy)
        let termsOfServiceRange = (Constants.termsText as NSString).range(of: Constants.termsOfService)
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.cityGreen,
                          NSAttributedString.Key.font: UIFont.font(name: .semiBold, size: Constants.termsFontSize)]
        attributedString.addAttributes(attributes, range: privacyPolicyRange)
        attributedString.addAttributes(attributes, range: termsOfServiceRange)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.font(name: .regular, size: Constants.termsFontSize),
                                      range: NSRange.init(location: 0, length: Constants.termsText.count))
        termsTextView.attributedText = attributedString
        termsTextView.textAlignment = .center
    }

    private enum Constants {
        static let titleFontSize: CGFloat = 24.0
        static let fieldsFontSize: CGFloat = 14.0
        static let continueFontSize: CGFloat = 16.0
        static let termsFontSize: CGFloat = 12.0
        static let unitValue: CGFloat = 1.0
        static let viewPadding: CGFloat = 16.0
        static let fieldSpacing: CGFloat = 8.0
        static let lastNameLabelTopMargin: CGFloat = 28.0
        static let viewVerticalSpacing: CGFloat = 40.0
        static let navigationLabelHeight = 24.0
        static let titleLabelHeight = 32.0
        static let fieldLabelHeight = 20.0
        static let textFieldHeight = 28.0
        static let termsViewHeight = 60.0
        static let continueButtonHeight: CGFloat = 44.0
        static let continueButtonEdgeInsets = UIEdgeInsets(top: 8, left: 32, bottom: 8, right: 32)
        
        static let logoIcon = "citypeople_logo_splash"
        
        static let whatNameTitle = "What is your name"
        static let firstName = "First Name"
        static let lastName = "Last Name"
        static let termsText = "By tapping \"Continue & Accept\", you acknowledge that you have read the Privacy Policy and agree to the Terms of Service."
        static let continueAccept = "Continue & Accept"
        static let privacyPolicy = "Privacy Policy"
        static let termsOfService = "Terms of Service"
    }
}
