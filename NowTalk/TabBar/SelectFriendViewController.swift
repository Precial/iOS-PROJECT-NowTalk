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


class SelectFriendViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var array :  [UserModel] = []

    @IBOutlet weak var tableview: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var view = tableView.dequeueReusableCell(withIdentifier: "SelectFriendCell", for: indexPath) as! SelectFriendCell
        
        view.labelName.text = array[indexPath.row].userName
        
        view.imageviewProfile.kf.setImage(with: URL(string:array[indexPath.row].profileImageUrl!))
        
        return view
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

        // Do any additional setup after loading the view.
    }
    



}

class SelectFriendCell : UITableViewCell {
    
    @IBOutlet weak var checkbox: BEMCheckBox!
    
    @IBOutlet weak var imageviewProfile: UIImageView!
    
    @IBOutlet weak var labelName: UILabel!
    
}
