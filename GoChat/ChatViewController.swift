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
import SDWebImage

class ChatViewController: JSQMessagesViewController {

    var messages = [JSQMessage]()
    var avatarDict = [String: JSQMessagesAvatarImage]()
    let messageRef = FIRDatabase.database().reference().child("messages")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentUser = FIRAuth.auth()!.currentUser!
        self.senderId = currentUser.uid
        if currentUser.isAnonymous {
            self.senderDisplayName = "anonimo"
        } else {
            self.senderDisplayName = currentUser.displayName!
        }
        
        observeMessages()
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let newMessage = messageRef.childByAutoId()
        let messageData = ["text": text, "senderId": senderId, "senderName": senderDisplayName, "mediaType": "TEXT"]
        newMessage.setValue(messageData)
        self.finishSendingMessage()
    }
    
    func observeUser (_ id: String) {
        
        FIRDatabase.database().reference().child("users").child(id).observe(.value) { (snapshot: FIRDataSnapshot) in
            
            if let dict = snapshot.value as? [String: AnyObject] {
            
                let avatarUrl = dict["profileUrl"] as! String
                self.setupAvatar(avatarUrl, messageId: id)
            }
        }
    }
    
    func setupAvatar (_ url: String, messageId: String) {
        
        if url != "" {
        
            let fileUrl = URL(string: url)
            let data = try? Data(contentsOf: fileUrl!)
            let image = UIImage(data: data!)
            let userImg = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
            avatarDict[messageId] = userImg
        } else {
            avatarDict[messageId] = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profileImage"), diameter: 30)
        }
        
        collectionView.reloadData()
    }
    
    func observeMessages(){
    
        messageRef.observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            
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

                    let photo = JSQPhotoMediaItem(image: nil)
//                    let fileUrl = dict["fileUrl"] as! String
//                    let url = URL(string: fileUrl)
//                    
//                    DispatchQueue.global().async {
//                        let data = try? Data(contentsOf: url!)
//                        let picture = UIImage(data: data!)
//                        DispatchQueue.main.async {
//                            photo?.image = picture
//                            self.collectionView.reloadData()
//                        }
//                    }
                    
                    
                    let downloader = SDWebImageDownloader.shared()
                    let fileUrl = dict["fileUrl"] as! String
                    
                    downloader?.downloadImage(with: URL(string: fileUrl),
                                              options: [],
                                              progress: nil,
                                              completed: { (image, data, error, finished) in
                                                DispatchQueue.main.async {
                                                    photo?.image = image
                                                    self.collectionView.reloadData()
                                                }
                    })
                    
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))
                    
                    if self.senderId == senderId {
                        photo?.appliesMediaViewMaskAsOutgoing = true
                    } else {
                        photo?.appliesMediaViewMaskAsOutgoing = false
                    }
                    
                case "VIDEO":
                        
                    let fileUrl = dict["fileUrl"] as! String
                    let video = URL(string: fileUrl)
                    let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
                    
                    if self.senderId == senderId {
                        videoItem?.appliesMediaViewMaskAsOutgoing = true
                    } else {
                        videoItem?.appliesMediaViewMaskAsOutgoing = false
                    }
                    
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: videoItem))
                    
                default:
                    print("tipo de arquivo desconhecido")
                    
                }
                
                self.collectionView.reloadData()
            }
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("didPressAccessoryButton")
        
        let sheet = UIAlertController(title: "Mensagens de Mídia", message: "Selecione uma mídia", preferredStyle: UIAlertControllerStyle.actionSheet)
        self.present(sheet, animated: true, completion: nil)
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (UIAlertAction) in
            
        }
        
        let photoLibrary = UIAlertAction(title: "Fotos", style: .default) { (UIAlertAction) in
            self.getMediaFrom(kUTTypeImage)
        }
        
        let videoLibrary = UIAlertAction(title: "Vídeos", style: .default) { (UIAlertAction) in
            self.getMediaFrom(kUTTypeMovie)
        }
        
        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
    }
    
    func getMediaFrom(_ type: CFString) {
        
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        if message.senderId == self.senderId {

            return bubbleFactory!.outgoingMessagesBubbleImage(with: UIColor.black)
        } else {
            
            return bubbleFactory!.incomingMessagesBubbleImage(with: UIColor.blue)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.item]
        return avatarDict[message.senderId]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        let message = messages[indexPath.item]

        if message.isMediaMessage {
        
            if let mediaItem = message.media as? JSQVideoMediaItem {
                
                let player = AVPlayer(url: mediaItem.fileURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true, completion: nil)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logoutAction(_ sender: AnyObject) {
    
        do {
            try FIRAuth.auth()?.signOut()
        }catch let error {
            print(error)
        }
        
        // Cria uma instancia do main storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // instancia do main storyboard para uma navigation controller
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        
        // pegar o app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // setar LoginVC como navigation controller como root view controller
        appDelegate.window?.rootViewController = loginVC
    }
    
    func sendMedia (_ picture: UIImage?, video: URL?) {
        
        if let picture = picture {
            
            let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(Date.timeIntervalSinceReferenceDate)"
            let data = UIImageJPEGRepresentation(picture, 0.1)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpg"
            FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata) { (metadata, error) in
                
                if error != nil {
                    print(error?.localizedDescription)
                    return
                } else {
                    
                    let fileUrl = metadata!.downloadURLs![0].absoluteString
                    
                    let newMessage = self.messageRef.childByAutoId()
                    let messageData : Dictionary<String, Any> = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "mediaType": "PHOTO"]
                    newMessage.setValue(messageData)
                }
            }
        } else if let video = video {
            
            let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(Date.timeIntervalSinceReferenceDate)"
            let data = try? Data(contentsOf: video)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "video/mp4"
            
            FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata) { (metadata, error) in
                
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            sendMedia(picture, video: nil)
        } else if let video = info[UIImagePickerControllerMediaURL] as? URL {
            sendMedia(nil, video: video)
        }
        
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
}
