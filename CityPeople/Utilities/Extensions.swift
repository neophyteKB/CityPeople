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




