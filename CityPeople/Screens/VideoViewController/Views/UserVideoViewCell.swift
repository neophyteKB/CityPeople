//
//  UserVideoViewCell.swift
//  CityPeople
//
//  Created by Kamal Kishor on 17/06/22.
//

import UIKit
import Stevia
import RxSwift
import RxRelay

class UserVideoViewCell: UICollectionViewCell {
    
    var errorMessage: ((FieldInputs) -> Void)?
    var show:((MoveTo) -> Void)?
    
    private let collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.itemSize = CGSize(width: Constants.screenWidth, height: Constants.videoViewHeight)
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(VideoPlayerCell.self, forCellWithReuseIdentifier: VideoPlayerCell.reuseIdentifier)
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let videos = PublishRelay<[Video]>()
    private var numberOfVideos: Int = 0
    private let disposeBag = DisposeBag()
    private var index: Int = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewLayouts()
        setupViewBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(userVideo: UserVideo) {
        videos.accept(userVideo.videos)
        numberOfVideos = userVideo.videos.count
    }
    
    private func setupViewLayouts() {
        contentView.subviews {
            collectionView
        }
        collectionView.fillContainer()
    }
    
    private func setupViewBindings() {
        videos
            .bind(to: collectionView.rx.items(cellIdentifier: VideoPlayerCell.reuseIdentifier,
                                              cellType: VideoPlayerCell.self)) { [weak self] (row, element, cell) in
                guard let self = self else { return }
                cell.configure(with: element)
                cell.move = { (side) in
                    self.handle(action: side)
                }
            }
                                              .disposed(by: disposeBag)
    }
    
    private func handle(action side: MoveTo) {
        if side == .next {
            let nextIndex = index + 1
            if nextIndex < numberOfVideos {
                let cellIndex = IndexPath(item: nextIndex, section: 0)
                scroll(to: cellIndex)
                index = nextIndex
            } else {
                index = 0
                show?(.next)
            }
        } else {
            let previousIndex = index - 1
            if previousIndex < 0 {
                show?(.previous)
                index = 0
            } else {
                let cellIndex = IndexPath(item: previousIndex, section: 0)
                scroll(to: cellIndex)
                index = previousIndex
            }
        }
    }
    
    private func scroll(to index: IndexPath) {
        collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        guard let cell = collectionView.cellForItem(at: index) as? VideoPlayerCell else { return }
        cell.resumeVideo()
    }
    
    private enum Constants {
        static let screenWidth = UIScreen.main.bounds.size.width
        static let videoViewHeight = screenWidth * (16/9)
    }
}
