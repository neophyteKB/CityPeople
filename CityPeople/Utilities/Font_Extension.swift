//
//  Font_Extension.swift
//  CityPeople
//
//  Created by Kamal Kishor on 27/04/22.
//

import Foundation
import UIKit

extension UIFont {
    static func font(name: FontName, size: CGFloat) -> UIFont {
        return UIFont(name: name.rawValue, size: size) ?? .systemFont(ofSize: size)
    }
}

enum FontName: String {
    case regular = "Poppins-Regular"
    case italic = "Poppins-Italic"
    case thin = "Poppins-Thin"
    case thinItalic = "Poppins-ThinItalic"
    case extraLight = "Poppins-ExtraLight"
    case extraLightItalic = "Poppins-ExtraLightItalic"
    case light = "Poppins-Light"
    case lightItalic = "Poppins-LightItalic"
    case medium = "Poppins-Medium"
    case mediumItalic = "Poppins-MediumItalic"
    case semiBold = "Poppins-SemiBold"
    case semiBoldItalic = "Poppins-SemiBoldItalic"
    case bold = "Poppins-Bold"
    case boldItalic = "Poppins-BoldItalic"
    case extraBold = "Poppins-ExtraBold"
    case extraBoldItalic = "Poppins-ExtraBoldItalic"
    case black = "Poppins-Black"
    case blackItalic = "Poppins-BlackItalic"
}

extension UIColor {
    static var cityGreen: UIColor {
        return UIColor(named: "primaryGreen")!
    }
}
