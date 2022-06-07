//
//  SendVideoHeaderView.swift
//  CityPeople
//
//  Created by Kamal Kishor on 03/06/22.
//

import UIKit
import RxSwift
import Stevia
import AVKit

class SendVideoHeaderView: UITableViewHeaderFooterView {

    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: Constants.backIcon), for: .normal)
        return button
    }()
    
    private let videoView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let sendOneTapLabel: UILabel = {
       let label = UILabel()
        label.text = Constants.sendWithOneTap
        label.font = .font(name: .semiBold, size: Constants.labelFontSize)
        label.textColor = .black
        return label
    }()
    
    private let cantSeeYourselfLabel: UILabel = {
       let label = UILabel()
        label.text = Constants.cantSeeyourself
        label.font = .font(name: .regular, size: Constants.bodyFontSize)
        label.textColor = .gray
        return label
    }()
    
    let searchField: SearchField = {
        let textField = SearchField()
        textField.placeholder = Constants.search
        textField.font = .font(name: .regular, size: Constants.textFieldFontSize)
        textField.textColor = .black
        return textField
    }()
    
    private let disposeBag = DisposeBag()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: SendVideoHeaderView.reuseIdentifier)
        setupViewLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playVideo(url: URL) {
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer)
        player.play()
    }
    
    private func setupViewLayouts() {
        contentView.subviews {
            backButton
            videoView
            sendOneTapLabel
            cantSeeYourselfLabel
            searchField
        }
        
        backButton
            .leading(Constants.viewPadding)
            .top(Constants.zeroValue)
        
        sendOneTapLabel.leading(Constants.viewPadding)
        sendOneTapLabel.Top == backButton.Bottom + Constants.extraSpaceConstant
        sendOneTapLabel.Trailing >= videoView.Leading - Constants.viewPadding
        
        cantSeeYourselfLabel.leading(Constants.viewPadding)
        cantSeeYourselfLabel.Top == sendOneTapLabel.Bottom + Constants.viewPadding
        cantSeeYourselfLabel.Trailing >= videoView.Leading - Constants.viewPadding
        
        searchField.leading(Constants.viewPadding)
            .fillHorizontally(padding: Constants.viewPadding)
            .height(Constants.searchFieldHeight)
        searchField.Top == videoView.Bottom + Constants.viewPadding
        searchField.Bottom == contentView.Bottom - Constants.viewPadding
        
        videoView
            .top(Constants.viewPadding)
            .right(Constants.viewPadding)
            .height(Constants.cameraHeight)
            .width(Constants.cameraWidth)
    }
    
    private enum Constants {
        static let sendWithOneTap = "Send with 1 tap"
        static let cantSeeyourself  = "You cannot see yourself"
        static let to  = "To"
        static let search = "Seacrh"
        static let backIcon = "circle_back_button"
        static let screenWidth = UIScreen.main.bounds.size.width
        static let cameraWidth = screenWidth * 0.25
        static let cameraHeight = cameraWidth * (16/9)
        static let fieldHeight = 44
        static let textFieldFontSize = 14.0
        static let labelFontSize = 18.0
        static let bodyFontSize = 12.0
        static let extraSpaceConstant = 80.0
        static let viewPadding = 16.0
        static let zeroValue = 0.0
        static let searchFieldHeight = 36.0
    }

}
