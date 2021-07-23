//
//  NewChannelViewController.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 23/07/2021.
//

import UIKit

//MARK: - Outlet, Override
class NewChannelViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblChannel: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customizeComponents()
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSaveTapped(_ sender: Any) {
    }
}

//MARK: - Action - Obj
extension NewChannelViewController {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension NewChannelViewController {
    private func initComponents() {
        initTableView()
    }
    
    private func initTableView() {
        NewChannelCell.registerCellByNib(tblChannel)
        tblChannel.dataSource = self
        tblChannel.delegate = self
        tblChannel.separatorInset.left = 0
        tblChannel.showsVerticalScrollIndicator = true
        tblChannel.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tblChannel.width, height: 0))
    }
}

//MARK: - Customize
extension NewChannelViewController {
    private func customizeComponents() {
        
    }
}

//MARK: - Các hàm chức năng
extension NewChannelViewController {
    
}

//MARK: - TableView
extension NewChannelViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = NewChannelCell.loadCell(tableView) as? NewChannelCell else {return UITableViewCell()}
        cell.setUpData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
