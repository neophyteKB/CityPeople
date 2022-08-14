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
        return tableView
    }()
    
    private let headerView: AddFriendHeaderView = {
        let headerView = AddFriendHeaderView()
        return headerView
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        headerView.disappear()
    }
    
    private func setupViewLayouts() {
        view.backgroundColor = .white
        view.subviews {
            headerView
            tableView
        }
        
        headerView
            .fillHorizontally()
            .Top == view.safeAreaLayoutGuide.Top
        
        tableView
            .fillHorizontally()
            .bottom(Constants.zeroValue)
            .Top == headerView.Bottom
        
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
                guard let self = self else { return }
                if self.headerView.searchField.isFirstResponder {
                    self.viewModel.search(contact: text ?? "")
                }
            })
            .disposed(by: disposeBag)
        
        headerView.showCameraPermissionAlert = { [weak self] in
            self?.alert(message: AppConstants.cameraPermissionMessage)
        }
        
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
