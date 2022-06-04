//
//  SendVideoViewController.swift
//  CityPeople
//
//  Created by Kamal Kishor on 03/06/22.
//

import UIKit
import AVKit
import RxSwift
import Stevia

class SendVideoViewController: UIViewController, UITableViewDelegate {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(FriendListCell.self, forCellReuseIdentifier: FriendListCell.reuseIdentifier)
        tableView.register(SendVideoHeaderView.self, forHeaderFooterViewReuseIdentifier: SendVideoHeaderView.reuseIdentifier)
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private let disposeBag = DisposeBag()
    private let viewModel: SendVideoViewModelProtocol
    init(viewModel: SendVideoViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewLayouts()
        setupViewBindings()
        viewModel.onViewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Private Methods
    private func setupViewLayouts() {
        view.backgroundColor = .white
        view.subviews {
            tableView
        }
        
        tableView
            .fillContainer()
            
    }
    
    private func setupViewBindings() {
        viewModel
            .toastMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.view.makeToast(message.message)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .reloadTableView
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel
            .showLoader
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] show in
                if show {
                    self?.view.makeToastActivity(.center)
                } else {
                    self?.view.hideToastActivity()
                    self?.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel
            .friends
            .bind(to: tableView
                .rx
                .items(cellIdentifier: FriendListCell.reuseIdentifier,
                       cellType: FriendListCell.self)) { [weak self] (index, friend, cell) in
                guard let self = self else { return}
                let isSelected = self.viewModel.isAlreadySelected(friend)
                cell.configure(with: friend, isSelected: isSelected)
                cell.btnSelectFriendTapped = { [weak self] in
                    self?.viewModel.update(with: friend)
                    self?.sendVideo(to: friend)
                }
                cell.selectionStyle = .none
            }.disposed(by: disposeBag)
        
//        tableView
//            .rx
//            .itemSelected
//          .subscribe(onNext: { [weak self] indexPath in
//              guard let self = self else { return}
//              self.viewModel.update(with: self.viewModel.friends.value[indexPath.row])
//          })
//          .disposed(by: disposeBag)
        
        tableView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func setupHeaderViewBindings(_ headerView: SendVideoHeaderView) {
        headerView
            .backButton
            .rx
            .tap
            .bind{
                Router.popVC()
            }
            .disposed(by: disposeBag)
    }
    
    private func sendVideo(to friend: Friend) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SendVideoHeaderView.reuseIdentifier) as?  SendVideoHeaderView else { return nil }
        setupHeaderViewBindings(headerView)
        headerView.playVideo(url: viewModel.videoUrl)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }
}
