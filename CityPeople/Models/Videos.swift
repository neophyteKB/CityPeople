//
//  Videos.swift
//  CityPeople
//
//  Created by Kamal Kishor on 07/06/22.
//

import Foundation
import UIKit
import AVFoundation

struct VideosSuccess: Codable {
    let status: Bool
    let videos: [Video]
    let message: String?
}

struct Video: Codable {
    let id, userId: Int
    let location, name, url: String
    
    enum CodingKeys: String, CodingKey {
        case id, location, name, url
        case userId = "user_id"
    }
}

struct UserVideo {
    let name: String
    let userId: Int
    let videos: [Video]
}

extension String {
    var url: URL? { URL(string: self)}
    
    func getThumbnailFromUrl(_ completion: @escaping ((_ image: UIImage?)->Void)) {
        
        guard let url = url else { return }
        DispatchQueue.main.async {
            let asset = AVAsset(url: url)
            let assetImgGenerate = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            
            let time = CMTimeMake(value: 2, timescale: 1)
            do {
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: img)
                completion(thumbnail)
            } catch let error{
                print("Error :: ", error)
                completion(nil)
            }
        }
    }
}
