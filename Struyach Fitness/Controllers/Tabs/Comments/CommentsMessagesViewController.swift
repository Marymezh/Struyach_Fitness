//
//  CommentsMessagesViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 22/4/23.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class CommentsMessagesViewController: MessagesViewController {
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.toAutoLayout()
        messagesCollectionView.backgroundColor = .customDarkComments
        messagesCollectionView.contentInset.top = 180
        messagesCollectionView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 180, left: 0, bottom: 0, right: 0)
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.setMessageOutgoingAvatarSize(CGSize(width: 40, height: 40))
        layout?.setMessageIncomingAvatarSize(CGSize(width: 40, height: 40))
        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 50)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 50)))
        
        layout?.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 5, left: 50, bottom: 5, right: 0)))
        layout?.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 5, left: 50, bottom: 5, right: 0)))
        
        layout?.setMessageOutgoingAvatarPosition(AvatarPosition(vertical: .messageBottom))
        layout?.setMessageIncomingAvatarPosition(AvatarPosition(vertical: .messageBottom))
        
        messageInputBar.backgroundView.backgroundColor = .customKeyboard
        messageInputBar.inputTextView.placeholder = " Write a comment..."
        messageInputBar.inputTextView.placeholderTextColor = .gray
        messageInputBar.inputTextView.backgroundColor = .systemGray6
        messageInputBar.inputTextView.layer.cornerRadius = 15
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 5, right: 0)
        messageInputBar.tintColor = .systemGray
        messageInputBar.setLeftStackViewWidthConstant(to: 35, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 35, animated: false)
        messageInputBar.leftStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        messageInputBar.leftStackView.isLayoutMarginsRelativeArrangement = true
        messageInputBar.rightStackView.isLayoutMarginsRelativeArrangement = true
        messageInputBar.sendButton.setTitle(nil, for: .normal)
        messageInputBar.sendButton.setSize(CGSize(width: 35, height: 35), animated: false)
        messageInputBar.sendButton.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
    }
}
