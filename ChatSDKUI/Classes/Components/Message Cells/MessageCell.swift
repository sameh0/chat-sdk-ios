//
//  BMessageCelself.m
//  Chat SDK
//
//  Created by Benjamin Smiley-andrews on 27/09/2013.
//  Copyright (c) 2013 deluge. All rights reserved.
//

import ChatSDK

class BMessageCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // They aren't selectable
        selectionStyle = UITableViewCell.SelectionStyle.default

        // Make sure the selected color is white
        selectedBackgroundView = UIView()

        // Bubble view
        bubbleImageView = UIImageView()
        bubbleImageView.contentMode = .scaleToFill
        bubbleImageView.isUserInteractionEnabled = true

        contentView.addSubview(bubbleImageView)

        profilePicture = UIImageView()
        profilePicture.contentMode = .scaleAspectFill
        profilePicture.clipsToBounds = true

        contentView.addSubview(profilePicture)

        timeLabel = UILabel(frame: CGRect(x: bTimeLabelPadding, y: 0, width: 0, height: 0))

        timeLabel.font = UIFont.italicSystemFont(ofSize: 12)
        if BChatSDK.config.messageTimeFont {
            timeLabel.font = BChatSDK.config.messageTimeFont
        }

        timeLabel.textColor = UIColor.lightGray
        timeLabel.isUserInteractionEnabled = false

        contentView.addSubview(timeLabel)

        nameLabel = UILabel(frame: CGRect(x: bTimeLabelPadding, y: 0, width: 0, height: 0))
        nameLabel.isUserInteractionEnabled = false

        nameLabel.font = UIFont.boldSystemFont(ofSize: bDefaultUserNameLabelSize)
        if BChatSDK.config.messageNameFont {
            nameLabel.font = BChatSDK.config.messageNameFont
        }
        contentView.addSubview(nameLabel)

        readMessageImageView = UIImageView(frame: CGRect(x: bTimeLabelPadding, y: 0, width: 0, height: 0))
        setReadStatus(bMessageReadStatusNone)
        contentView.addSubview(readMessageImageView)

        let profileTouched = UITapGestureRecognizer(target: self, action: #selector(BMessageCell.showProfileView))
        profilePicture.isUserInteractionEnabled = true
        profilePicture.addGestureRecognizer(profileTouched)

        activityIndicator = UIActivityIndicatorView(style: .gray)
    }

    func setReadStatus(_ status: bMessageReadStatus) {
        var imageName: String? = nil

        switch status {
            case bMessageReadStatusNone:
                imageName = "icn_message_received.png"
            case bMessageReadStatusDelivered:
                imageName = "icn_message_delivered.png"
            case bMessageReadStatusRead:
                imageName = "icn_message_read.png"
            default:
                break
        }

        if imageName != nil {
            readMessageImageView.image = Bundle.uiImageNamed(imageName)
        } else {
            readMessageImageView.image = nil
        }
    }

    func setMessage(_ message: PElmMessage?) {
        setMessage(message, withColorWeight: 1.0)
    }

    func showActivityIndicator() {
        contentView.addSubview(activityIndicator)
        activityIndicator.keepCenter()
        activityIndicator.keepInsets.equal = 0
        activityIndicator.startAnimating()
        contentView.bringSubviewToFront(activityIndicator)
    }

    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }

    // Called to setup the current cell for the message
    func setMessage(_ message: PElmMessage?, withColorWeight colorWeight: Float) {

        // Set the message for later use
        self.message = message

        let isMine = message?.senderIsMe
        if isMine ?? false {
            if let readStatus = message?.readStatus {
                setReadStatus(readStatus)
            }
        } else {
            setReadStatus(bMessageReadStatusHide)
        }

        let position: bMessagePos? = message?.messagePosition
        let nextMessage: PElmMessage? = message?.lazyNextMessage

        // Set the bubble to be the correct color
        bubbleImageView.image = BMessageCache.shared().bubble(for: message, withColorWeight: colorWeight)

        // Hide profile pictures for 1-to-1 threads
        profilePicture.hidden = profilePictureHidden()

        // We only want to show the user picture if it is the latest message from the user
        if let position = position {
            if position & bMessagePosLast != 0 {
                if message?.userModel != nil {
                    if message?.userModel.imageURL != nil {
                        profilePicture.sd_setImage(with: URL(string: message?.userModel.imageURL ?? ""), placeholderImage: message?.userModel.defaultImage, options: SDWebImageLowPriority & SDWebImageScaleDownLargeImages)
                    } else if message?.userModel.imageAsImage != nil {
                        profilePicture.image = message?.userModel.imageAsImage
                    } else {
                        profilePicture.image = message?.userModel.defaultImage
                    }
                } else {
                    // If the user doesn't have a profile picture set the default profile image
                    profilePicture.image = message?.userModel.defaultImage
                    profilePicture.backgroundColor = UIColor.white
                }
            } else {
                profilePicture.image = nil
            }
        }

        if message?.flagged.intValue ?? 0 != 0 {
            timeLabel.text = Bundle.t(bFlagged)
        }

        timeLabel.text = self.message.date.messageTimeAt
        // We use 10 here because if the messages are less than 10 minutes apart, then we
        // can just compare the minute figures. If they were hours apart they could have
        // the same number of minutes
        if nextMessage != nil && nextMessage?.date.minutes(from: message?.date) ?? 0 < 10 {
            if message?.date.minute == nextMessage?.date.minute && message?.userModel == nextMessage?.userModel {
                timeLabel.text = nil
            }
        }

        nameLabel.text = self.message.userModel.name

        //
        //    // We only want to show the name label if the previous message was posted by someone else and if this is enabled in the thread
        //    // Or if the message is mine...

        nameLabel.hidden = !self.message.showUserNameLabel(forPosition: position)

        // Hide the read receipt view if this is a public thread or if read receipts are disabled
        readMessageImageView.hidden = self.message.thread.type.intValue & bThreadFilterPublic != 0 || !BChatSDK.readReceipt
    }

    // Format the cells properly when the device orientation changes
    func layoutSubviews() {
        super.layoutSubviews()

        let isMine: Bool = message?.userModel == BChatSDK.currentUser

        // Extra x-margin if the profile picture isn't shown
        // TODO: Fix this
        let xMargin: Float = profilePicture.image ? 0 : 0

        // Layout the date label this will be the full size of the cell
        // This will automatically center the text in the y direction
        // we'll set the side using text alignment
        timeLabel.viewFrameWidth = fw - bTimeLabelPadding * 2.0

        // We don't want the label getting in the way of the read receipt
        timeLabel.viewFrameHeight = cellHeight() * 0.8

        readMessageImageView.viewFrameWidth = bReadReceiptWidth
        readMessageImageView.viewFrameHeight = bReadReceiptHeight
        readMessageImageView.viewFrameY = timeLabel.fh * 2.0 / 3.0

        // Make the width less by the profile picture width means the name and profile picture are inline
        nameLabel.viewFrameWidth = fw - bTimeLabelPadding * 2.0 - profilePicture.fw
        nameLabel.viewFrameHeight = nameHeight()

        // Layout the bubble
        // The bubble is translated the "margin" to the right of the profile picture
        if !isMine {
            profilePicture.viewFrameX = profilePicture.hidden ? 0 : profilePicturePadding()
            bubbleImageView.viewFrameX = bubbleMargin().left + profilePicture.fx + profilePicture.fw + CGFloat(xMargin)
            nameLabel.viewFrameX = bTimeLabelPadding

            timeLabel.textAlignment = .right
            nameLabel.textAlignment = .left
        } else {
            profilePicture.viewFrameX = profilePicture.hidden ? contentView.fw : contentView.fw - profilePicture.fw - profilePicturePadding()
            bubbleImageView.viewFrameX = CGFloat(profilePicture.fx - bubbleWidth()) - bubbleMargin().right - CGFloat(xMargin)
            //[_nameLabel setViewFrameX: bTimeLabelPadding];

            timeLabel.textAlignment = .left
            nameLabel.textAlignment = .right
        }

        //        self.bubbleImageView.layer.borderColor = UIColor.redColor.CGColor;
        //        self.bubbleImageView.layer.borderWidth = 1;
        //        self.contentView.layer.borderColor = UIColor.blueColor.CGColor;
        //        self.contentView.layer.borderWidth = 1;
        //        self.cellContentView.layer.borderColor = UIColor.greenColor.CGColor;
        //        self.cellContentView.layer.borderWidth = 1;
    }

    func profilePictureHidden() -> Bool {
        return BMessageCell.profilePictureHidden(message)
    }

    class func profilePictureHidden(_ message: PElmMessage?) -> Bool {
        return message?.thread.type.intValue ?? 0 & bThreadType1to1 != 0 && !BChatSDK.config.showUserAvatarsOn1to1Threads
    }

    // Open the users profile
    @objc func showProfileView() {

        // Cannot view our own profile this way
        if !(message?.userModel.entityID == BChatSDK.currentUser.entityID) {
            let profileView: UIViewController? = BChatSDK.ui.profileViewController(withUser: message?.userModel)
            if let profileView = profileView {
                navigationController?.pushViewController(profileView, animated: true)
            }
        }
    }

    func cellContentView() -> UIView? {
        print("Method: cellContentView must be implemented in sub classes")
        assert(1 == 0)
        return nil
    }

    // Change the color of a bubble. This method takes an image and loops over
    // the pixels changing any non-zero pixels to the new color

    // MEM1
    class func bubble(with bubbleImage: UIImage?, with color: UIColor?) -> UIImage? {

        // Get a CGImageRef so we can use CoreGraphics
        let image = bubbleImage?.cgImage

        let width = CGImageGetWidth(image)
        let height = CGImageGetHeight(image)

        // Create a new bitmap context i.e. a buffer to store the pixel data
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let bitsPerComponent: size_t = 8
        let bytesPerPixel: size_t = 4
        let bytesPerRow = size_t((width * CGFloat(bitsPerComponent) * CGFloat(bytesPerPixel) + 7) / 8) // As per the header file for CGBitmapContextCreate
        let dataSize = size_t(CGFloat(bytesPerRow) * height)

        // Allocate some memory to store the pixels
        let data = malloc(dataSize)
        memset(data, 0, dataSize)

        // Create the context
        let context = CGContext(data: data, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)

        // Draw the image onto the context
        context.draw(in: image, image: CGRect(x: 0, y: 0, width: width, height: height))

        // Get the components of our input color
        let colors = color?.cgColor.components

        // Change the pixels which have alpha > 0 to our new color
        var i = 0
        while i < width * height * 4 {
            // If alpha is not zero
            if data[i + 3] != 0 {
                data[i] = UInt8(Int8(colors?[0] * 255))
                data[i + 1] = UInt8(Int8(colors?[1] * 255))
                data[i + 2] = UInt8(Int8(colors?[2] * 255))
            }
            i += 4
        }

        let leftCapWidth: Int? = bubbleImage?.leftCapWidth
        let topCapHeight: Int? = bubbleImage?.topCapHeight

        // Write from the context to our new image
        // Make sur to copy across the orientation and scale so the bubbles render
        // properly on a retina screen
        let imageRef = context.makeImage()
        var newImage: UIImage? = nil
        if let imageOrientation = bubbleImage?.imageOrientation {
            newImage = (UIImage(cgImage: imageRef, scale: bubbleImage?.scale ?? 0.0, orientation: imageOrientation)).stretchableImage(withLeftCapWidth: leftCapWidth ?? 0, topCapHeight: topCapHeight ?? 0)
        }
        // Free up the memory we used
        CGImageRelease(imageRef)
        CGContextRelease(context)
        free(data)

        return newImage
    }

    func supportsCopy() -> Bool {
        return false
    }

    // Layout Methods
    func messageContentHeight() -> Float {
        return BMessageCell.messageContentHeight(message)
    }

    class func messageContentHeight(_ message: PElmMessage?) -> Float {
        return self.messageContentHeight(message, maxWidth: self.maxTextWidth(message))
    }

    class func messageContentHeight(_ message: PElmMessage?, maxWidth: Float) -> Float {

        switch message?.type.intValue ?? 0 as? bMessageType {
            case bMessageTypeImage?, bMessageTypeVideo?:
                if message?.imageHeight ?? 0 > 0 && message?.imageWidth ?? 0 > 0 {

                    // We want the height to be less than the max height and more than the min height
                    // First check if the calculated height is bigger than the max height, we take the smaller of these
                    // Next we take the max of this value and the min value, this ensures the image is at least the min height
                    return max(bMinMessageHeight, min(self.messageContentWidth(message) * message?.imageHeight ?? 0.0 / message?.imageWidth ?? 0.0, bMaxMessageHeight))
                }
                return 0
            case bMessageTypeLocation?:
                return self.messageContentWidth(message)
            case bMessageTypeAudio?:
                return 50
            case bMessageTypeSticker?:
                return 140
            case bMessageTypeFile?:
                return 60
            default:
                return self.getText(message?.textString, heightWith: UIFont.systemFont(ofSize: bDefaultFontSize), withWidth: self.messageContentWidth(message, maxWidth: maxWidth))
        }
    }

    func messageContentWidth() -> Float {
        return BMessageCell.messageContentWidth(message, maxWidth: maxTextWidth())
    }

    class func messageContentWidth(_ message: PElmMessage?) -> Float {
        return self.messageContentWidth(message, maxWidth: self.maxTextWidth(message))
    }

    class func messageContentWidth(_ message: PElmMessage?, maxWidth: Float) -> Float {
        switch message?.type.intValue ?? 0 as? bMessageType {
            case bMessageTypeText?, bMessageTypeSystem?:
                return self.textWidth(message?.textString, maxWidth: maxWidth)
            case bMessageTypeSticker?:
                return 140
        // Do this so we can have 6 padding on each side
            case bMessageTypeFile?:
                return bMaxMessageWidth - 10.0
            default:
                return bMaxMessageWidth
        }
    }

    class func textWidth(_ text: String?, maxWidth: Float) -> Float {
        if text != nil {
            let font = UIFont.systemFont(ofSize: bDefaultFontSize)
            //if font
            return Float(text?.boundingRect(with: CGSize(width: CGFloat(maxWidth), height: CGFLOAT_MAX), options: .usesLineFragmentOrigin, attributes: [
            NSAttributedString.Key.font: font
            ], context: nil).size.width ?? 0.0)
        }
        return 0
    }

    func maxTextWidth() -> Float {
        return BMessageCell.maxTextWidth(message)
    }

    class func maxTextWidth(_ message: PElmMessage?) -> Float {
        return Float(CGFloat(self.maxBubbleWidth(message)) - self.bubblePadding(message).left - self.bubblePadding(message).right)
    }

    class func maxBubbleWidth(_ message: PElmMessage?) -> Float {
        let bubbleMargin: UIEdgeInsets = self.bubbleMargin(message)
        return Float(self.currentSize().width - bMessageMarginX - CGFloat((self.profilePictureHidden(message) ? 0 : self.profilePictureDiameter() + self.profilePicturePadding(message))) - bubbleMargin.left - bubbleMargin.right)
    }

    func bubbleHeight() -> Float {
        return BMessageCell.bubbleHeight(message, maxWidth: maxTextWidth())
    }

    //+(float) bubbleHeight: (id<PElmMessage>) message {
    //
    //}
    class func bubbleHeight(_ message: PElmMessage?, maxWidth: Float) -> Float {
        return Float(CGFloat(BMessageCell.messageContentHeight(message, maxWidth: maxWidth)) + BMessageCell.bubblePadding(message).top + BMessageCell.bubblePadding(message).bottom)
    }

    func cellHeight() -> Float {
        return BMessageCell.cellHeight(message, maxWidth: maxTextWidth())
    }

    class func cellHeight(_ message: PElmMessage?, maxWidth: Float) -> Float {
        let bubbleMargin: UIEdgeInsets = self.bubbleMargin(message)
        return Float(CGFloat(BMessageCell.bubbleHeight(message, maxWidth: maxWidth)) + bubbleMargin.top + bubbleMargin.bottom + CGFloat(self.nameHeight(message)))
    }

    func nameHeight() -> Float {
        return BMessageCell.nameHeight(message)
    }

    class func nameHeight(_ message: PElmMessage?) -> Float {
        let pos: bMessagePos? = message?.messagePosition()
        // Do we want to show the users name label
        if message?.showUserNameLabel(forPosition: pos) != nil {
            return bUserNameHeight
        }
        return 0
    }

    func bubbleWidth() -> Float {
        return BMessageCell.bubbleWidth(message, maxWidth: maxTextWidth())
    }

    class func bubbleWidth(_ message: PElmMessage?, maxWidth: Float) -> Float {
        return Float(CGFloat(BMessageCell.messageContentWidth(message, maxWidth: maxWidth)) + self.bubblePadding(message).left + self.bubblePadding(message).right + bTailSize)
    }

    // The margin outside the bubble
    func bubbleMargin() -> UIEdgeInsets {
        return BMessageCell.bubbleMargin(message)
    }

    // The padding inside the bubble - i.e. between the bubble and the content
    class func bubbleMargin(_ message: PElmMessage?) -> UIEdgeInsets {
        var value: NSValue? = BChatSDK.config.messageBubbleMargin(forType: message?.type.intValue ?? 0)
        value = value != nil ? value : BChatSDK.config.messageBubbleMargin(forType: bMessageTypeAll)
        if value != nil {
            return (value?.uiEdgeInsetsValue)!
        }

        switch message?.type.intValue ?? 0 as? bMessageType {
            case bMessageTypeText?, bMessageTypeImage?, bMessageTypeLocation?, bMessageTypeAudio?, bMessageTypeVideo?, bMessageTypeSystem?, bMessageTypeSticker?, bMessageTypeFile?:
                return UIEdgeInsets(top: 2.0, left: 2.0, bottom: 1.0, right: 2.0)
            case bMessageTypeCustom?:
                fallthrough
            default:
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    func bubblePadding() -> UIEdgeInsets {
        return BMessageCell.bubblePadding(message)
    }

    class func bubblePadding(_ message: PElmMessage?) -> UIEdgeInsets {
        var value: NSValue? = BChatSDK.config.messageBubblePadding(forType: message?.type.intValue ?? 0)
        value = value != nil ? value : BChatSDK.config.messageBubblePadding(forType: bMessageTypeAll)
        if value != nil {
            return (value?.uiEdgeInsetsValue)!
        }

        switch message?.type.intValue ?? 0 as? bMessageType {
            case bMessageTypeText?:
                return UIEdgeInsets(top: 8.0, left: 9.0, bottom: 8.0, right: 9.0)
            case bMessageTypeImage?, bMessageTypeLocation?, bMessageTypeAudio?, bMessageTypeVideo?:
                return UIEdgeInsets(top: 3.0, left: 3.0, bottom: 3.0, right: 3.0)
            case bMessageTypeSystem?:
                return UIEdgeInsets(top: 6.0, left: 6.0, bottom: 6.0, right: 6.0)
            case bMessageTypeFile?:
                return UIEdgeInsets(top: 10.0, left: 6.0, bottom: 10.0, right: 6.0)
            case bMessageTypeSticker?, bMessageTypeCustom?:
                fallthrough
            default:
                return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        }
    }

    func profilePicturePadding() -> Float {
        return BMessageCell.profilePicturePadding(message)
    }

    class func profilePicturePadding(_ message: PElmMessage?) -> Float {
        switch message?.type.intValue ?? 0 as? bMessageType {
            case bMessageTypeText?, bMessageTypeImage?, bMessageTypeLocation?, bMessageTypeAudio?, bMessageTypeVideo?, bMessageTypeSticker?, bMessageTypeSystem?, bMessageTypeFile?, bMessageTypeCustom?:
                fallthrough
            default:
                return 3
        }
    }

    class func profilePictureDiameter() -> Float {
        return bProfilePictureDiameter
    }

    func getTextHeight(withWidth width: Float) -> Float {
        return BMessageCell.getText(message?.textString, heightWithWidth: width)
    }

    class func getText(_ text: String?, heightWithWidth width: Float) -> Float {
        return Float(text?.boundingRect(with: CGSize(width: CGFloat(width), height: CGFLOAT_MAX), options: .usesLineFragmentOrigin, attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: bDefaultFontSize)
        ], context: nil).size.height ?? 0.0)
    }

    func getTextHeight(with font: UIFont?, withWidth width: Float) -> Float {
        return BMessageCell.getText(message?.textString, heightWith: font, withWidth: width)
    }

    class func getText(_ text: String?, heightWith font: UIFont?, withWidth width: Float) -> Float {
        if let font = font {
            return Float(text?.boundingRect(with: CGSize(width: CGFloat(width), height: CGFLOAT_MAX), options: .usesLineFragmentOrigin, attributes: [
            NSAttributedString.Key.font: font
            ], context: nil).size.height ?? 0.0)
        }
        return 0.0
    }

    class func currentSize() -> CGSize {
        var size: CGSize = UIScreen.main.bounds.size
        let application = UIApplication.shared
        if application.isStatusBarHidden == false {
            size.height -= min(application.statusBarFrame.size.width, application.statusBarFrame.size.height)
        }
        return size
    }
}
