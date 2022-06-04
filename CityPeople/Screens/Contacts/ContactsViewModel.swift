//
//  ContactsViewModel.swift
//  CityPeople
//
//  Created by Kamal Kishor on 03/05/22.
//

import Foundation
import SwiftyContacts
import RxRelay

protocol ContactsProtocol: ViewModelProtocol {
    var allContacts: BehaviorRelay<[User]> { get }
    var showLoader: PublishRelay<Bool> { get }
    func add(friend: User)
}

class ContactsViewModel: ContactsProtocol {
    var toastMessage = PublishRelay<FieldInputs>()
    var showLoader = PublishRelay<Bool>()
    var isContactsPermissionGranted = PublishRelay<Bool>()
    var allContacts = BehaviorRelay<[User]>(value: [])
    
    private let contacts: [CNContact]
    init(contacts: [CNContact]) {
        self.contacts = contacts
    }
    
    func onViewDidLoad() {
        fetchFriends()
    }
    
    // MARK: - Private Methods
    private func fetchFriends() {
        var users = [User]()
        contacts.forEach { contact in
            users.append(contentsOf: contact.phoneNumbers.compactMap { phoneNumber in
                User(phone: phoneNumber.value.stringValue.replacingOccurrences(of: " ", with: ""),
                     name: [contact.familyName, contact.givenName].joined(separator: " "),
                     id: 0,
                     isRegistered: false,
                     requestStatus: 0,
                     isFriend: false)
            })
        }
        let params: [String: Any] = [ApiConstants.contacts.rawValue: users.compactMap({$0.phone})]
        showLoader.accept(true)
        Network.request(.contacts, params: params) { [weak self] (result: Result<FriendResponse, String>) in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                for friend in response.users {
                    if let index = users.firstIndex(where: {$0.phone == friend.phone}) {
                        users.remove(at: index)
                        let user = User(phone: friend.phone, name: friend.name, id: friend.id, isRegistered: true, requestStatus: friend.requestStatus, isFriend: friend.alreadyFriend)
                        users.insert(user, at: 0)
                    }
                }
                self.allContacts.accept(users)
            case let .failure(error):
                self.toastMessage.accept(.custom(message: error))
            }
            self.showLoader.accept(false)
        }
    }
    
    func add(friend: User) {
        let params = [ApiConstants.friendId.rawValue: friend.id]
        showLoader.accept(true)
        Network.request(.addFriend, params: params) { [weak self] (result: Result<AddFriendResponse, String>) in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                if success.status {
                    self.toastMessage.accept(.custom(message: "Friend added!"))
                }
            case .failure(let error):
                self.toastMessage.accept(.custom(message: error))
            }
            self.showLoader.accept(false)
        }
    }
    
    func respondRequest(_ status: Int) {
        
    }
}
