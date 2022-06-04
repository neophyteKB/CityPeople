//
//  VerifyOtpViewModel.swift
//  CityPeople
//
//  Created by Kamal Kishor on 26/05/22.
//

import Foundation
import FirebaseAuth
import RxRelay

protocol VerifyOtpViewModelProtocol: ViewModelProtocol {
    var timeLeft: PublishRelay<String> { get }
    var phoneNumber: String { get }
    func process(otp: String)
    func resendOtp()
}

class VerifyOtpViewModel: VerifyOtpViewModelProtocol {
    
    var toastMessage = PublishRelay<FieldInputs>()
    var timeLeft = PublishRelay<String>()
    var phoneNumber: String {
        userModel.phoneNumber
    }
    private let userModel: UserRequest
    private var verificationId: String
    init(userRequestModel: UserRequest) {
        self.userModel = userRequestModel
        self.verificationId = userModel.verificationId
    }
    
    func onViewDidLoad() {
        startTimer()
    }
    
    func resendOtp() {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
            guard let self = self else { return }
            if let verificationID = verificationID {
                self.verificationId = verificationID
                self.startTimer()
            } else if let error = error {
                self.toastMessage.accept(.custom(message: error.localizedDescription))
            }
        }
    }
    func process(otp: String) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId,
                                                verificationCode: otp)
        Auth.auth().signIn(with: credential) { [weak self] auth, error in
            guard let self = self else { return }
            if auth != nil {
                Network.generateFirebaseToken { isGenerated in
                    if isGenerated {
                        UserDefaults.standard.set(phone: self.phoneNumber)
                        self.saveUserInfo()
                    }
                }
            } else if let error = error {
                self.toastMessage.accept(.custom(message: error.localizedDescription))
            }
        }
    }
    
    private func saveUserInfo() {
        let name = [userModel.firstName, userModel.lastName].joined(separator: " ")
        let params: [String: Any] = [ApiConstants.name.rawValue: name]
        Network.request(.user, params: params) { [weak self] (result: Result<UserResponse, String>) in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                print(user)
            case .failure(let error):
                self.toastMessage.accept(.custom(message: error))
            }
        }
    }
    
    private func startTimer() {
        var maxtime = Constants.seconds
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            maxtime -= 1
            if maxtime == 0 {
                timer.invalidate()
            }
            self.timeLeft.accept("\(maxtime)s")
        }
    }
    
    private enum Constants {
        static let seconds = 10
    }
}
