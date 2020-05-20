//
//  SignupViewController.swift
//  NowTalk
//
//  Created by 장성구 on 2020/05/20.
//  Copyright © 2020 com.sg. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignupViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var name: UITextField!
    
  
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    func signupEvent(){
         Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
            let uid = user?.user.uid
            
            Database.database().reference().child("users").child(uid!).setValue(["name":self.name.text!])
            
            
        }
        
    }
    
    @IBAction func createBtn(_ sender: Any) {
        signupEvent()
    }
    
    @IBAction func cancleBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
