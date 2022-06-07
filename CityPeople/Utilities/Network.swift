//
//  Network.swift
//  CityPeople
//
//  Created by Kamal Kishor on 22/05/22.
//

import Foundation
import FirebaseAuth

struct Network {
    static var phoneNumber: String = UserDefaults.standard.phoneNumber
    static let basePath: String = "http://18.216.101.139/api/"
    
    static func request<T: Decodable>(_ endPoint: EndPoints,
                                      isMultipart: Bool = false,
                                      file: Any? = nil, // URL or image
                                      params: [String: Any]? = nil,
                                      completion: @escaping (Result<T, String>) -> Void) {
        var urlRequest = URLRequest(url: URL(string: Network.basePath + endPoint.rawValue)!,
                                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                    timeoutInterval: .infinity)
        urlRequest.httpMethod = "POST"
        
        // Checking token
        guard let token = UserDefaults.standard.firebaseToken else {
            completion(.failure("Token expired"))
            return
        }
        
        // Setting headers
        urlRequest.allHTTPHeaderFields = ["Authorization": "Bearer \(token)"]
        
        // Setting parameters
        var parameters: [String: Any] = [ApiConstants.phone.rawValue: UserDefaults.standard.phoneNumber]
        parameters.merge(params ?? [:]) { (current, _) in current }
        
        // Setting data
        if isMultipart {
            // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
            // And the boundary is also set here
            let boundary = UUID().uuidString
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            let multipartData = multipartData(for: file, boundry: boundary, params: parameters)
            
            URLSession.shared.uploadTask(with: urlRequest, from: multipartData) { (data, response, error) in
                if let error = error {
                    completion(.failure(error.localizedDescription))
                } else if let data = data {
                    do {
                        let value = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(value))
                    } catch {
                        fatalError("Error in parsing - \(error)")
                    }
                }
            }.resume()
        } else {
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            if let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) {
                urlRequest.httpBody = jsonData
            }
            // Request
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    completion(.failure(error.localizedDescription))
                } else if let data = data {
                    do {
                        let value = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(value))
                    } catch {
                        fatalError("Error in parsing - \(error)")
                    }
                }
            }.resume()
        }
    }
    
    static private func multipartData(for file: Any?, boundry: String, params: [String: Any]) -> Data {
        let boundary = UUID().uuidString
        
       var data = Data()
        
        // Add the file data to the raw http request data
        for (key, value) in params {
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(value)\r\n".data(using: .utf8)!)
        }
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        let fileName = "video-\(boundry).mp4"
        guard let videoLink = file as? URL,
                let videoData = try? Data(contentsOf: videoLink) else { return Data() }
        data.append("Content-Disposition: form-data; name=\"\(ApiConstants.video.rawValue)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
                data.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
        data.append(videoData)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return data
    }
    
    static func generateFirebaseToken(completion: @escaping ((Bool) -> Void)) {
        let auth = FirebaseAuth.Auth.auth()
        let currentUser = auth.currentUser
        currentUser?.getIDToken(completion: { result, error in
            if let token = result {
                UserDefaults.standard.set(token: token)
                completion(true)
            } else if let error = error {
                print(error)
                completion(false)
            }
        })
    }
}

extension UserDefaults {
    func set(token: String) {
        set(token, forKey: "FirebaseToken")
    }
    func set(phone: String) {
        set(phone, forKey: "Phone")
    }
    var firebaseToken: String? {
        value(forKey: "FirebaseToken") as? String
    }
    var phoneNumber: String {
        value(forKey: "Phone") as? String ?? ""
    }
}

enum EndPoints: String {
    case user
    case contacts
    case videos
    case addFriend = "friends/add"
    case createGroup = "groups/create"
    case sendVideo = "videos/upload"
    case accept = "friends/accept"
}

enum ApiConstants: String {
    case name
    case phone
    case contacts
    case friendId = "friend_id"
    case ids
    case friends
    case groups
    case location
    case video
    case accept
    
}

enum FieldInputs {
    case firstName
    case lastName
    case mobileNumber
    case otp
    case groupName
    case custom(message: String)
    
    var message: String {
        switch self {
        case .firstName: return "First name is empty"
        case .lastName: return "Last name is empty"
        case .mobileNumber: return "Mobile number is empty"
        case .otp: return "Enter valid OTP"
        case .groupName: return "Group name is empty"
        case .custom(let message): return message
        }
    }
}
