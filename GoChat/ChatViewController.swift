//
//  ChatViewController.swift
//  GoChat
//
//  Created by Iuri Menin on 23/08/16.
//  Copyright © 2016 Iuri Menin. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ChatViewController: JSQMessagesViewController {

    var messages = [JSQMessage]()
    var avatarDict = [String: JSQMessagesAvatarImage]()
    let messageRef = FIRDatabase.database().reference().child("messages")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentUser = FIRAuth.auth()!.currentUser!
        self.senderId = currentUser.uid
        if currentUser.anonymous {
            self.senderDisplayName = "anonimo"
        } else {
            self.senderDisplayName = currentUser.displayName!
        }
        
        observeMessages()
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let newMessage = messageRef.childByAutoId()
        let messageData = ["text": text, "senderId": senderId, "senderName": senderDisplayName, "mediaType": "TEXT"]
        newMessage.setValue(messageData)
        self.finishSendingMessage()
    }
    
    func observeUser (id: String) {
        
        FIRDatabase.database().reference().child("users").child(id).observeEventType(.Value) { (snapshot: FIRDataSnapshot) in
            
            if let dict = snapshot.value as? [String: AnyObject] {
            
                let avatarUrl = dict["profileUrl"] as! String
                self.setupAvatar(avatarUrl, messageId: id)
            }
        }
    }
    
    func setupAvatar (url: String, messageId: String) {
        
        if url != "" {
        
            let fileUrl = NSURL(string: url)
            let data = NSData(contentsOfURL: fileUrl!)
            let image = UIImage(data: data!)
            let userImg = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: 30)
            avatarDict[messageId] = userImg
        } else {
            avatarDict[messageId] = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "profileImage"), diameter: 30)
        }
        
        collectionView.reloadData()
    }
    
    func observeMessages(){
    
        messageRef.observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot) in
            
            if let dict = snapshot.value as? [String: AnyObject] {
                
                let senderId = dict["senderId"] as! String
                let senderName = dict["senderName"] as! String
                let mediaType = dict["mediaType"] as! String
                
                self.observeUser(senderId)
                
                switch mediaType {
                
                case "TEXT":
                    
                    let text = dict["text"] as! String
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                    
                case "PHOTO":
                    
                    let fileUrl = dict["fileUrl"] as! String
                    let url = NSURL(string: fileUrl)
                    let data = NSData(contentsOfURL: url!)
                    let picture = UIImage(data: data!)
                    let photo = JSQPhotoMediaItem(image: picture)
                    
                    if self.senderId == senderId {
                        photo.appliesMediaViewMaskAsOutgoing = true
                    } else {
                        photo.appliesMediaViewMaskAsOutgoing = false
                    }
                    
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))
                    
                case "VIDEO":
                        
                    let fileUrl = dict["fileUrl"] as! String
                    let video = NSURL(string: fileUrl)
                    let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
                    
                    if self.senderId == senderId {
                        videoItem.appliesMediaViewMaskAsOutgoing = true
                    } else {
                        videoItem.appliesMediaViewMaskAsOutgoing = false
                    }
                    
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: videoItem))
                    
                default:
                    print("tipo de arquivo desconhecido")
                    
                }
                
                self.collectionView.reloadData()
            }
        }
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("didPressAccessoryButton")
        
        let sheet = UIAlertController(title: "Mensagens de Mídia", message: "Selecione uma mídia", preferredStyle: UIAlertControllerStyle.ActionSheet)
        self.presentViewController(sheet, animated: true, completion: nil)
        let cancel = UIAlertAction(title: "Cancelar", style: .Cancel) { (UIAlertAction) in
            
        }
        
        let photoLibrary = UIAlertAction(title: "Fotos", style: .Default) { (UIAlertAction) in
            self.getMediaFrom(kUTTypeImage)
        }
        
        let videoLibrary = UIAlertAction(title: "Vídeos", style: .Default) { (UIAlertAction) in
            self.getMediaFrom(kUTTypeMovie)
        }
        
        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
    }
    
    func getMediaFrom(type: CFString) {
        
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.presentViewController(mediaPicker, animated: true, completion: nil)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        if message.senderId == self.senderId {

            return bubbleFactory.outgoingMessagesBubbleImageWithColor(.blackColor())
        } else {
            
            return bubbleFactory.incomingMessagesBubbleImageWithColor(.blueColor())
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.item]
        return avatarDict[message.senderId]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        
        let message = messages[indexPath.item]

        if message.isMediaMessage {
        
            if let mediaItem = message.media as? JSQVideoMediaItem {
                
                let player = AVPlayer(URL: mediaItem.fileURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.presentViewController(playerViewController, animated: true, completion: nil)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logoutAction(sender: AnyObject) {
    
        do {
            try FIRAuth.auth()?.signOut()
        }catch let error {
            print(error)
        }
        
        // Cria uma instancia do main storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // instancia do main storyboard para uma navigation controller
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        
        // pegar o app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // setar LoginVC como navigation controller como root view controller
        appDelegate.window?.rootViewController = loginVC
    }
    
    func sendMedia (picture: UIImage?, video: NSURL?) {
        
        if let picture = picture {
            
            let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(NSDate.timeIntervalSinceReferenceDate())"
            let data = UIImageJPEGRepresentation(picture, 0.1)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpg"
            FIRStorage.storage().reference().child(filePath).putData(data!, metadata: metadata) { (metadata, error) in
                
                if error != nil {
                    print(error?.localizedDescription)
                    return
                } else {
                    
                    let fileUrl = metadata!.downloadURLs![0].absoluteString
                    
                    let newMessage = self.messageRef.childByAutoId()
                    let messageData = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "mediaType": "PHOTO"]
                    newMessage.setValue(messageData)
                }
            }
        } else if let video = video {
            
            let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(NSDate.timeIntervalSinceReferenceDate())"
            let data = NSData(contentsOfURL: video)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "video/mp4"
            
            FIRStorage.storage().reference().child(filePath).putData(data!, metadata: metadata) { (metadata, error) in
                
                if error != nil {
                    print(error?.localizedDescription)
                    return
                } else {
                    
                    let fileUrl = metadata!.downloadURLs![0].absoluteString
                    
                    let newMessage = self.messageRef.childByAutoId()
                    let messageData = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "mediaType": "VIDEO"]
                    newMessage.setValue(messageData)
                }
            }
        }
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            sendMedia(picture, video: nil)
        } else if let video = info[UIImagePickerControllerMediaURL] as? NSURL {
            sendMedia(nil, video: video)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        collectionView.reloadData()
    }
}
