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
    func action(friend: User, isRejected: Bool)
    func search(contact keyword: String)
}

class ContactsViewModel: ContactsProtocol {
    var toastMessage = PublishRelay<FieldInputs>()
    var showLoader = PublishRelay<Bool>()
    var isContactsPermissionGranted = PublishRelay<Bool>()
    var allContacts = BehaviorRelay<[User]>(value: [])
    private lazy var users = [User]()
    
    private let contacts: [CNContact]
    init(contacts: [CNContact]) {
        self.contacts = contacts
    }
    
    func onViewDidLoad() {
        fetchFriends()
    }
    
    // MARK: - Private Methods
    private func fetchFriends() {
        var _users = [User]()
        contacts.forEach { contact in
            _users.append(contentsOf: contact.phoneNumbers.compactMap { phoneNumber in
                User(phone: phoneNumber.value.stringValue.replacingOccurrences(of: " ", with: ""),
                     name: [contact.familyName, contact.givenName].joined(separator: " "),
                     id: 0,
                     isRegistered: false,
                     requestStatus: .none,
                     isFriend: false)
            })
        }
        self.users = _users
        let params: [String: Any] = [ApiConstants.contacts.rawValue: _users.compactMap({$0.phone})]
        showLoader.accept(true)
        Network.request(.contacts, params: params) { [weak self] (result: Result<FriendResponse, String>) in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                for friend in response.users {
                    if let index = _users.firstIndex(where: {$0.phone == friend.phone}) {
                        _users.remove(at: index)
                        let user = User(phone: friend.phone, name: friend.name, id: friend.id, isRegistered: true, requestStatus: friend.requestStatus, isFriend: friend.alreadyFriend)
                        _users.insert(user, at: 0)
                    }
                }
                self.allContacts.accept(_users)
            case let .failure(error):
                self.toastMessage.accept(.custom(message: error))
            }
            self.showLoader.accept(false)
        }
    }
    
    func action(friend: User, isRejected: Bool = false) {
        if friend.requestStatus == .none {
            add(params: [ApiConstants.friendId.rawValue: friend.id])
        } else if friend.requestStatus == .requestReceived {
            acceptRejectRequest(params: [ApiConstants.friendId.rawValue: friend.id,
                                   ApiConstants.accept.rawValue: isRejected ? 0 : 1])
        }
    }
    
    func add(params: [String: Any]) {
        showLoader.accept(true)
        Network.request(.addFriend, params: params) { [weak self] (result: Result<Success, String>) in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                if success.status {
                    self.toastMessage.accept(.custom(message: success.message ?? ""))
                }
            case .failure(let error):
                self.toastMessage.accept(.custom(message: error))
            }
            self.showLoader.accept(false)
        }
    }
    
    private func acceptRejectRequest(params: [String: Any]) {
        showLoader.accept(true)
        Network.request(.accept, params: params) { [weak self] (result: Result<Success, String>) in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                self.toastMessage.accept(.custom(message: success.message ?? ""))
            case .failure(let error):
                self.toastMessage.accept(.custom(message: error))
            }
            self.showLoader.accept(false)
        }
    }
    
    func search(contact keyword: String) {
        if keyword.isEmpty {
            self.allContacts.accept(users)
        } else {
            let filteredContacts = users.filter { contact in
                (contact.name.range(of: keyword, options: .caseInsensitive) != nil)
            }
            self.allContacts.accept(filteredContacts)
        }
    }
}
