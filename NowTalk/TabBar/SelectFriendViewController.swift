//
//  SelectFriendViewController.swift
//  NowTalk
//
//  Created by 장성구 on 2020/05/24.
//  Copyright © 2020 com.sg. All rights reserved.
//

import UIKit
import Firebase
import BEMCheckBox


class SelectFriendViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,BEMCheckBoxDelegate {
    
    
    var user = Dictionary<String,Bool>()
    
    var array :  [UserModel] = []

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var button: UIButton!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var view = tableView.dequeueReusableCell(withIdentifier: "SelectFriendCell", for: indexPath) as! SelectFriendCell
        
        view.labelName.text = array[indexPath.row].userName
        
        view.imageviewProfile.kf.setImage(with: URL(string:array[indexPath.row].profileImageUrl!))
        
        view.checkbox.delegate = self
        view.checkbox.tag = indexPath.row
        
        
        view.imageviewProfile.layer.cornerRadius = 50/2
        view.imageviewProfile.clipsToBounds = true
        
        return view
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
        
        if(checkBox.on) {
            user[self.array[checkBox.tag].uid!] = true
        } else {
            user.removeValue(forKey: self.array[checkBox.tag].uid!)
        }
        
    }
    
    @objc func createRoom() {
        
        var myUid = Auth.auth().currentUser?.uid
        user[myUid!] = true
        let nsDic = user as! NSDictionary
        
        Database.database().reference().child("chatrooms").childByAutoId().child("users").setValue(nsDic)
        
        backAlert()
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        Database.database().reference().child("users").observe(DataEventType.value, with: { (snapshot) in

                      

                  

                      self.array.removeAll()

                      
                      let myUid = Auth.auth().currentUser?.uid
                      

                      for child in snapshot.children {

                          let fchild = child as! DataSnapshot

                          let userModel = UserModel()

                          

                          userModel.setValuesForKeys(fchild.value as! [String : Any])

                          
                          
                          if(userModel.uid == myUid) {
                              continue
                          }
                          
                          
                          
                          
                          self.array.append(userModel)

                          

                      }

                      

                      DispatchQueue.main.async {

                          self.tableview.reloadData();

                      }

                      

              })

        button.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    

    
    func backAlert(){
        let alert = UIAlertController(title: "알림", message: "채팅방이 생성되었습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default){
                UIAlertAction in
                 self.navigationController?.popViewController(animated: true)
          })
        
     
        
         present(alert, animated: true, completion: nil)
        }
    
    


}

class SelectFriendCell : UITableViewCell {
    
    @IBOutlet weak var checkbox: BEMCheckBox!
    
    @IBOutlet weak var imageviewProfile: UIImageView!
    
    @IBOutlet weak var labelName: UILabel!
    
}
