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


class threadsVC:BPrivateThreadsViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        threads = []
    }
    override func createThread() {
        
    }
    

}


extension threadsVC
{
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
        
//        typingText = threadTypingMessages[entityID] as? String
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
}
