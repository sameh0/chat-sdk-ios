//
//  UIInterface.swift
//  ChatSDKSwift
//
//  Created by Sameh sayed on 2/15/19.
//  Copyright © 2019 deluge. All rights reserved.
//

import Foundation
import UIKit
import ChatSDK

class CustomAdapter:BDefaultInterfaceAdapter{
    override func privateThreadsViewController() -> UIViewController! {
        return UIStoryboard(name: "Custom", bundle: nil).instantiateViewController(withIdentifier: "threadsVC") as! threadsVC
    }
    
    override func chatViewController(with thread: PThread!) -> BChatViewController! {
        return ChatVC(thread: thread)
    }
}
