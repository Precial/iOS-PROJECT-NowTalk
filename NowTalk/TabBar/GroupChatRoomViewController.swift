//
//  GroupChatRoomViewController.swift
//  NowTalk
//
//  Created by 장성구 on 2020/05/24.
//  Copyright © 2020 com.sg. All rights reserved.
//

import UIKit
import Firebase


class GroupChatRoomViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
       
       @IBOutlet weak var bottomLayout: NSLayoutConstraint!
    
    
    @IBOutlet weak var button_send: UIButton!
    @IBOutlet weak var textfiled_message: UITextField!
    @IBOutlet weak var tableview: UITableView!
    
    
    var destinationRoom : String?
    var uid : String?
    
    var databaseRef : DatabaseReference?
    var observe : UInt?
    var comments : [ChatModel.Comment] = []
    var users : [String:AnyObject]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden  = true
        uid = Auth.auth().currentUser?.uid
        
        Database.database().reference().child("users").observeSingleEvent(of: DataEventType.value, with: {(datansnapshot) in
            self.users = datansnapshot.value as! [String:AnyObject]
           // print("log:[현재 유저 수는]\(dic.count)")
            
        })
   

        button_send.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        // Do any additional setup after loading the view.
        
        getMessageList()
        
        
        
        // [x] TODO: 키보드 디텍션
                  NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
                  NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
         NotificationCenter.default.removeObserver(self)
         self.tabBarController?.tabBar.isHidden = false
         
         
       //  databaseRef?.removeObserver(withHandle: observe!)
     }
     
    @objc func dismissKeyboard(){
           self.view.endEditing(true)
       }
    
    /* 키보드창 내리기 */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
          self.view.endEditing(true)
    }
    
    

    
    
    
    
    
    
    
    
    @objc func sendMessage(){
        
        let value : Dictionary<String,Any> = [
            "uid" : uid!,
            "message": textfiled_message.text!,
            "timestamp":ServerValue.timestamp()
            
        ]
        
        Database.database().reference().child("chatrooms").child(destinationRoom!).child("comments").childByAutoId().setValue(value, withCompletionBlock: { (err, ref) in
            self.textfiled_message.text = ""
            
        })
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
           self.view.endEditing(true)
          
       }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            if(self.comments[indexPath.row].uid == uid){

                        let view = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MymessageCell

                        view.label_message.text = self.comments[indexPath.row].message

                        view.label_message.numberOfLines = 0

                      if let time = self.comments[indexPath.row].timestamp{

                          view.label_timestamp.text = time.toDayTime

                      }

                      
                      //setReadCount(label: view.label_read_counter, position: indexPath.row)
                      
                        return view

                        

                    }else{

                let destinationUser = users![self.comments[indexPath.row].uid!]

                        let view = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell

                        view.label_name.text = destinationUser!["userName"] as! String
                        view.label_message.text = self.comments[indexPath.row].message

                        view.label_message.numberOfLines = 0;

                        let imageUrl = destinationUser!["profileImageUrl"] as! String

                        let url = URL(string:(imageUrl))
                      
                      view.imageview_profile.layer.cornerRadius = view.imageview_profile.frame.width/2
                      view.imageview_profile.clipsToBounds = true
                      view.imageview_profile.kf.setImage(with: url)
                      

             
                      
                      if let time = self.comments[indexPath.row].timestamp{

                          view.label_timestamp.text = time.toDayTime

                      }

                   //  setReadCount(label: view.label_read_counter, position: indexPath.row)

                        return view
              
              
                  }
                      return UITableViewCell()
    }
    
    
    
    
    
    
    
     func getMessageList(){

            databaseRef = Database.database().reference().child("chatrooms").child(self.destinationRoom!).child("comments")
            observe = databaseRef?.observe(DataEventType.value, with: {
                
                (datasnapshot) in
                
                self.comments.removeAll()
                    
                var readUserDic : Dictionary<String,AnyObject> = [:]
                           

                           for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                            let key = item.key as String
                               let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                                let comment_motify = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                            
                            comment_motify?.readUsers[self.uid!] = true
                            readUserDic[key] = comment_motify?.toJSON() as! NSDictionary
                               self.comments.append(comment!)

                           }
                
                            let nsDic  = readUserDic as NSDictionary
                            
              
                if(self.comments.last?.readUsers.keys == nil) {
                    return
                }
                            
                if(!(self.comments.last?.readUsers.keys.contains(self.uid!))!){
                    
               
                
                datasnapshot.ref.updateChildValues(nsDic as! [AnyHashable : Any], withCompletionBlock: {(err, ref) in
                    
                    self.tableview.reloadData()
                                       if self.comments.count > 0{

                                           self.tableview.scrollToRow(at: IndexPath(item:self.comments.count - 1,section:0), at: UITableView.ScrollPosition.bottom, animated: false)

                                         }
                    
                })
                
                } else{
                    self.tableview.reloadData()
                    if self.comments.count > 0{

                        self.tableview.scrollToRow(at: IndexPath(item:self.comments.count - 1,section:0), at: UITableView.ScrollPosition.bottom, animated: true)

                }
            }
                
         }

    )
        }
    

    
}

extension GroupChatRoomViewController {
    @objc private func adjustInputView(noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        // [x] TODO: 키보드 높이에 따른 인풋뷰 위치 변경
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        if noti.name == UIResponder.keyboardWillShowNotification {
            let adjustmentHeight = keyboardFrame.height - view.safeAreaInsets.bottom + 40
            bottomLayout.constant = adjustmentHeight
            print("log:[키보드 사이즈 확인]: \(adjustmentHeight)")
        } else {
           bottomLayout.constant = 20
            bottomContraint.constant = -15
        }
        
        print("---> Keyboard End Frame: \(keyboardFrame)")
    }
}
