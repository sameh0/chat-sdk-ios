//
//  BTextMessageCell.m
//  Chat SDK
//
//  Created by Benjamin Smiley-andrews on 26/09/2013.
//  Copyright (c) 2013 deluge. All rights reserved.
//

import ChatSDK

class BTextMessageCell:BMessageCell {
    var textView: UITextView?

    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Text view
        textView = UITextView()
        textView.backgroundColor = UIColor.clear
        textView.dataDetectorTypes = .all
        textView.editable = false
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        // Get rid of padding and margin
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero

        textView.font = UIFont.systemFont(ofSize: bDefaultFontSize)
        if BChatSDK.config.messageTextFont {
            textView.font = BChatSDK.config.messageTextFont
        }

        let linkColor: UIColor? = BChatSDK.ui.color(forName: bColorMessageLink)
        if linkColor != nil {
            if let linkColor = linkColor {
                textView.linkTextAttributes = [
                NSAttributedString.Key.foregroundColor: linkColor
                ]
            }
        }

        //        textView.contentInset = UIEdgeInsetsMake(-9.0, -5.0, 0.0, 0.0);

        bubbleImageView.addSubview(textView)
    }

    func setMessage(_ message: PElmMessage?, withColorWeight colorWeight: Float) {
        super.setMessage(message, withColorWeight: colorWeight)

        textView.text = message?.textString

        if BChatSDK.config.messageTextColorMe && message?.userModel.isMe ?? false {
            textView.textColor = BCoreUtilities.color(withHexString: BChatSDK.config.messageTextColorMe)
        } else if BChatSDK.config.messageTextColorReply && !(message?.userModel.isMe ?? false) {
            textView.textColor = BCoreUtilities.color(withHexString: BChatSDK.config.messageTextColorReply)
        } else {
            textView.textColor = BCoreUtilities.color(withHexString: bDefaultTextColor)
        }
    }

//#pragma Cell Properties
    func cellContentView() -> UIView? {
        return textView
    }
}
