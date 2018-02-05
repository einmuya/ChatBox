//
//  ChatViewController.swift
//  ChatBox
//
//  Created by Edward Muya on 04/02/2018.
//  Copyright © 2018 com.einmuya. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {

    // MARK: Properties
    var senderName: String?
    var messages = [JSQMessage]()
    
    // Firebase database connection for messages
    private lazy var messageRef: DatabaseReference = Database.database().reference().child("messages")
    private var newMessageRefHandle: DatabaseHandle?
    
    // Typing indicator
    private lazy var userIsTypingRef: DatabaseReference = Database.database().reference().child("typingIndicator").child(self.senderId)
    private lazy var usersTypingQuery: DatabaseQuery =
        Database.database().reference().child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = Auth.auth().currentUser?.uid
        self.senderDisplayName = senderName
        
        title = senderName
        
        setupView()
    }
    
    func setupView() {
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        // Listen and display message in view
        observeMessages()
        observeTyping()
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    private func observeMessages() {
        let messageQuery = messageRef.queryLimited(toLast: 25)
        
        // Listen for new messages being written to the Firebase Database
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            
            let messageData = snapshot.value as! [String: String]
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.count > 0 {
                
                self.addMessage(withId: id, name: name, text: text)
                
                self.finishReceivingMessage()
            } else {
                print("Error! Could not decode message data")
            }
        })
    }
    
    // Typing Indicator Action
    private func observeTyping() {
        usersTypingQuery.observe(.value) { (data: DataSnapshot) in
            
            if data.childrenCount == 1 && self.isTyping {
                return
            }

            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
    
    // Write messages in Firebase Database
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        // Create child ref for message
        let itemRef = messageRef.childByAutoId()
        let key = messageRef.childByAutoId().key
        
        // Dictionary for holding message
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            "key": key
            ]
        
        // Save child ref for message
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        
    }
}

// ChatViewController DataSource
extension ChatViewController {
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    // set avatar image for messages
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    // message bubbles setup for outgoing and incoming messages
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        cell.textView.isSelectable = false
        
        // longPressGestureRecognizer
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(handleDeleteMessage))
        longPressGesture.minimumPressDuration = 0.4
        cell.addGestureRecognizer(longPressGesture)
        
        // set color for message bubbles
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        
        return cell
    }
    
    @objc func handleDeleteMessage(recognizer: UILongPressGestureRecognizer) {
        let touchPoint = recognizer.location(in: collectionView)
        let indexPath: IndexPath = collectionView.indexPathForItem(at: touchPoint)!
        
        // Dictionary for holding message
        let message = messages[indexPath.item]
        let query = messageRef.queryOrdered(byChild: "senderId").queryEqual(toValue: message.senderId)
        
        let alert = UIAlertController(title: "", message: "Select Action", preferredStyle: .actionSheet)
    
        // Delete action
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (UIAlertAction) in
                query.observe(DataEventType.value, with: { (snapshot) in
                let chat = snapshot.value as? [String: AnyObject] ?? [:]
                print(chat)
            })
            //print(indexPath[1], message)
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (UIAlertAction) in
        }))
        
        self.present(alert, animated: true, completion: {})
        finishSendingMessage()
    }
}
