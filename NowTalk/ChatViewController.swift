//
//  ChatViewController.swift
//  NowTalk
//
//  Created by 장성구 on 2020/05/21.
//  Copyright © 2020 com.sg. All rights reserved.
//



import UIKit

import Firebase



class ChatViewController: UIViewController {
    

    var uid: String?

    var chatRoomUid: String?

        @IBOutlet weak var textfiled_message: UITextField!

    

    public var destinationUid: String? // 나중에 내가 채팅할 대상의 uid

    override func viewDidLoad() {

        super.viewDidLoad()

        uid = Auth.auth().currentUser?.uid


        checkChatRoom()

        // Do any additional setup after loading the view.

    }



    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.

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

        Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo)

        }else{

            let value: Dictionary<String,Any> = [

                "comments":[

                    "uid" : uid!,

                    "messaage" : textfiled_message.text!

                ]

            ]

            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(value)

        }

    }

    

    func checkChatRoom(){

        

        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue:true).observeSingleEvent(of: DataEventType.value,with: {

            (datasnapshot) in

            for item in datasnapshot.children.allObjects as! [DataSnapshot]{

                self.chatRoomUid = item.key

            }

        })

    }







}
   


