//
//  Helper.swift
//  GoChat
//
//  Created by Iuri Menin on 23/08/16.
//  Copyright © 2016 Iuri Menin. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseDatabase

class Helper {
    static let helper = Helper()
    
    func loginAnonimo() {
        
        // Login de usuario anonimo
        
        FIRAuth.auth()?.signInAnonymously(completion: { (usuarioAnonimo, error) in
            
            if error == nil {
                
                let newUser = FIRDatabase.database().reference().child("users").child(usuarioAnonimo!.uid)
                newUser.setValue(["displayName": "anonimo", "id" : "\(usuarioAnonimo!.uid)", "profileUrl": ""])
                
                self.mudaParaNavigationViewController()
            } else {
                print(error!.localizedDescription)
                return
            }
        })
    }
    
    func loginGoogle (_ authentication: GIDAuthentication) {
        
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                
                let newUser = FIRDatabase.database().reference().child("users").child(user!.uid)
                newUser.setValue(["displayName": "\(user!.displayName!)", "id" : "\(user!.uid)", "profileUrl": "\(user!.photoURL!)"])
                self.mudaParaNavigationViewController()
            }
        })
    }
    
    func mudaParaNavigationViewController () {
        
        //Pega a storyboard pelo nome
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //pega o navigationController pelo nome
        let naviVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
        
        //pega o appDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //seta no appDelegate o viewControoler como root view
        appDelegate.window?.rootViewController = naviVC
    }

}
