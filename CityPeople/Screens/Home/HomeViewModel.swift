//
//  HomeViewModel.swift
//  CityPeople
//
//  Created by Kamal Kishor on 25/04/22.
//

import Foundation
import AVFoundation
import SwiftyContacts
import RxSwift
import RxRelay

protocol HomeViewModelProtocol: ViewModelProtocol {
    var items: BehaviorRelay<[Any]> { get }
    var isContactsPermissionGranted: PublishRelay<Bool> { get }
    var isCameraPermissionGranted: PublishRelay<Bool> { get }
    var contacts: BehaviorRelay<[CNContact]> { get }
    var cameraViewModel: CameraViewModelProtocol { get }
    var videos: [UserVideo] { get }
    func onViewWillDisappear()
    func requestVideos()
    func camera(action userAction: VideoAction)
}

class HomeViewModel: HomeViewModelProtocol {
    var toastMessage = PublishRelay<FieldInputs>()
    var isContactsPermissionGranted = PublishRelay<Bool>()
    var items = BehaviorRelay<[Any]>(value: [])
    var isCameraPermissionGranted = PublishRelay<Bool>()
    var contacts = BehaviorRelay<[CNContact]>(value: [])
    var cameraViewModel: CameraViewModelProtocol = {
        CameraViewModel(cameraSide: .front)
    }()
    
    var videos: [UserVideo] = [UserVideo]()
    
    func onViewDidLoad() {
        requestContactsAccess()
        checkOrAskCameraPermissions()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.items.accept([0,1,2,3,4,5,6])
        }
    }
    
    func onViewWillDisappear() {
        cameraViewModel.videoAction.accept(.remove)
    }
    
    func camera(action userAction: VideoAction) {
        cameraViewModel.videoAction.accept(userAction)
    }
    
    func requestVideos() {
        Network.request(.videos) { [weak self] (result: Result<VideosSuccess, String>) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                if response.status {
                    var userVideos = [UserVideo]()
                    var allVideos = response.videos
                    while !allVideos.isEmpty {
                        let video = allVideos.first!
                        let userVideo = UserVideo(name: video.name, userId: video.userId, videos: allVideos.filter({$0.userId == video.userId}))
                        allVideos = allVideos.filter({$0.userId != video.userId})
                        userVideos.append(userVideo)
                    }
                    self.videos = userVideos
                    self.update(values: userVideos)
                } else {
                    self.toastMessage.accept(.custom(message: response.message ?? ""))
                }
            case .failure(let failure):
                self.toastMessage.accept(.custom(message: failure))
            }
        }
    }
    
    private func update(values videos: [UserVideo]) {
        if videos.count > items.value.count {
            items.accept(videos)
        } else {
            var index = 0
            var values = items.value
            while index < videos.count {
                values[index] = videos[index]
                index += 1
            }
            items.accept(values)
        }
    }
    
    private func checkOrAskCameraPermissions() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .notDetermined, .restricted:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] isGranted in
                self?.isCameraPermissionGranted.accept(isGranted)
            }
        case .denied:
            isCameraPermissionGranted.accept(false)
        case .authorized:
            isCameraPermissionGranted.accept(true)
        @unknown default:
            fatalError()
        }
    }
    
    private func requestContactsAccess() {
        requestAccess { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(isGranted):
                self.isContactsPermissionGranted.accept(isGranted)
                if isGranted { self.pullContacts() }
            case let .failure(error):
                self.toastMessage.accept(.custom(message: error.localizedDescription))
            }
        }
    }
    
    private func pullContacts() {
        fetchContacts { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(contacts):
                self.contacts.accept(contacts)
            case let .failure(error):
                self.toastMessage.accept(.custom(message: error.localizedDescription))
            }
        }
    }
}
