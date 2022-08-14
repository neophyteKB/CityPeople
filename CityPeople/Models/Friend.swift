//
//  Friend.swift
//  CityPeople
//
//  Created by Kamal Kishor on 28/05/22.
//

import Foundation

struct FriendResponse: Codable {
    let users: [Friend]?
    let message: String?
    let status: Bool
}

// MARK: - Friend
struct Friend: Codable {
    let id: Int
    let name, phone: String
    let alreadyFriend: Bool
    let requestStatus: RequestStatus

    enum CodingKeys: String, CodingKey {
        case id, name, phone
        case alreadyFriend = "already_friend"
        case requestStatus = "request_status"
    }
}

struct GroupsResponse: Codable {
    let users: [Group]
    let status: Bool
}

// MARK: - Group
struct Group: Codable {
    let id: Int
    let name: String
    let isGroup: Bool

    enum CodingKeys: String, CodingKey {
        case id, name
        case isGroup = "is_group"
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
