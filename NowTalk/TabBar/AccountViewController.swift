//
//  AccountViewController.swift
//  NowTalk
//
//  Created by 장성구 on 2020/05/22.
//  Copyright © 2020 com.sg. All rights reserved.
//

import UIKit
import Firebase


class AccountViewController: UIViewController {

    
    @IBOutlet weak var conditionsCommentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        conditionsCommentButton.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
        
    }
    

    @objc func showAlert() {
        
        let alertController = UIAlertController(title: "상태 메시지", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField { (textfiled) in
            textfiled.placeholder = "상태메시지를 입력해주세요"
        }
        
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler:{ (action) in
            
            if let textfiled = alertController.textFields?.first {
                
                let dic = ["comment" : textfiled.text!]
                let uid = Auth.auth().currentUser?.uid
                Database.database().reference().child("users").child(uid!).updateChildValues(dic)
                
            }
                
                
            
            
        }))
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action)
                in
            }))
            
            self.present(alertController, animated: true, completion: nil)
    }
    
    

}
