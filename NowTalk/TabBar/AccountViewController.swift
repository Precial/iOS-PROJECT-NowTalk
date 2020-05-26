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
        
        
           let lbNavTitle = UILabel (frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        
           lbNavTitle.textColor = UIColor.black
           lbNavTitle.textAlignment = .left
           lbNavTitle.font = .systemFont(ofSize: 22, weight: .semibold)
           lbNavTitle.text = "  더보기"


           self.navigationItem.titleView = lbNavTitle

        
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
