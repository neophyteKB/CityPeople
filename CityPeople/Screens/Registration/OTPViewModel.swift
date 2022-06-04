//
//  OTPViewModel.swift
//  CityPeople
//
//  Created by Kamal Kishor on 24/05/22.
//

import Foundation
import CountryPicker
import RxRelay
import FirebaseAuth

protocol OTPViewModelProtocol: ViewModelProtocol {
    var country: BehaviorRelay<Country> { get }
    var userRequestModel: PublishRelay<UserRequest> { get }
    func validate(phone: String)
}

class OTPViewModel: OTPViewModelProtocol {
    var toastMessage = PublishRelay<FieldInputs>()
    var userRequestModel = PublishRelay<UserRequest>()
    var country = BehaviorRelay<Country>(value: CountryManager.shared.currentCountry ?? Country(countryCode: "IN"))
    
    private let firstName: String
    private let lastName: String
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    func onViewDidLoad() {
        
    }
    
    func validate(phone: String) {
        if phone.isEmpty {
            toastMessage.accept(.mobileNumber)
        } else {
            let completePhoneNumber = (country.value.dialingCode ?? "+1") + phone
            processPhoneAuth(for: completePhoneNumber)
        }
    }
    
    private func processPhoneAuth(for phoneNumber: String) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
            guard let self = self else { return }
            if let verificationID = verificationID {
                let model = UserRequest(firstName: self.firstName,
                                        lastName: self.lastName,
                                        country: self.country.value,
                                        phoneNumber: phoneNumber,
                                        verificationId: verificationID)
                self.userRequestModel.accept(model)
            } else if let error = error {
                self.toastMessage.accept(.custom(message: error.localizedDescription))
            }
        }
    }
}
