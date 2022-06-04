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
    var reloadTableView: PublishRelay<Void> { get }
    var videoUrl: URL { get }
    var friends: BehaviorRelay<[Friend]> { get }
    func update(with contact: Friend)
    func isAlreadySelected(_ friend: Friend) -> Bool
    func sendVideo()
}

class SendVideoViewModel: SendVideoViewModelProtocol {
    var toastMessage = PublishRelay<FieldInputs>()
    var reloadTableView = PublishRelay<Void>()
    var friends = BehaviorRelay<[Friend]>(value: [])
    var showLoader = PublishRelay<Bool>()
    var videoUrl: URL { self.videoLink }
    
    private let videoLink: URL
    private let contacts: [CNContact]
    private lazy var selectedFriends = [Friend]()
    
    init(videoLink: URL, contacts: [CNContact]) {
        self.videoLink = videoLink
        self.contacts = contacts
    }
    
    func onViewDidLoad() {
        fetchFriends()
    }
    
    func isAlreadySelected(_ friend: Friend) -> Bool {
        selectedFriends.firstIndex(where: {$0.id == friend.id}) != nil
    }
    
    func update(with contact: Friend) {
        if let index = selectedFriends.firstIndex(where: {$0.id == contact.id}) {
            selectedFriends.remove(at: index)
        } else {
            selectedFriends.append(contact)
        }
        reloadTableView.accept(())
    }
    
    func sendVideo(to friend: Friend) {
        let params = [ApiConstants.ids.]
    }
    
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
            case let .failure(error):
                self.toastMessage.accept(.custom(message: error))
            }
            self.reloadTableView.accept(())
            self.showLoader.accept(false)
        }
    }
}
