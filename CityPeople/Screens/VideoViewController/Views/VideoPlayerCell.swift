//
//  VideoPlayerCell.swift
//  CityPeople
//
//  Created by Kamal Kishor on 10/06/22.
//

import AVKit
import RxGesture
import RxSwift
import Stevia

class VideoPlayerCell: UICollectionViewCell {
    
    var errorMessage: ((FieldInputs) -> Void)?
    var move: ((MoveTo) -> Void)?
    
    private let videoView = UIView()
    private let disposeBag = DisposeBag()
    private var userVideos = [Video]()
    private var currentIndex: Int = 0
    private var player: AVPlayer?
    private var url: URL?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewLayouts()
        setupViewBindings()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { _ in
            print("Video finished")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playVideo() {
        guard let url = url else {
            errorMessage?(.custom(message: "Something went wrong, try another video"))
            return
        }
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = contentView.bounds
        contentView.layer.addSublayer(playerLayer)
        self.player = player
        player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 3), queue: .main) { [weak self] time in
            self?.addPlayerObservers()
        }
        player.play()
    }
    
    private func addPlayerObservers() {
        if let currentItem = self.player?.currentItem {
                if currentItem.status == .readyToPlay {
                    if currentItem.isPlaybackLikelyToKeepUp {
                        contentView.hideToastActivity()
                    } else {
                        contentView.makeToastActivity(.center)
                    }
                } else if currentItem.status == .failed {
                    contentView.makeToastActivity(.center)
                } else if currentItem.status == .unknown {
                    contentView.makeToastActivity(.center)
                }
            } else {
                errorMessage?(.custom(message: "There is no video to play!!"))
            }
    }
    
    private func setupViewLayouts() {
        contentView.subviews {
            videoView
        }
        videoView.backgroundColor = .black
        videoView.fillContainer()
    }
    
    private func setupViewBindings() {
        contentView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] gesture in
                self?.handle(gesture: gesture)
            })
            .disposed(by: disposeBag)
    }
    
    func configure(with video: Video) {
        url = video.url.url
        playVideo()
    }
    
    func resumeVideo() {
        playVideo()
    }
    
    private func handle(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: contentView)
        if point.x > contentView.frame.size.width / (UIScreen.main.scale * 2) {
            move?(.next)
        } else {
            move?(.previous)
        }
    }
}

enum MoveTo {
    case previous, next
}
