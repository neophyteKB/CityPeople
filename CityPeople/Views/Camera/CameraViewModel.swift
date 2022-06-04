//
//  CameraViewModel.swift
//  CityPeople
//
//  Created by Kamal Kishor on 25/04/22.
//

import Foundation
import RxSwift
import RxRelay

protocol CameraViewModelProtocol {
    var videoAction: PublishRelay<VideoAction> { get }
    var toggleCamera: PublishRelay<Void> { get }
    var video: PublishRelay<URL> { get }
    func flipCamera()
}

class CameraViewModel: CameraViewModelProtocol {
    var videoAction = PublishRelay<VideoAction>()
    var toggleCamera = PublishRelay<Void>()
    var video = PublishRelay<URL>()
    
    func flipCamera() {
        toggleCamera.accept(())
    }
}

enum VideoAction {
    case show, start, stop, remove
}
