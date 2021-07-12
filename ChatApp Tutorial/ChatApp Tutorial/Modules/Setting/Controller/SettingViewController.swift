//
//  SettingViewController.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 10/06/2021.
//

import UIKit

//MARK: - Outlet, Override
class SettingViewController: UIViewController {
    @IBOutlet weak var tblSetting: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customizeComponents()
    }
    
    
}

//MARK: - Action, Obj
extension SettingViewController {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension SettingViewController {
    private func initComponents() {
        initLocalizableText()
        initTableView()
    }
    
    private func initLocalizableText() {
        lblTitle.text = "Settings".localized()
    }
    
    private func initTableView() {
        SettingCell.registerCellByNib(tblSetting)
        tblSetting.dataSource = self
        tblSetting.delegate = self
        tblSetting.separatorStyle = .none
        tblSetting.showsVerticalScrollIndicator = false
        tblSetting.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tblSetting.width, height: 0))
    }
}

//MARK: - Customize
extension SettingViewController {
    private func customizeComponents() {
        
    }
}

//MARK: - Các hàm chức năng
extension SettingViewController {
    
}

//MARK: - TableView
extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = SettingCell.loadCell(tableView) as? SettingCell else {return UITableViewCell()}
        cell.delegate = self
        cell.showUserInfo(LocalResourceRepository.getUserLocally())
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension SettingViewController: SettingCellDelegate {
    func clickViewUser() {
        guard let vc = RouterType.profile.getVc() as? ProfileViewController else {return}
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func clickViewTell() {
        print(2)
    }
    
    func clickViewTerms() {
        print(3)
    }
    
    func clickViewLogout() {
        AlertUtil.showAlertConfirm(from: self, with: "Log Out".localized(), message: "") { _ in
            FirebaseUserListener.shared.logoutCurrentUser { error in
                if error == nil {
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    AlertUtil.showAlert(from: self, with: error?.localizedDescription ?? "", message: "")
                }
            }
        }        
    }
}

//MARK: - ProfileViewControllerDelegate
extension SettingViewController: ProfileViewControllerDelegate {
    func reloadData() {
        tblSetting.reloadData()
    }
}
