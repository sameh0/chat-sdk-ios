//
//  ChatVC.swift
//  ChatSDKSwift
//
//  Created by Sameh sayed on 2/15/19.
//  Copyright © 2019 deluge. All rights reserved.
//

import Foundation
import UIKit
import ChatSDK

class ChatVC:BChatViewController
{
    var selectedCell:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setChatGesture()
    }
    
    func setChatGesture()
    {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(chatLongPress(longPress:)))
        longPress.minimumPressDuration = 3
        tableView.addGestureRecognizer(longPress)
    }
    
    func chatLongPress(longPress: UILongPressGestureRecognizer)
    {
        let state = longPress.state
        let location = longPress.location(in: self.tableView)
        guard let indexPath = self.tableView.indexPathForRow(at: location) else { return }
        self.selectedCell = indexPath
        switch state {
        case .began:
            tableView.alpha = 0
        case .ended:
            tableView.alpha = 1
            break
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
