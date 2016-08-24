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

class Helper {
    static let helper = Helper()
    
    func loginAnonimo() {
        
        // Login de usuario anonimo
        
        FIRAuth.auth()?.signInAnonymouslyWithCompletion({ (anonymosUser: FIRUser?, error: NSError?) in
            
            if error == nil {
                print("UserId: \(anonymosUser!.uid)")
                self.mudaParaNavigationViewController()
            } else {
                print(error!.localizedDescription)
                return
            }
        })
    }
    
    func loginGoogle (authentication: GIDAuthentication) {
        
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken, accessToken: authentication.accessToken)
        
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                print(user?.email)
                print(user?.displayName)
                
                self.mudaParaNavigationViewController()
            }
        })
    }
    
    private func mudaParaNavigationViewController () {
        
        //Pega a storyboard pelo nome
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //pega o navigationController pelo nome
        let naviVC = storyboard.instantiateViewControllerWithIdentifier("NavigationVC") as! UINavigationController
        
        //pega o appDelegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //seta no appDelegate o viewControoler como root view
        appDelegate.window?.rootViewController = naviVC
    }

}