//
//  ChatViewController.swift
//  GoChat
//
//  Created by Iuri Menin on 23/08/16.
//  Copyright © 2016 Iuri Menin. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {

    var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = "1"
        self.senderDisplayName = "Iuri"
        // Do any additional setup after loading the view.
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        print("didPressSendButton")
        print("\(text)")
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("didPressAccessoryButton")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logoutAction(sender: AnyObject) {
    
        // Cria uma instancia do main storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // instancia do main storyboard para uma navigation controller
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        
        // pegar o app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // setar LoginVC como navigation controller como root view controller
        appDelegate.window?.rootViewController = loginVC

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
