//
//  CreateGroupViewModel.swift
//  CityPeople
//
//  Created by Kamal Kishor on 05/05/22.
//

import Foundation
import SwiftyContacts
import RxRelay
import SwiftUI

protocol CreateGroupViewModelProtocol: ViewModelProtocol {
    var friends: BehaviorRelay<[Friend]> { get }
    var selectedFriends: BehaviorRelay<[Friend]> { get }
    var showLoader: PublishRelay<Bool> { get }
    var isContactsPermissionGranted: PublishRelay<Bool> { get }
    func isAlreadySelected(_ friend: Friend) -> Bool
    func update(with contact: Friend)
    func createGroup(name: String)
    func search(contact keyword: String)
}

class CreateGroupViewModel: CreateGroupViewModelProtocol {
    var friends = BehaviorRelay<[Friend]>(value: [])
    var selectedFriends = BehaviorRelay<[Friend]>(value: [])
    var showLoader = PublishRelay<Bool>()
    var toastMessage = PublishRelay<FieldInputs>()
    var isContactsPermissionGranted = PublishRelay<Bool>()
    private lazy var allFriends = [Friend]()
    
    private let contacts: [CNContact]
    
    init(contacts: [CNContact]) {
        self.contacts = contacts
    }
    
    func onViewDidLoad() {
        fetchFriends()
    }
    
    // MARK: - Private Methods
    private func fetchFriends() {
        var phoneNumbers = [String]()
        contacts.forEach { contact in
            phoneNumbers.append(contentsOf: contact.phoneNumbers.compactMap({$0.value.stringValue.replacingOccurrences(of: " ", with: "")}))
        }
        let params: [String: Any] = [ApiConstants.contacts.rawValue: phoneNumbers]
        showLoader.accept(true)
        Network.request(.contacts, params: params) { [weak self] (result: Result<FriendResponse, String>) in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                self.friends.accept(response.users)
                self.allFriends = response.users
            case let .failure(error):
                self.toastMessage.accept(.custom(message: error))
            }
            self.showLoader.accept(false)
        }
    }
    
    func isAlreadySelected(_ friend: Friend) -> Bool {
        selectedFriends.value.firstIndex(where: {$0.id == friend.id}) != nil
    }
    
    func createGroup(name: String) {
        let params: [String: Any] = [ApiConstants.name.rawValue: name,
                                     ApiConstants.ids.rawValue: selectedFriends.value.map({$0.id})]
        showLoader.accept(true)
        Network.request(.createGroup, params: params) { [weak self] (result: Result<Success, String>) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.toastMessage.accept(.custom(message: "Group Created!"))
            case .failure(let error):
                self.toastMessage.accept(.custom(message: error))
            }
            self.showLoader.accept(false)
        }
    }
    
    func update(with contact: Friend) {
        var selected = selectedFriends.value
        if let index = selected.firstIndex(where: {$0.id == contact.id}) {
            selected.remove(at: index)
        } else { 
            selected.append(contact)
        }
        selectedFriends.accept(selected)
    }
    
    func search(contact keyword: String) {
        if keyword.isEmpty {
            self.friends.accept(allFriends)
        } else {
            let filteredContacts = allFriends.filter { contact in
                (contact.name.range(of: keyword, options: .caseInsensitive) != nil)
            }
            self.friends.accept(filteredContacts)
        }
    }
}
