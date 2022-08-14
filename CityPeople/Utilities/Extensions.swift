//
//  Extensions.swift
//  CityPeople
//
//  Created by Kamal Kishor on 23/05/22.
//

import UIKit
import AVKit

extension  UIView {
    func setBorder(with color: UIColor, of width: CGFloat = 1, cornerRadius: CGFloat = 0) {
        layer.cornerRadius = cornerRadius
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        clipsToBounds = true
    }
    
    func roundCorners(radius: CGFloat) {
        layer.cornerRadius = radius
    }
}

extension UICollectionViewCell {
    static var reuseIdentifier: String {
        return "\(Self.self)"
    }
}

extension UITableViewCell {
    static var reuseIdentifier: String {
        return "\(Self.self)"
    }
}

extension UITableViewHeaderFooterView {
    static var reuseIdentifier: String {
        return "\(Self.self)"
    }
}

extension UIViewController {
    func alert(message: String) {
        let alert = UIAlertController(title: "Settings", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { _ in
            Router.showAppSettings()
        }))
        present(alert, animated: true)
    }
}

extension FileManager {
    var videoFileUrl: URL {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { fatalError() }
        return documentsURL.appendingPathComponent("video.mp4")
    }
    
    var recordedFileUrl: URL {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { fatalError() }
        return documentsURL.appendingPathComponent("recorded_video.mov")
    }
    
    func deleteRecordingFile(_ url: URL = FileManager.default.videoFileUrl) {
        do {
            try removeItem(at: url)
            print("File deleted successfully at - \(url.absoluteString)")
        } catch {
            print("Unable to delete the file at - \(url.absoluteString)")
            print("Error ----- \(error)")
        }
    }
}

extension URL {
    func encodeVideo(completion: @escaping ((AVAssetExportSession) -> Void))  {
        let outputFileUrl = FileManager.default.videoFileUrl
        let avAsset = AVURLAsset(url: self)
        
        //Create Export session
        guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough) else { return }
        
        //Check if the file already exists then remove the previous file
        FileManager.default.deleteRecordingFile()
        exportSession.outputURL = outputFileUrl
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
        let range = CMTimeRange(start: start, duration: avAsset.duration)
        exportSession.timeRange = range
        
        exportSession.exportAsynchronously {
            completion(exportSession)
        }
    }
}
