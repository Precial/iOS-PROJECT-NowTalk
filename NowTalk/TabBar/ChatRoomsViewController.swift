//
//  ChatRoomsViewController.swift
//  NowTalk
//
//  Created by 장성구 on 2020/05/22.
//  Copyright © 2020 com.sg. All rights reserved.
//

import UIKit
import Firebase

class ChatRoomsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
 
    var uid : String!
    var chatrooms : [ChatModel]! = []
    
    @IBOutlet weak var tableview: UITableView!
    
   override func viewDidLoad() {

            super.viewDidLoad()

            

            self.uid = Auth.auth().currentUser?.uid

            self.getChatroomsList()

            // Do any additional setup after loading the view.

        }

        

        func getChatroomsList(){

            

            Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value, with: {(datasnapshot) in

                

                for item in datasnapshot.children.allObjects as! [DataSnapshot]{

                    

                    if let chatroomdic = item.value as? [String:AnyObject]{

                        let chatModel = ChatModel(JSON: chatroomdic)

                        self.chatrooms.append(chatModel!)

                    }

                    

                }

                self.tableview.reloadData()

                

                

            })

            

            

            

        }

        

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

            return self.chatrooms.count

        }

        

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(withIdentifier: "RowCell", for:indexPath)

            

            

            return cell

            

            

        }

        

        override func didReceiveMemoryWarning() {

            super.didReceiveMemoryWarning()

            // Dispose of any resources that can be recreated.

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
