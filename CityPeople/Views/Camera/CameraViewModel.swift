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
    var toggleCamera: PublishRelay<CameraSide> { get }
    var video: PublishRelay<URL> { get }
    var cameraSide: CameraSide { get }
    func flipCamera(to side: CameraSide)
}

class CameraViewModel: CameraViewModelProtocol {
    var videoAction = PublishRelay<VideoAction>()
    var toggleCamera = PublishRelay<CameraSide>()
    var video = PublishRelay<URL>()
    var cameraSide: CameraSide { side }
    
    private var side: CameraSide
    init(cameraSide: CameraSide) {
        self.side = cameraSide
    }
    
    func flipCamera(to side: CameraSide) {
        self.side = side
        toggleCamera.accept(side)
    }
}

enum VideoAction {
    case show, start, stop, remove
}

enum CameraSide {
    case front, rear
}
