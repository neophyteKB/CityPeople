//
//  Extensions.swift
//  CityPeople
//
//  Created by Kamal Kishor on 23/05/22.
//

import UIKit

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
    func deleteRecordingFile() {
        do {
            try removeItem(at: videoFileUrl)
            print("File deleted successfully at - \(videoFileUrl.absoluteString)")
        } catch {
            print("Unable to delete the file at - \(videoFileUrl.absoluteString)")
            print("Error ----- \(error)")
        }
    }
}
