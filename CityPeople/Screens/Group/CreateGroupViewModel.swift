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
    var groups: BehaviorRelay<[Group]> { get }
    var selectedGroups: BehaviorRelay<[Group]> { get }
    var showLoader: PublishRelay<Bool> { get }
    var isContactsPermissionGranted: PublishRelay<Bool> { get }
    func isAlreadySelected(_ group: Group) -> Bool
    func update(with contact: Group)
    func createGroup(name: String)
    func search(contact keyword: String)
}

class CreateGroupViewModel: CreateGroupViewModelProtocol {
    var groups = BehaviorRelay<[Group]>(value: [])
    var selectedGroups = BehaviorRelay<[Group]>(value: [])
    var showLoader = PublishRelay<Bool>()
    var toastMessage = PublishRelay<FieldInputs>()
    var isContactsPermissionGranted = PublishRelay<Bool>()
    private lazy var allGroups = [Group]()
    
    private let contacts: [CNContact]
    private let cameraSide: CameraSide
    
    init(contacts: [CNContact], cameraSide: CameraSide) {
        self.cameraSide = cameraSide
        self.contacts = contacts
    }
    
    func onViewDidLoad() {
        fetchGroups()
    }
    
    // MARK: - Private Methods
    private func fetchGroups() {
        Network.request(.groups) { [weak self] (result: Result<GroupsResponse, String>) in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                self.groups.accept(response.users)
                self.allGroups = response.users
            case let .failure(error):
                self.toastMessage.accept(.custom(message: error))
            }
            self.showLoader.accept(false)
        }
    }
    
    // MARK: Protocol Methods
    func isAlreadySelected(_ group: Group) -> Bool {
        selectedGroups.value.firstIndex(where: {$0.id == group.id}) != nil
    }
    
    func createGroup(name: String) {
        let params: [String: Any] = [ApiConstants.name.rawValue: name,
                                     ApiConstants.ids.rawValue: selectedGroups.value.map({$0.id})]
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
    
    func update(with contact: Group) {
        var selected = selectedGroups.value
        if let index = selected.firstIndex(where: {$0.id == contact.id}) {
            selected.remove(at: index)
        } else { 
            selected.append(contact)
        }
        selectedGroups.accept(selected)
    }
    
    func search(contact keyword: String) {
        if keyword.isEmpty {
            self.groups.accept(allGroups)
        } else {
            let filteredContacts = allGroups.filter { contact in
                (contact.name.range(of: keyword, options: .caseInsensitive) != nil)
            }
            self.groups.accept(filteredContacts)
        }
    }
}
