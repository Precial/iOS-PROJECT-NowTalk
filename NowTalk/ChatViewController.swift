//
//  ChatViewController.swift
//  NowTalk
//
//  Created by 장성구 on 2020/05/21.
//  Copyright © 2020 com.sg. All rights reserved.
//



import UIKit
import Firebase



class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    

    var uid: String?

    var chatRoomUid: String?

    @IBOutlet weak var textfiled_message: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    
    var comments : [ChatModel.Comment] = []
    var userModel: UserModel?
    

    public var destinationUid: String? // 나중에 내가 채팅할 대상의 uid
    
    
    override func viewDidLoad() {

        super.viewDidLoad()

        uid = Auth.auth().currentUser?.uid


        checkChatRoom()
        self.tabBarController?.tabBar.isHidden  = true
      
        
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name(rawValue: "UIKeyboardWillShow"), object: nil)
        
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name(rawValue: "UIKeyboardWillHide"), object: nil)
        
    }
    
    
    // 컨트롤러 종료시
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    @objc func keyboardWillShow(notification : Notification){
         UIView.animate(withDuration: 0 , animations: {
             self.view.layoutIfNeeded()
         }, completion: {
             (complete) in
            
            if self.comments.count > 0{

                self.tableview.scrollToRow(at: IndexPath(item:self.comments.count - 1,section:0), at: UITableView.ScrollPosition.bottom, animated: true)

                  

              }
            

         })

     }
    
    
    @objc func keyboardWillHide(notification:Notification) {
        self.view.layoutIfNeeded()
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("log[1]: \(comments.count)")
        
        return comments.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

          

          if(self.comments[indexPath.row].uid == uid){

              let view = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MymessageCell

              view.label_message.text = self.comments[indexPath.row].message

              view.label_message.numberOfLines = 0

              return view

              

          }else{

              

              let view = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell

              view.label_name.text = userModel?.userName

              view.label_message.text = self.comments[indexPath.row].message

              view.label_message.numberOfLines = 0;

              

              let url = URL(string:(self.userModel?.profileImageUrl)!)

              URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, err) in

                  

                  DispatchQueue.main.async {

                      

                      view.imageview_profile.image = UIImage(data: data!)

                      view.imageview_profile.layer.cornerRadius = view.imageview_profile.frame.width/2

                      view.imageview_profile.clipsToBounds = true

                      

                  }

              }).resume()

              return view
    
    
        }
            return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableView.automaticDimension

      }
    
    

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.

    }
    
    /* 키보드창 내리기 */
         override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
               self.view.endEditing(true)
         }

    
    @IBAction func sendBtn(_ sender: Any) {
        createRoom()
    }
    
    
    func createRoom(){

        let createRoomInfo : Dictionary<String,Any> = [ "users" : [

            uid!: true,

            destinationUid! : true

            ]

        ]

        

        if(chatRoomUid == nil){
            // 방 생성 코드
            
            self.sendButton.isEnabled = false
            
            Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo, withCompletionBlock: {
                (err, ref) in
                if(err == nil) {
                    self.checkChatRoom()
                }
                
            })

        }else{

            let value: Dictionary<String,Any> = [

        

                    "uid" : uid!,

                    "message" : textfiled_message.text!

              

            ]

            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(value, withCompletionBlock: { (err, ref) in
                self.textfiled_message.text = ""
            })

        }

    }

    

    func checkChatRoom(){

        

        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue:true).observeSingleEvent(of: DataEventType.value,with: {

            (datasnapshot) in

            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                
                
                if let chatRoomdic = item.value as? [String:AnyObject] {
                    
                    let chatModel = ChatModel(JSON: chatRoomdic)
                    if(chatModel?.users[self.destinationUid!] == true) {
                        self.chatRoomUid = item.key
                        self.sendButton.isEnabled = true
                        self.getDestinationInfo()

                    }
    
                }
                
                

                self.chatRoomUid = item.key

            }

        })
    }
    
    
     func getDestinationInfo(){
      
        Database.database().reference().child("users").child(self.destinationUid!).observeSingleEvent(of: DataEventType.value, with: {
            (dataSnapshot) in
            self.userModel = UserModel()
            self.userModel?.setValuesForKeys(dataSnapshot.value as! [String:Any])
            self.getMessageList()
        })
    
         
     }

    
    
    

    
    
    

    func getMessageList(){

        Database.database().reference().child("chatrooms").child(self.chatRoomUid!).child("comments").observe(DataEventType.value, with: {
            
            (datasnapshot) in
            
            self.comments.removeAll()

                       

                       for item in datasnapshot.children.allObjects as! [DataSnapshot]{

                           let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])

                           self.comments.append(comment!)

                       }

                       self.tableview.reloadData()
                        if self.comments.count > 0{

                            self.tableview.scrollToRow(at: IndexPath(item:self.comments.count - 1,section:0), at: UITableView.ScrollPosition.bottom, animated: true)

                              

                          }

            
            
        })

   
         

     }





}
   


class MymessageCell : UITableViewCell {
    
    @IBOutlet weak var label_message: UILabel!
}


class DestinationMessageCell : UITableViewCell {
    @IBOutlet weak var label_message: UILabel!
    @IBOutlet weak var imageview_profile: UIImageView!
    @IBOutlet weak var label_name: UILabel!
    
}
