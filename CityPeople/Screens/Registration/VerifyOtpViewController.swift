//
//  VerifyOtpViewController.swift
//  CityPeople
//
//  Created by Kamal Kishor on 26/05/22.
//

import UIKit
import RxSwift
import Stevia

class VerifyOtpViewController: UIViewController {
    
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
        label.text = Constants.verifyYourNumber
        label.textColor = .black
        label.textAlignment = .center
        label.font = .font(name: .semiBold, size: Constants.titleFontSize)
        return label
    }()
    private let subTitleTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .black
        return textView
    }()
    private lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.code
        label.textColor = .cityGreen
        label.font = .font(name: .regular, size: Constants.codeFontSize)
        return label
    }()
    private let otpView: OTPView = {
        let otpView = OTPView(numberOfDigits: Constants.numberOfOtpDigits)
        return otpView
    }()
    private let timerMessageLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.timerMessage
        label.textColor = .black
        label.textAlignment = .center
        label.font = .font(name: .regular, size: Constants.bodyFontSize)
        return label
    }()
    private lazy var resendCodeButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.resendCode, for: .normal)
        button.setTitleColor(.cityGreen, for: .normal)
        button.titleLabel?.font = .font(name: .regular, size: Constants.bodyFontSize)
        return button
    }()
    private lazy var verifyButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.verifyButtonText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .cityGreen
        button.titleLabel?.font = .font(name: .semiBold, size: Constants.verifyFontSize)
        button.contentEdgeInsets = Constants.verifyButtonEdgeInsets
        button.roundCorners(radius: Constants.verifyButtonHeight / 2)
        return button
    }()
    
    // MARK: - Private Properties
    private let viewModel: VerifyOtpViewModelProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    init(viewModel: VerifyOtpViewModelProtocol) {
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
        viewModel.onViewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Private Properties
    private func setupViewLayouts() {
        view.backgroundColor = .white
        subTitleAttributes()
        
        view.subviews {
            backButton
            navigationTitleView
            titleLabel
            subTitleTextView
            codeLabel
            otpView
            timerMessageLabel
            resendCodeButton
            verifyButton
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
        subTitleTextView
            .fillHorizontally(padding: Constants.viewPadding)
            .height(Constants.subtitleTextViewHeight)
            .Top == titleLabel.Bottom + Constants.viewPadding
        codeLabel
            .leading(Constants.viewPadding)
            .Top == subTitleTextView.Bottom + Constants.viewVerticalSpacing
        otpView
            .fillHorizontally(padding: Constants.viewPadding)
            .height(Constants.otpInputViewHeight)
            .Top == codeLabel.Bottom + Constants.viewPadding
        timerMessageLabel
            .fillHorizontally(padding: Constants.viewPadding)
            .Top == otpView.Bottom + Constants.viewVerticalSpacing
        resendCodeButton
            .fillHorizontally(padding: Constants.viewPadding)
            .Top == timerMessageLabel.Bottom
        verifyButton
            .centerHorizontally()
            .height(Constants.verifyButtonHeight)
            .Top == resendCodeButton.Bottom + (2 * Constants.viewVerticalSpacing)
    }
    
    private func setupViewBindings() {
        verifyButton
            .rx
            .tap
            .bind { [weak self] in
                guard let self = self else { return }
                if self.otpView.otpValue.count < Constants.numberOfOtpDigits {
                    self.view.makeToast(FieldInputs.otp.message)
                    return
                }
                self.viewModel.process(otp: self.otpView.otpValue)
            }
            .disposed(by: disposeBag)
        
        resendCodeButton
            .rx
            .tap
            .bind { [weak self] in
                self?.otpView.reset()
                self?.viewModel.resendOtp()
            }
            .disposed(by: disposeBag)
        
        viewModel
            .toastMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] messageType in
                self?.view.makeToast(messageType.message)
        }).disposed(by: disposeBag)
        
        viewModel
            .timeLeft
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] time in
                guard let self = self else { return }
                self.timerMessageLabel.text = Constants.timerMessage + time
        }).disposed(by: disposeBag)
        
    }
    
    private func subTitleAttributes() {
        let completeString = Constants.timerMessage + viewModel.phoneNumber + ". " + Constants.changeText
        let attributedString = NSMutableAttributedString(string: completeString)
        let changeRange = (completeString as NSString).range(of: Constants.changeText)
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.cityGreen,
                          NSAttributedString.Key.font: UIFont.font(name: .semiBold, size: Constants.bodyFontSize)]
        attributedString.addAttributes(attributes, range: changeRange)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.font(name: .regular, size: Constants.bodyFontSize),
                                      range: NSRange.init(location: 0, length: completeString.count))
        subTitleTextView.attributedText = attributedString
        subTitleTextView.textAlignment = .center
    }
    
    // MARK: - Constants
    private enum Constants {
        static let titleFontSize: CGFloat = 24.0
        static let bodyFontSize: CGFloat = 12.0
        static let codeFontSize: CGFloat = 14.0
        static let numberOfOtpDigits: Int = 6
        static let verifyButtonHeight: CGFloat = 44.0
        static let otpInputViewHeight: CGFloat = 44.0
        static let subtitleTextViewHeight: CGFloat = 44.0
        static let verifyFontSize: CGFloat = 16.0
        static let navigationLabelHeight = 24.0
        static let viewPadding: CGFloat = 16.0
        static let viewVerticalSpacing: CGFloat = 40.0
        static let verifyButtonEdgeInsets = UIEdgeInsets(top: 8, left: 32, bottom: 8, right: 32)
        static let logoIcon = "citypeople_logo_splash"
        static let dropDownIcon = "dropdown_arrow"
        static let backButtonIcon = "black_back_arrow"
        static let code = "CODE"
        static let resendCode = "Resend Code"
        static let verifyButtonText = "Verify"
        static let verifyYourNumber = "Verify your number"
        static let sixDigitCodeMessage = "Enter the six digit code we've sent by text to"
        static let timerMessage = "This text should arrive within "
        static let changeText = "Change"
    }

}
