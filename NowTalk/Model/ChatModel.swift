//
//  ChatModel.swift
//  NowTalk
//
//  Created by 장성구 on 2020/05/21.
//  Copyright © 2020 com.sg. All rights reserved.
//

import UIKit

@objcMembers
class ChatModel: NSObject {
    
   public var users: Dictionary<String,Bool> = [:] // 채팅방에 참여한 사람들

      public var comments: Dictionary<String,Comment> = [:] // 채팅방의 대화내용

      

      public class Comment{

          public var uid: String?

          public var message: String?

      }

}
