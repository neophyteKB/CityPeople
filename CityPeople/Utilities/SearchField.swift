//
//  SearchField.swift
//  CityPeople
//
//  Created by Kamal Kishor on 05/06/22.
//

import UIKit
import Stevia

class SearchField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customiseUI()
        setGlassIcon()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func customiseUI() {
        roundCorners(radius: 12)
        backgroundColor = UIColor.init(white: 0.8, alpha: 0.7)
    }
    
    private func setGlassIcon() {
        let imageView = UIImageView()
        let magnifyingGlassImage = UIImage(named: "search")
        imageView.image = magnifyingGlassImage
        imageView.contentMode = .scaleAspectFit
        leftViewMode = .always
        leftView = imageView
        
        imageView.left(0)
            .centerVertically()
            .width(40)
            .height(20)
    }

}
