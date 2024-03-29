//
//  Router.swift
//  CityPeople
//
//  Created by Kamal Kishor on 25/04/22.
//

import Foundation
import UIKit
import Contacts

struct Router {
    static let navigationController: UINavigationController = {
        let navVC = UINavigationController()
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        navVC.navigationBar.standardAppearance = appearance;
        navVC.isNavigationBarHidden = true
        navVC.navigationBar.scrollEdgeAppearance = navVC.navigationBar.standardAppearance
        return navVC
    }()
    
    static func popVC() {
        navigationController.popViewController(animated: true)
    }
    
    static func showAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else{ return }
        UIApplication.shared.open(settingsUrl)
    }
    
    static func pushOtpViewController(firstName: String, lastName: String) {
        let viewModel = OTPViewModel(firstName: firstName, lastName: lastName)
        let otpVCVC = OTPViewController(viewModel: viewModel)
        navigationController.pushViewController(otpVCVC, animated: true)
    }
    
    static func pushVerifyOtpViewController(userModel: UserRequest) {
        let viewModel = VerifyOtpViewModel(userRequestModel: userModel)
        let verifyOtpVC = VerifyOtpViewController(viewModel: viewModel)
        navigationController.pushViewController(verifyOtpVC, animated: true)
    }
    
    static func pushHomeViewController() {
        let homeVC = HomeViewController()
        navigationController.setViewControllers([homeVC], animated: true)
    }
    
    static func pushContactsViewController(contacts: [CNContact]) {
        let contactsViewModel = ContactsViewModel(contacts: contacts)
        let contactVC = ContactsViewController(viewModel: contactsViewModel)
        navigationController.pushViewController(contactVC, animated: true)
    }
    
    static func pushCreateGroupViewController(contacts: [CNContact], side: CameraSide) {
        let createGroupViewModel = CreateGroupViewModel(contacts: contacts, cameraSide: side)
        let createGroupVC = CreateGroupViewController(viewModel: createGroupViewModel)
        navigationController.pushViewController(createGroupVC, animated: true)
    }
    
    static func pushSendVideo(with videoLink: URL, contacts: [CNContact]) {
        let viewModel = SendVideoViewModel(videoLink: videoLink, contacts: contacts)
        let sendVideoVC = SendVideoViewController(viewModel: viewModel)
        navigationController.pushViewController(sendVideoVC, animated: true)
    }
    
    static func pushVideoPlayerViewController(_ allUserVideos: [UserVideo], selected: UserVideo, cameraSide: CameraSide) {
        let viewModel = VideoPlayerViewModel(allVideos: allUserVideos, selected: selected)
        let viewController = VideoPlayerViewController(viewModel: viewModel, side: cameraSide)
        navigationController.pushViewController(viewController, animated: true)
    }
}
