//
//  threadsVC.swift
//  ChatSDKSwift
//
//  Created by Sameh sayed on 2/12/19.
//  Copyright © 2019 deluge. All rights reserved.
//

import Foundation
import UIKit
import ChatSDK

class CustomAdapter:BDefaultInterfaceAdapter{
    override func privateThreadsViewController() -> UIViewController! {
        return UIStoryboard(name: "Custom", bundle: nil).instantiateViewController(withIdentifier: "threadsVC") as! threadsVC
    }
}

class threadsVC:BPrivateThreadsViewController
{
    @IBOutlet var wefwe:UITableView!
    var _threadTypingMessages = NSMutableDictionary()
    var notificationList = BNotificationObserverList()
    var internetConnectionHook = BHook()
    var _editButton:UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        threads = [] 
    }
    override func createThread() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isUserInteractionEnabled = true
        reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeObservers()
    }
    
    override func toggleEditing() {
        self.setEditingEnabled(!tableView.isEditing)
    }
    
    override func setEditingEnabled(_ enabled: Bool) {
        if enabled {
            _editButton.title = "GTEG"
        }else {
            _editButton.title = "DAD"
        }
        tableView.setEditing(enabled, animated: true)
    }
    
    func removeObservers() {
        BChatSDK.hook().remove(internetConnectionHook, withName: bHookInternetConnectivityChanged)
        notificationList.dispose()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func updateButtonStatusForInternetConnection() {
        let connected = BChatSDK.connectivity().isConnected()
        self.navigationItem.rightBarButtonItem?.isEnabled = connected
    }
    
    deinit {
        tableView.delegate = nil
        tableView.dataSource = nil
    }
    
    override func pushChatViewController(with thread: PThread?) {
        if thread != nil {
            let vc: UIViewController? = BChatSDK.ui().chatViewController(with: thread)
            if let vc = vc {
                navigationController?.pushViewController(vc, animated: true)
            }
            // Stop multiple touches opening multiple chat views
            tableView.isUserInteractionEnabled = false
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if tableView.responds(to: #selector(setter: UITableView.separatorInset)) {
            tableView.separatorInset = .zero
        }
        
        if tableView.responds(to: #selector(setter: UITableView.layoutMargins)) {
            tableView.layoutMargins = .zero
        }
    }

}


extension threadsVC
{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threads.count
    }
    
    override func tableView(_ tableView_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView_.dequeueReusableCell(withIdentifier: "bCellIdentifier") as? BThreadCell
        guard
            let threads = threads,
            let thread = threads[indexPath.row] as? PThread
        else { return UITableViewCell() }
        
        
        
        let threadDate: Date? = thread.orderDate()
        
        var text = Bundle.t(bNoMessages)
        
        let lastMessage: PMessage? = thread.lazyLastMessage()
        if lastMessage != nil {
            text = Bundle.text(for: lastMessage)
        }
        
        if threadDate != nil {
//            cell?.dateLabel.text = threadDate.
        } else {
            cell?.dateLabel.text = ""
        }
        
        if let threadTimeFont = BChatSDK.config().threadTimeFont {
            cell?.dateLabel.font = threadTimeFont
        }
        
        if let threadTitleFont = BChatSDK.config()?.threadTitleFont {
            cell?.titleLabel.font = threadTitleFont
        }
        
        if let subTitleFont = BChatSDK.config().threadSubtitleFont {
            cell?.messageTextView.font = subTitleFont
        }
        
        cell?.titleLabel.text = thread.displayName() != nil ? thread.displayName() : Bundle.t(bDefaultThreadName)
        
        cell?.profileImageView.image = thread.imageForThread()
        
        //    cell.unreadView.hidden = !thread.unreadMessageCount;
        
        let unreadCount = Int(arc4random_uniform(UInt32(thread.unreadMessageCount())))
        
        cell?.unreadMessagesLabel.isHidden = !(unreadCount > 0)
        cell?.unreadMessagesLabel.text = NSNumber(value: unreadCount ).stringValue
        
        // Add the typing indicator
        var typingText: String? = nil
        let entityID = thread.entityID
        typingText = _threadTypingMessages[entityID] as? String
        if typingText != nil && (typingText?.count ?? 0) != 0 {
            cell?.startTyping(withMessage: typingText)
        } else {
            cell?.stopTyping(withMessage: text)
        }
        cell?.backgroundColor = .red
        
        return cell!
    }
    
    override func tableView(_ tableView_: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let thread: PThread? = threads?[indexPath.row] as? PThread
        pushChatViewController(with: thread)
        tableView_.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = .zero
        }
        
        if cell.responds(to: #selector(setter: UITableViewCell.layoutMargins)) {
            cell.layoutMargins = .zero
        }
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // Called when a thread is to be deleted
    override func tableView(_ tableView_: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let thread: PThread? = threads?[indexPath.row] as? PThread
            BChatSDK.core().delete(thread)
            reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }

}
