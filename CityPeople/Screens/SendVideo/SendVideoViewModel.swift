//
//  SendVideoViewModel.swift
//  CityPeople
//
//  Created by Kamal Kishor on 03/06/22.
//

import Foundation
import SwiftyContacts
import RxRelay

protocol SendVideoViewModelProtocol: ViewModelProtocol {
    var showLoader: PublishRelay<Bool> { get }
    var videoSent: PublishRelay<Bool> { get}
    var reloadTableView: PublishRelay<Void> { get }
    var videoUrl: URL { get }
    var groups: BehaviorRelay<[Group]> { get }
    func update(with contact: Group)
    func isAlreadySelected(_ group: Group) -> Bool
    func sendVideo(to group: Group)
    func search(contact keyword: String)
}

class SendVideoViewModel: SendVideoViewModelProtocol {
    var toastMessage = PublishRelay<FieldInputs>()
    var reloadTableView = PublishRelay<Void>()
    var groups = BehaviorRelay<[Group]>(value: [])
    var showLoader = PublishRelay<Bool>()
    var videoSent = PublishRelay<Bool>()
    var videoUrl: URL { self.videoLink }
    
    private let videoLink: URL
    private let contacts: [CNContact]
    private lazy var allGroups = [Group]()
    private lazy var selectedFriends = [Group]()
    
    init(videoLink: URL, contacts: [CNContact]) {
        self.videoLink = videoLink
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
    
    func isAlreadySelected(_ group: Group) -> Bool {
        selectedFriends.firstIndex(where: {$0.id == group.id}) != nil
    }
    
    func update(with contact: Group) {
        if let index = selectedFriends.firstIndex(where: {$0.id == contact.id}) {
            selectedFriends.remove(at: index)
        } else {
            selectedFriends.append(contact)
        }
        reloadTableView.accept(())
    }
    
    func sendVideo(to group: Group) {
        showLoader.accept(true)
        let params: [String: Any] = [ApiConstants.friends.rawValue: group.id,
                                     ApiConstants.location.rawValue: LocationManager.shared.locationString]
        Network.multipart(.sendVideo,
                          file: FileManager.default.videoFileUrl,
                          params: params) { [weak self] (result: Result<Success, String>) in
            guard let self = self else { return }
            self.selectedFriends.removeAll()
            self.showLoader.accept(false)
            switch result {
            case .success(let response):
                self.toastMessage.accept(.custom(message: response.message ?? ""))
                FileManager.default.deleteRecordingFile()
                self.videoSent.accept(true)
            case .failure(let error):
                self.toastMessage.accept(.custom(message: error))
                self.videoSent.accept(false)
            }
        }
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
