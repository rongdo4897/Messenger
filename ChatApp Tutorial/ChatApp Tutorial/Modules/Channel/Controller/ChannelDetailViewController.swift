//
//  ChannelDetailViewController.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 29/07/2021.
//

import UIKit

//MARK: - Outlet, Override
class ChannelDetailViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblChannel: UITableView!
    
    var channel = Channel()
    
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
extension ChannelDetailViewController {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension ChannelDetailViewController {
    private func initComponents() {
        initTitle()
        initTableView()
    }
    
    private func initTitle() {
        lblTitle.text = "Channel Detail".localized()
    }
    
    private func initTableView() {
        ChannelDetailCell.registerCellByNib(tblChannel)
        tblChannel.dataSource = self
        tblChannel.delegate = self
        tblChannel.separatorInset.left = 0
        tblChannel.showsVerticalScrollIndicator = true
        tblChannel.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tblChannel.width, height: 0))
    }
}

//MARK: - Customize
extension ChannelDetailViewController {
    private func customizeComponents() {
        
    }
}

//MARK: - Các hàm chức năng
extension ChannelDetailViewController {
    
}

//MARK: - TableView
extension ChannelDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = ChannelDetailCell.loadCell(tableView) as? ChannelDetailCell else {return UITableViewCell()}
        cell.setUpData(channel: channel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
