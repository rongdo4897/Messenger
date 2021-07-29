//
//  ChannelViewController.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 10/06/2021.
//

import UIKit
import BetterSegmentedControl

//MARK: - Outlet, Override
class ChannelViewController: UIViewController {
    @IBOutlet weak var segmentChannel: BetterSegmentedControl!
    @IBOutlet weak var tblSubcribedChannel: UITableView!
    @IBOutlet weak var tblAllChannel: UITableView!
    
    var allChannels: [Channel] = []
    var subscribedChannels: [Channel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customizeComponents()
        downloadChannels()
    }
    
    @IBAction func segmentChannelValueChange(_ sender: BetterSegmentedControl) {
        if sender.index == 0 {
            tblSubcribedChannel.isHidden = false
            tblAllChannel.isHidden = true
        } else {
            tblSubcribedChannel.isHidden = true
            tblAllChannel.isHidden = false
        }
    }
    
    @IBAction func btnMyChannelTapped(_ sender: Any) {
        guard let vc = RouterType.myChannels.getVc() as? MyChannelViewController else {return}
        vc.hidesBottomBarWhenPushed = false
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Action, Obj
extension ChannelViewController {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension ChannelViewController {
    private func initComponents() {
        initTableViews([tblSubcribedChannel, tblAllChannel])
        initSegment()
    }
    
    private func initTableViews(_ tableViews: [UITableView]) {
        for tableView in tableViews {
            ChannelCell.registerCellByNib(tableView)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorInset.left = 0
            tableView.showsVerticalScrollIndicator = false
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.width, height: 0))
            
            if tableView == tblSubcribedChannel {
                tableView.isHidden = false
                
                tableView.bindHeadRefreshHandler({
                    self.downloadSubscribedChannels()
                }, themeColor: Defined.defaultColor, refreshStyle: .replicatorTriangle)
            } else {
                tableView.isHidden = true
                
                tableView.bindHeadRefreshHandler({
                    self.downloadAllChannels()
                }, themeColor: Defined.defaultColor, refreshStyle: .replicatorTriangle)
            }
        }
    }
    
    private func initSegment() {
        let font = UIFont.boldSystemFont(ofSize: 13)
        segmentChannel.segments = LabelSegment.segments(withTitles: ["Subscribed".localized(), "All Channels".localized()], normalFont: font, normalTextColor: Defined.defaultColor, selectedFont: font, selectedTextColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        segmentChannel.indicatorViewBackgroundColor = Defined.defaultColor
        segmentChannel.layer.borderWidth = 3
        segmentChannel.layer.borderColor = Defined.whiteColor.cgColor
        segmentChannel.cornerRadius = 10
    }
}

//MARK: - Customize
extension ChannelViewController {
    private func customizeComponents() {
        
    }
}

//MARK: - Các hàm chức năng
extension ChannelViewController {
    private func downloadChannels() {
        downloadSubscribedChannels()
        downloadAllChannels()
    }
    
    private func downloadSubscribedChannels() {
        FirebaseChannelListener.share.downloadSubscribedChannels { channels in
            self.subscribedChannels = channels
            
            DispatchQueue.main.async {
                self.tblSubcribedChannel.reloadData()
                self.tblSubcribedChannel.headRefreshControl.endRefreshing()
                self.view.endEditing(true)
            }
        }
    }
    
    private func downloadAllChannels() {
        FirebaseChannelListener.share.downloadAllChannels { channels in
            self.allChannels = channels
            
            DispatchQueue.main.async {
                self.tblAllChannel.reloadData()
                self.tblAllChannel.headRefreshControl.endRefreshing()
                self.view.endEditing(true)
            }
        }
    }
}

//MARK: - TableView
extension ChannelViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case tblSubcribedChannel:
            return subscribedChannels.count
        case tblAllChannel:
            return allChannels.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = ChannelCell.loadCell(tableView) as? ChannelCell else {return UITableViewCell()}
        switch tableView {
        case tblSubcribedChannel:
            cell.setUpData(channel: subscribedChannels[indexPath.row])
            return cell
        case tblAllChannel:
            cell.setUpData(channel: allChannels[indexPath.row])
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView {
        case tblSubcribedChannel:
            return 120
        case tblAllChannel:
            return 120
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case tblSubcribedChannel:
            print(1)
        case tblAllChannel:
            guard let vc = RouterType.channelDetail.getVc() as? ChannelDetailViewController else {return}
            vc.channel = allChannels[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
