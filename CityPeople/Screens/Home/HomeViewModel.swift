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
    var users: PublishRelay<[Int]> { get }
    var isContactsPermissionGranted: PublishRelay<Bool> { get }
    var isCameraPermissionGranted: PublishRelay<Bool> { get }
    var contacts: BehaviorRelay<[CNContact]> { get }
    var cameraViewModel: CameraViewModelProtocol { get }
    func onViewWillDisappear()
    func toggleCamera()
    func camera(action userAction: VideoAction)
}

class HomeViewModel: HomeViewModelProtocol {
    var toastMessage = PublishRelay<FieldInputs>()
    var isContactsPermissionGranted = PublishRelay<Bool>()
    var users = PublishRelay<[Int]>()
    var isCameraPermissionGranted = PublishRelay<Bool>()
    var contacts = BehaviorRelay<[CNContact]>(value: [])
    var cameraViewModel: CameraViewModelProtocol = {
        CameraViewModel()
    }()
    
    func onViewDidLoad() {
        requestContactsAccess()
        checkOrAskCameraPermissions()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.users.accept([0,1,2,3,4,5,6,7,8,9,10,11,12])
        }
    }
    
    func onViewWillDisappear() {
        cameraViewModel.videoAction.accept(.remove)
    }
    
    func toggleCamera() {
        cameraViewModel.flipCamera()
    }
    
    func camera(action userAction: VideoAction) {
        cameraViewModel.videoAction.accept(userAction)
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
