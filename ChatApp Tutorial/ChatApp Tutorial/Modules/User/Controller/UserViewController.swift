//
//  UserViewController.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 10/06/2021.
//

import UIKit
import RxSwift
import RxCocoa
import KafkaRefresh

//MARK: - Outlet, Override
class UserViewController: UIViewController {
    @IBOutlet weak var tblUser: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tfSearch: DesignableTextField!
    @IBOutlet weak var btnBack: UIButton!
    
    let disposeBag = DisposeBag()
    
    var isBackButtonHidden = true
    
    var listUsers: [User] = []
    var filteredListUsers: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customizeComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tfSearch.text = ""
        downloadUsers()
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - Action, Obj
extension UserViewController {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension UserViewController {
    private func initComponents() {
        initLocalizableText()
        initTableView()
        initTextFields()
        initButton()
    }
    
    private func initLocalizableText() {
        lblTitle.text = "Users".localized()
    }
    
    private func initTableView() {
        UserCell.registerCellByNib(tblUser)
        tblUser.dataSource = self
        tblUser.delegate = self
        tblUser.separatorInset.left = 0
        tblUser.showsVerticalScrollIndicator = false
        tblUser.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tblUser.width, height: 0))
        
        // refresh header
        tblUser.bindHeadRefreshHandler({
            self.tfSearch.text = ""
            self.downloadUsers()
        }, themeColor: Defined.defaultColor, refreshStyle: .replicatorTriangle)
    }
    
    private func initTextFields() {
        // search textfield
        let imageView = UIImageView(frame: CGRect(x: 10, y: 0, width: 15, height: 15))
        tfSearch.leftViewMode = .always
        let image = UIImage(systemName: "magnifyingglass")
        imageView.image = image
        imageView.contentMode = .scaleToFill
        imageView.tintColor = Defined.blackColor
        tfSearch.leftView = imageView
        
        self.tfSearch.rx.text.orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] (text) in
                if !text.isEmpty {
                    self.filteredListUsers.removeAll()
                    
                    // Trả lại list dựa trên kết quả tìm kiếm
                    self.filteredListUsers = self.listUsers.filter({ user -> Bool in
                        return user.userName!.lowercased().contains(text.lowercased())
                    })
                } else {
                    // Nếu text rỗng trả về full user
                    self.filteredListUsers = listUsers
                }
                self.tblUser.reloadData()
            }).disposed(by: disposeBag)
    }
    
    private func initButton() {
        btnBack.isHidden = isBackButtonHidden
    }
}

//MARK: - Customize
extension UserViewController {
    private func customizeComponents() {
        
    }
}

//MARK: - Các hàm chức năng
extension UserViewController {
    func downloadUsers() {
        FirebaseUserListener.shared.downloadAllUsersFromFirebase { allUsers in
            self.listUsers = allUsers
            self.filteredListUsers = allUsers
            
            DispatchQueue.main.async {
                self.tblUser.reloadData()
                self.tblUser.headRefreshControl.endRefreshing()
                self.view.endEditing(true)
            }
        }
    }
}

//MARK: - TableView
extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredListUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = UserCell.loadCell(tableView) as? UserCell else {return UITableViewCell()}
        let user = filteredListUsers[indexPath.row]
        cell.setUpData(user: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = RouterType.userDetail.getVc() as? UserDetailViewController else {return}
        vc.user = filteredListUsers[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}
