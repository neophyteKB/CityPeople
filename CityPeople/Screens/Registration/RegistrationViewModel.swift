//
//  RegistrationViewModel.swift
//  CityPeople
//
//  Created by Kamal Kishor on 24/05/22.
//

import Foundation
import RxRelay

protocol RegistrationViewModelProtocol: ViewModelProtocol {
    func isValidated(firstName: String, lastName: String) -> Bool
}

class RegistrationViewModel: RegistrationViewModelProtocol {
    var toastMessage = PublishRelay<FieldInputs>()
    var processRequests = PublishRelay<Void>()
    
    func onViewDidLoad() {
    
    }
    
    func isValidated(firstName: String, lastName: String) -> Bool {
        if firstName.isEmpty {
            toastMessage.accept(.firstName)
            return false
        } else if lastName.isEmpty {
            toastMessage.accept(.lastName)
            return false
        } else {
            return true
        }
    }
    
    private func processAuth() {
        
    }
}
