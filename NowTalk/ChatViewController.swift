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

    
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomLayout: NSLayoutConstraint!
    
    
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
      
        
        
        // [x] TODO: 키보드 디텍션
            NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        
       
        
    }
    
    
    // 컨트롤러 종료시
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        self.tabBarController?.tabBar.isHidden = false
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

extension ChatViewController {
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
   


class MymessageCell : UITableViewCell {
    
    @IBOutlet weak var label_message: UILabel!
}


class DestinationMessageCell : UITableViewCell {
    @IBOutlet weak var label_message: UILabel!
    @IBOutlet weak var imageview_profile: UIImageView!
    @IBOutlet weak var label_name: UILabel!
    
}
