//
//  VideoPlayerViewModel.swift
//  CityPeople
//
//  Created by Kamal Kishor on 08/06/22.
//

import AVFoundation
import Foundation
import RxRelay

protocol VideoPlayerViewModelProtocol: ViewModelProtocol {
    var showLoader: PublishRelay<Bool> { get }
    var allVideos: PublishRelay<[UserVideo]> { get }
    var selectedIndex: Int { get }
    var allVideosCount: Int { get }
    var isCameraPermissionGranted: PublishRelay<Bool> { get }
    func sendVideo(_ videoLink: URL)
}

class VideoPlayerViewModel: VideoPlayerViewModelProtocol {
    var showLoader = PublishRelay<Bool>()
    var toastMessage = PublishRelay<FieldInputs>()
    var isCameraPermissionGranted = PublishRelay<Bool>()
    var allVideos = PublishRelay<[UserVideo]>()
    var selectedIndex: Int = 0
    var allVideosCount: Int = 0
    
    func onViewDidLoad() {
        checkOrAskCameraPermissions()
        allVideos.accept(allUserVideos)
        allVideosCount = allUserVideos.count
    }
    
    func sendVideo(_ videoLink: URL) {
        showLoader.accept(true)
        let params: [String: Any] = [ApiConstants.friends.rawValue: [selectedUser.userId],
                                     ApiConstants.groups.rawValue: [],
                                     ApiConstants.location.rawValue: LocationManager.shared.locationString]
        Network.multipart(.sendVideo,
                          file: videoLink,
                          params: params) { [weak self] (result: Result<Success, String>) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.toastMessage.accept(.custom(message: response.message ?? ""))
                FileManager.default.deleteRecordingFile()
            case .failure(let error):
                self.toastMessage.accept(.custom(message: error))
            }
            self.showLoader.accept(false)
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
    
    private let allUserVideos: [UserVideo]
    private let selectedUser: UserVideo
    init(allVideos: [UserVideo], selected: UserVideo) {
        self.allUserVideos = allVideos
        self.selectedUser = selected
        selectedIndex = allVideos.firstIndex(where: {$0.userId == selected.userId}) ?? 0
    }
}

