//
//  LoginViewController.swift
//  SingPortoSeguro
//
//  Created by Humberto Vieira on 10/14/16.
//  Copyright © 2016 Humberto Vieira. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKShareKit

class LoginViewController: UIViewController, FBSDKSharingDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var buttonLoginFacebook: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    
    func openShareDialog() {
        let content = FBSDKShareLinkContent()
        content.contentTitle = "Link muito bom"
        content.contentDescription = "Descrição muito boa"
        content.contentURL = URL(string: "http://site.indice.in/")
        
        let dialog = FBSDKShareDialog()
        dialog.fromViewController = self
        dialog.shareContent = content
        dialog.mode = .feedWeb
        
        OperationQueue.main.addOperation {
            dialog.show()
        }
        
    }
    
    @IBAction func actionFacebookLogin(_ sender: AnyObject) {
        self.openShareDialog()
    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("terminou logar")
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        print("Termino do login")
        return true
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("LOG OUT")
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        print("CANCELOU SHARE")
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        print("ERROR SHARE")
    }
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print("COMPARTILHADO COM SUCESSO!")
    }

    
    
    
    
    
}
