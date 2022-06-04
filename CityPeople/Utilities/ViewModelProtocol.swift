//
//  ViewModelProtocol.swift
//  CityPeople
//
//  Created by Kamal Kishor on 25/04/22.
//

import Foundation
import RxRelay

protocol ViewModelProtocol {
    var toastMessage: PublishRelay<FieldInputs> { get }
    func onViewDidLoad() 
}
