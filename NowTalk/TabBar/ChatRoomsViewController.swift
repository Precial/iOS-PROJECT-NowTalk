//
//  ChatRoomsViewController.swift
//  NowTalk
//
//  Created by 장성구 on 2020/05/22.
//  Copyright © 2020 com.sg. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ChatRoomsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
 
    var uid : String!
    var chatrooms : [ChatModel]! = []
    var keys : [String] = []
    var destinationUsers : [String] = []
    
    var userCount : [Int] = []
    
    var userNameKey: [Dictionary<String, Bool>.Keys] = []
    
      var groupUserName : [String] = []
    
    
    
    @IBOutlet weak var tableview: UITableView!
    
   override func viewDidLoad() {

            super.viewDidLoad()

    self.destinationUsers.removeAll()
   
            self.uid = Auth.auth().currentUser?.uid

            self.getChatroomsList()

            // Do any additional setup after loading the view.

        }

        
    
    
    
    
    
    
    func getChatroomsList(){

            
            Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value, with: {(datasnapshot) in
                self.chatrooms.removeAll()
                
                for item in datasnapshot.children.allObjects as! [DataSnapshot]{

                   // print("log[채팅방 리스트 확인]:\(item)")
                    
                   // self.chatrooms.removeAll()

                    if let chatroomdic = item.value as? [String:AnyObject]{

                        let chatModel = ChatModel(JSON: chatroomdic)
                        self.keys.append(item.key)
                        self.chatrooms.append(chatModel!)
                        self.userCount.append(chatModel!.users.count)
                        self.userNameKey.append(chatModel!.users.keys)
                        
                        print("log[특검 0] = \(chatModel!.users.keys)")
                        
                     
                    }

                    
                }
                //   print("log[chat room 개수 값 확인]:\(self.chatrooms.count)")
                self.tableview.reloadData()

            })
            self.chatrooms.removeAll()
        }

        

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // print("log[채팅방 개수]:\(chatrooms.count)")
            return self.chatrooms.count

        }

        

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

               let cell = tableView.dequeueReusableCell(withIdentifier: "RowCell", for:indexPath) as! CustomCell

      

               var destinationUid: String?

               

               for item in chatrooms[indexPath.row].users{

                   if(item.key != self.uid){

                       destinationUid = item.key
                    destinationUsers.append(destinationUid!)
                    
                  

                   }

               }
        
         //   print("log[특검]:\(self.userNameKey[indexPath.row])")
        
        if self.userCount[indexPath.row] > 2 {
            
            
            print("log[특검]:\(self.userNameKey[indexPath.row])")
//                             let userNameKey = chatModel!.users.keys
//                             print("log[특검-1]: \(userNameKey)")
//
//
                                 for i in self.userNameKey[indexPath.row] {
                                    
                                     print("log[특검-2]: \(i)")

                                     Database.database().reference().child("users").child(i).observeSingleEvent(of: DataEventType.value, with: { (datasnapshot) in

                                         let userModel = UserModel()

                                         userModel.setValuesForKeys(datasnapshot.value as! [String:AnyObject])
                                         print("log[특검 2-2 ]: \(userModel.userName!)")

                                        self.groupUserName.append(userModel.userName!)
                                     
                                        

                                     })


                                 }
            self.groupUserName.removeAll()
                                    print("log[특검-3]: \(self.groupUserName)")
                             }
        
        
        
        
        

       // print("log[destination 유저 수 확인:\(destinationUsers.count)]")
        
               Database.database().reference().child("users").child(destinationUid!).observeSingleEvent(of: DataEventType.value, with: { (datasnapshot) in

                   
                    
                
                
                   let userModel = UserModel()

                   userModel.setValuesForKeys(datasnapshot.value as! [String:AnyObject])

                 if(self.userCount[indexPath.row] > 2){
                  //  cell.label_title.text = "단체 톡 (\(self.userCount[indexPath.row]))"
                    
                    
                    print("log[특검-4]: \(self.groupUserName)")
                    
                    let tempSort = self.groupUserName.sorted(by:<)
                    
                    var sumName = ""
                    for ii in tempSort {
                        print("log[특검 4-1]: \(ii)")
                        sumName = sumName + ii + ","
                    }
                    
                    sumName = String(sumName.dropLast(1))
                     print("log[특검 4-2]: \(sumName)")
                    
                   
                    
             cell.label_title.text = "\(sumName) (\(self.userCount[indexPath.row]))"
                    
                
                    
                    
                                  cell.imageview.layer.cornerRadius = cell.imageview.frame.width/2
                                  cell.imageview.layer.masksToBounds = true
                    //cell.imageView?.image = UIImage(named: "people") // 단체 톡방 이미지
                              
                } else {
                     cell.label_title.text = userModel.userName
                    let url = URL(string: userModel.profileImageUrl!)
                                  cell.imageview.layer.cornerRadius = cell.imageview.frame.width/2
                                  cell.imageview.layer.masksToBounds = true
                                  cell.imageview.kf.setImage(with: url)
                }
                    
                
                  

             

                if(self.chatrooms[indexPath.row].comments.keys.count == 0) {
                    return
                }

                   

                   let lastMessagekey = self.chatrooms[indexPath.row].comments.keys.sorted(){$0>$1}

                   cell.label_lastmessage.text = self.chatrooms[indexPath.row].comments[lastMessagekey[0]]?.message
                   
                let unixTime = self.chatrooms[indexPath.row].comments[lastMessagekey[0]]?.timestamp
                cell.label_timestamp.text = unixTime?.toDayTime
                   
              
               })

   
                
               return cell

               

               

           }

        
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        print("log[추적 1]:\(destinationUsers)")
            
        print("log[추적 2 - 유저 개수 값은]:\(self.userCount[indexPath.row])")
        
        if(self.userCount[indexPath.row] > 2){
            print("log[일로 넘어가면안됨!!!!!!!!....]")
            let destinationUid = self.destinationUsers[indexPath.row]
               let view = self.storyboard?.instantiateViewController(withIdentifier: "GroupChatRoomViewController") as!
                GroupChatRoomViewController

            view.destinationRoom = self.keys[indexPath.row]

               self.navigationController?.pushViewController(view, animated: true)


        } else {
            print("log[일로 넘어가야함....]")
            let destinationUid = self.destinationUsers[indexPath.row]
               let view = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
               view.destinationUid = destinationUid
               
               self.navigationController?.pushViewController(view, animated: true)
        }
        
        
        
   
    }
    
    
        
    override func viewDidAppear(_ animated: Bool) {
        self.userNameKey.removeAll()
        viewDidLoad()
    }
    
    
    

        override func didReceiveMemoryWarning() {

            super.didReceiveMemoryWarning()
            
            // Dispose of any resources that can be recreated.

        }

        
        override func viewWillAppear(_ animated: Bool) {
            self.userNameKey.removeAll()
                  viewDidLoad()
    
         }
        

        /*

         // MARK: - Navigation

         // In a storyboard-based application, you will often want to do a little preparation before navigation

         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

         // Get the new view controller using segue.destinationViewController.

         // Pass the selected object to the new view controller.

         }

         */

        

    }


class CustomCell: UITableViewCell {
    
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_lastmessage: UILabel!
    @IBOutlet weak var label_timestamp: UILabel!
    
}
