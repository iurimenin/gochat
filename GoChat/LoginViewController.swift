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
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            print(user.authentication)
            Helper.helper.loginGoogle(user.authentication)
        } else {
            print(error.localizedDescription)
            return
        }
    }

    
    @IBOutlet weak var botaoAnonimo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //botaoAnonimo
        //setar a cor da borde e largura
        botaoAnonimo.layer.borderWidth = 2.0
        botaoAnonimo.layer.borderColor = UIColor.white.cgColor
        GIDSignIn.sharedInstance().clientID = "784528099924-q7s7pm1dgl7tp623oqmuck8furh5vm87.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth: FIRAuth, user: FIRUser?) in
            
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
    
    @IBAction func loginAnonimo(_ sender: UIButton) {

        // Login de usuario anonimo
        Helper.helper.loginAnonimo()
    }
    
    @IBAction func loginGoogle(_ sender: UIButton) {
        
        // Login com google
        GIDSignIn.sharedInstance().signIn()
    }
}
