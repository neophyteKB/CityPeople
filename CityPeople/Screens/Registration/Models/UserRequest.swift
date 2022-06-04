//
//  UserRequest.swift
//  CityPeople
//
//  Created by Kamal Kishor on 27/05/22.
//

import Foundation
import CountryPicker
import SwiftyContacts


struct Success: Codable {
    let status: Bool
}

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
    var requestStatus: Int
    var isFriend: Bool
}


struct UserRequest {
    let firstName: String
    let lastName: String
    let country: Country
    let phoneNumber: String
    let verificationId: String
}
