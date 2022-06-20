//
//  ContactsViewController.swift
//  CityPeople
//
//  Created by Kamal Kishor on 03/05/22.
//

import UIKit
import RxSwift
import RxCocoa
import Stevia

class ContactsViewController: UIViewController, UITableViewDelegate {
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(ContactInfoCell.self, forCellReuseIdentifier: ContactInfoCell.reuseIdentifier)
        tableView.register(AddFriendHeaderView.self, forHeaderFooterViewReuseIdentifier: AddFriendHeaderView.reuseIdentifier)
        return tableView
    }()
    
    // MARK: - Private Properties
    private let viewModel: ContactsProtocol
    private let disposeBag = DisposeBag()

    init(viewModel: ContactsProtocol) {
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
        }
        
        tableView
            .fillHorizontally()
            .bottom(Constants.zeroValue)
            .Top == view.safeAreaLayoutGuide.Top
    }
    
    private func setupViewBindings() {
        viewModel
            .allContacts
            .bind(to: tableView.rx.items(cellIdentifier: ContactInfoCell.reuseIdentifier,
                                         cellType: ContactInfoCell.self)) { (index, contact, cell) in
                cell.configure(with: contact)
                cell.cellButtonTapped = { [weak self] in
                    self?.viewModel.action(friend: contact, isRejected: false)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel
            .toastMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.view.makeToast(message.message)
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
                }
            })
            .disposed(by: disposeBag)
        
        tableView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func setupHeaderViewBindings(_ headerView: AddFriendHeaderView) {
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
        
        headerView.showCameraPermissionAlert = { [weak self] in
            self?.alert(message: AppConstants.cameraPermissionMessage)
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: AddFriendHeaderView.reuseIdentifier) as?  AddFriendHeaderView else { return nil }
        setupHeaderViewBindings(headerView)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }
    
    private enum Constants {
        static let zeroValue = 0.0
        static let viewPadding = 16.0
        
        static let backIcon = "circle_back_button"
    }
}
