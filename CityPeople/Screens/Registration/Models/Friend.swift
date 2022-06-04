//
//  Friend.swift
//  CityPeople
//
//  Created by Kamal Kishor on 28/05/22.
//

import Foundation

struct FriendResponse: Codable {
    let users: [Friend]
    let status: Bool
}

// MARK: - Friend
struct Friend: Codable {
    let id: Int
    let name, phone: String
    let alreadyFriend: Bool
    let requestStatus: Int

    enum CodingKeys: String, CodingKey {
        case id, name, phone
        case alreadyFriend = "already_friend"
        case requestStatus = "request_status"
    }
}

struct AddFriendResponse: Codable {
    let status: Bool
    let accept, friendID: Int

    enum CodingKeys: String, CodingKey {
        case status, accept
        case friendID = "friend_id"
    }
}
