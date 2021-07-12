//
//  ChannelViewController.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 10/06/2021.
//

import UIKit

//MARK: - Outlet, Override
class ChannelViewController: UIViewController {
    @IBOutlet weak var tblChannel: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customizeComponents()
    }
}

//MARK: - Action, Obj
extension ChannelViewController {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension ChannelViewController {
    private func initComponents() {
        initLocalizableText()
        initTableView()
    }
    
    private func initLocalizableText() {
        lblTitle.text = "Channels".localized()
    }
    
    private func initTableView() {
        ChannelCell.registerCellByNib(tblChannel)
        tblChannel.dataSource = self
        tblChannel.delegate = self
        tblChannel.separatorInset.left = 0
        tblChannel.showsVerticalScrollIndicator = false
        tblChannel.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tblChannel.width, height: 0))
    }
}

//MARK: - Customize
extension ChannelViewController {
    private func customizeComponents() {
        
    }
}

//MARK: - Các hàm chức năng
extension ChannelViewController {
    
}

//MARK: - TableView
extension ChannelViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = ChannelCell.loadCell(tableView) as? ChannelCell else {return UITableViewCell()}
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
