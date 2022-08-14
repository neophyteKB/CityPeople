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
            .groups
            .bind(to: tableView
                .rx
                .items(cellIdentifier: FriendListCell.reuseIdentifier,
                       cellType: FriendListCell.self)) { [weak self] (index, group, cell) in
                guard let self = self else { return}
                let isSelected = self.viewModel.isAlreadySelected(group)
                cell.configure(with: group, isSelected: isSelected)
                cell.btnSelectFriendTapped = { [weak self] in
                    self?.processSendVideo(to: group)
                }
                cell.selectionStyle = .none
            }.disposed(by: disposeBag)
        
        viewModel
            .videoSent
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        tableView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func processSendVideo(to group: Group) {
        viewModel.showLoader.accept(true)
        viewModel.update(with: group)
        FileManager.default.recordedFileUrl.encodeVideo { [weak self] exportSession in
            guard let self = self else { return }
            switch exportSession.status {
            case .cancelled:
                break
            case .failed:
                print(exportSession.error ?? "")
            case .completed:
                self.viewModel.sendVideo(to: group)
            case .exporting:
                print("Exporting.....")
            default: break
            }
        }
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
        
        headerView
            .searchField
            .rx
            .text
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                if headerView.searchField.isFirstResponder {
                    self?.viewModel.search(contact: text ?? "")
                }
            })
            .disposed(by: disposeBag)
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
