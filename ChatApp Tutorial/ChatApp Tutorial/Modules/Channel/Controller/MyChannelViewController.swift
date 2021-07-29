//
//  MyChannelViewController.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 23/07/2021.
//

import UIKit

//MARK: - Outlet, Override
class MyChannelViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblChannel: UITableView!
    
    var myChannels: [Channel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customizeComponents()
        downloadUserChannels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddTapped(_ sender: Any) {
        guard let vc = RouterType.newChannel.getVc() as? NewChannelViewController else {return}
        vc.channelToEdit = nil
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Action - Obj
extension MyChannelViewController {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension MyChannelViewController {
    private func initComponents() {
        initTitle()
        initTableView()
    }
    
    private func initTitle() {
        lblTitle.text = "My Channels".localized()
    }
    
    private func initTableView() {
        ChannelCell.registerCellByNib(tblChannel)
        tblChannel.dataSource = self
        tblChannel.delegate = self
        tblChannel.separatorInset.left = 0
        tblChannel.showsVerticalScrollIndicator = true
        tblChannel.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tblChannel.width, height: 0))
    }
}

//MARK: - Customize
extension MyChannelViewController {
    private func customizeComponents() {
        FirebaseChannelListener.share.downloadUserChannelsFromFirebase { allChannels in
            self.myChannels = allChannels
            
            DispatchQueue.main.async {
                self.tblChannel.reloadData()
            }
        }
    }
}

//MARK: - Các hàm chức năng
extension MyChannelViewController {
    private func downloadUserChannels() {
        FirebaseChannelListener.share.downloadUserChannelsFromFirebase { allChannels in
            self.myChannels = allChannels
            
            DispatchQueue.main.async {
                self.tblChannel.reloadData()
            }
        }
    }
}

//MARK: - TableView
extension MyChannelViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myChannels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = ChannelCell.loadCell(tableView) as? ChannelCell else {return UITableViewCell()}
        cell.setUpData(channel: myChannels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let channel = myChannels[indexPath.row]
            
            AlertUtil.showAlertConfirm(from: self, with: "Delete".localized() + ":" + " \(channel.name)" + " ?", message: "") { _ in
                FirebaseChannelListener.share.deleteChannel(channel)
                self.myChannels.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let vc = RouterType.newChannel.getVc() as? NewChannelViewController else {return}
        vc.channelToEdit = myChannels[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}
