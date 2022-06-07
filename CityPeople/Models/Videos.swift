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

extension String {
    var url: URL? { URL(string: self)}
    
    func getThumbnailImage() -> UIImage? {
        guard let url = url else { return nil }
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }

        return nil
    }
}
