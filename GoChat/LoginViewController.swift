//
//  LoginViewController.swift
//  GoChat
//
//  Created by Iuri Menin on 23/08/16.
//  Copyright © 2016 Iuri Menin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var botaoAnonimo: UIButton!
    
    @IBAction func loginAnonimo(sender: UIButton) {
        print("login anonimo")
    }
    
    @IBAction func loginGoogle(sender: UIButton) {
        print("login google")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //botaoAnonimo
        //setar a cor da borde e largura
        botaoAnonimo.layer.borderWidth = 2.0
        botaoAnonimo.layer.borderColor = UIColor.whiteColor().CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
