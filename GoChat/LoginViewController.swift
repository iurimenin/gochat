//
//  LoginViewController.swift
//  GoChat
//
//  Created by Iuri Menin on 23/08/16.
//  Copyright © 2016 Iuri Menin. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var botaoAnonimo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //botaoAnonimo
        //setar a cor da borde e largura
        botaoAnonimo.layer.borderWidth = 2.0
        botaoAnonimo.layer.borderColor = UIColor.whiteColor().CGColor
        GIDSignIn.sharedInstance().clientID = "784528099924-q7s7pm1dgl7tp623oqmuck8furh5vm87.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth: FIRAuth, user: FIRUser?) in
            
            if user != nil {
                Helper.helper.mudaParaNavigationViewController()
            } else {
                print("Não autorizado")
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAnonimo(sender: UIButton) {

        // Login de usuario anonimo
        Helper.helper.loginAnonimo()
    }
    
    @IBAction func loginGoogle(sender: UIButton) {
        
        // Login com google
        GIDSignIn.sharedInstance().signIn()
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if error == nil {
            print(user.authentication)
            Helper.helper.loginGoogle(user.authentication)
        } else {
            print(error.localizedDescription)
            return
        }
    }
}
