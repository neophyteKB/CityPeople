//
//  CreateGroupViewController.swift
//  CityPeople
//
//  Created by Kamal Kishor on 05/05/22.
//

import UIKit
import Stevia
import RxSwift
import RxCocoa
import SwiftyContacts

class CreateGroupViewController: UIViewController, UITableViewDelegate {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(FriendListCell.self, forCellReuseIdentifier: FriendListCell.reuseIdentifier)
        tableView.register(CreateGroupHeaderView.self, forHeaderFooterViewReuseIdentifier: CreateGroupHeaderView.reuseIdentifier)
        tableView.estimatedSectionHeaderHeight = 140.0
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private let createGroupButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.createGroupTitle, for: .normal)
        button.titleLabel?.font = .font(name: .semiBold, size: Constants.createGroupFontSize)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .cityGreen
        button.roundCorners(radius: Constants.createGroupButtonHeight / 2)
        button.contentEdgeInsets = Constants.createGroupBtnEdgeInset
        return button
    }()

    private let disposeBag = DisposeBag()
    private var createGroupNameField: UITextField!
    private var viewModel: CreateGroupViewModelProtocol!
    
    init(viewModel: CreateGroupViewModelProtocol) {
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
    
    private func setupViewLayouts() {
        view.backgroundColor = .white
        view.subviews {
            tableView
            createGroupButton
        }
        
        tableView
            .fillHorizontally()
            .Top == view.safeAreaLayoutGuide.Top
        
        createGroupButton.centerHorizontally().height(Constants.createGroupButtonHeight)
        createGroupButton.Top == tableView.Bottom
        createGroupButton.Bottom == view.safeAreaLayoutGuide.Bottom
    }
    
    private func setupViewBindings() {
        createGroupButton
            .rx
            .tap
            .bind { [weak self] in
                self?.validateCreateGroupFields()
            }.disposed(by: disposeBag)
        
        viewModel
            .toastMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.view.makeToast(message.message)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .selectedFriends
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel
            .showLoader
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] show in
                if show {
                    self?.view.makeToastActivity(.center)
                } else {
                    self?.view.hideToastActivity()
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
                }
                cell.selectionStyle = .none
            }.disposed(by: disposeBag)
        
        tableView
            .rx
            .itemSelected
          .subscribe(onNext: { [weak self] indexPath in
              guard let self = self else { return}
              self.viewModel.update(with: self.viewModel.friends.value[indexPath.row])
          })
          .disposed(by: disposeBag)
        
        tableView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    
    private func setupHeaderViewBindings(_ headerView: CreateGroupHeaderView) {
        headerView
            .backButton
            .rx
            .tap
            .bind {
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
                       
        headerView
            .groupNameField
            .rx
            .text
            .orEmpty
            .map { String($0.prefix(10))}
            .bind(to: headerView.groupNameField.rx.text)
            .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CreateGroupHeaderView.reuseIdentifier) as?  CreateGroupHeaderView else { return nil }
        setupHeaderViewBindings(headerView)
        createGroupNameField = headerView.groupNameField
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }
    
    private func validateCreateGroupFields() {
        let groupName = createGroupNameField.text ?? ""
        if groupName.isEmpty {
            view.makeToast(FieldInputs.groupName.message)
            return
        }
        viewModel.createGroup(name: groupName)
    }
    
    private enum Constants {
        static let createGroupTitle = "Create"
        static let viewPadding = 16.0
        static let leadingValue = 16.0
        static let zerovalue = 0.0
        static let createGroupFontSize = 16.0
        static let createGroupButtonHeight: CGFloat = 44
        static let createGroupBtnEdgeInset = UIEdgeInsets(top: 8, left: 32, bottom: 8, right: 32)
    }

}
