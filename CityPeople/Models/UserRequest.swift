//
//  UserRequest.swift
//  CityPeople
//
//  Created by Kamal Kishor on 27/05/22.
//

import Foundation
import CountryPicker
import SwiftyContacts

struct UserResponse: Codable {
    let user: UserClass
    let status: Bool
}

// MARK: - UserClass
struct UserClass: Codable {
    let phone, name: String
}

// MARK: - User
struct User: Codable {
    let phone, name: String
    var id: Int
    var isRegistered: Bool
    var requestStatus: RequestStatus
    var isFriend: Bool
}

enum RequestStatus: Int, Codable {
    case none = 0
    case requestSent
    case requestReceived
    
    var title: String {
        switch self {
        case .none: return "Add"
        case .requestSent: return "Requested"
        case .requestReceived: return "Accept"
        }
    }
}

struct UserRequest {
    let firstName: String
    let lastName: String
    let country: Country
    let phoneNumber: String
    let verificationId: String
}
