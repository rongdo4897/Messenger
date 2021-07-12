//
//  StatusViewController.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 15/06/2021.
//

import UIKit

protocol StatusViewControllerDelegate: AnyObject {
    func reloadData()
}

//MARK: - Outlet, Override
class StatusViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblStatus: UITableView!
    
    weak var delegate: StatusViewControllerDelegate?
    
    let listStatus: [Status] = [.available, .busy, .atSchool, .atTheMovies, .atWork, .atTheGym, .atThePlayerGame, .online, .offline, .inAMeeting, .sleeping, .cantTalk]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customizeComponents()
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - Action - Obj
extension StatusViewController {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension StatusViewController {
    private func initComponents() {
        initLocalizableText()
        initTableView()
    }
    
    private func initLocalizableText() {
        lblTitle.text = "Status".localized()
    }
    
    private func initTableView() {
        StatusCell.registerCellByNib(tblStatus)
        tblStatus.dataSource = self
        tblStatus.delegate = self
        tblStatus.separatorInset.left = 0
        tblStatus.showsVerticalScrollIndicator = false
        tblStatus.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tblStatus.width, height: 0))
    }
}

//MARK: - Customize
extension StatusViewController {
    private func customizeComponents() {
        
    }
}

//MARK: - Các hàm chức năng
extension StatusViewController {
    
}

//MARK: - TableView
extension StatusViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listStatus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = StatusCell.loadCell(tableView) as? StatusCell else {return UITableViewCell()}
        cell.setUpData(text: listStatus[indexPath.row].rawValue.localized())
        if listStatus[indexPath.row].rawValue.lowercased().contains(((LocalResourceRepository.getUserLocally()?.status ?? "").lowercased())) {
            cell.imgCheck.isHidden = false
        } else {
            cell.imgCheck.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if var user = LocalResourceRepository.getUserLocally() {
            user.status = listStatus[indexPath.row].rawValue
            LocalResourceRepository.setUserLocally(user: user)
            FirebaseUserListener.shared.saveUserToFireStore(user)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.delegate?.reloadData()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
