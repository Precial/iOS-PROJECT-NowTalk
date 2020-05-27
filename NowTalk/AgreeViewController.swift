//
//  AgreeViewController.swift
//  NowTalk
//
//  Created by 장성구 on 2020/05/26.
//  Copyright © 2020 com.sg. All rights reserved.
//

import UIKit
import Firebase


class AgreeViewController: UIViewController {

    
    var receiveCodeName = ""
  
    var ref: DatabaseReference!
  
    
    
    @IBOutlet weak var agreeTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
         navigationController?.navigationBar.isHidden = false
       
      //  print("log[re특검]: \(self.receiveCodeName)")
          ref = Database.database().reference()
        
        
        ref.child("agree").child(self.receiveCodeName).observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
          let value = snapshot.value as? NSDictionary
            let title = value?["title"] as? String ?? ""
          print("log[title]: \(title)")
            
            let content = value?["content"] as? String ?? ""
            print("log[content]: \(content)")

            self.agreeTextView.text = content
           
            self.navigationController?.navigationBar.topItem?.title = title
            
            
          }) { (error) in
            print(error.localizedDescription)
        }
        
        

    }
    


}
