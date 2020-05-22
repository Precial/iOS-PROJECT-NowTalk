//
//  ChatModel.swift
//  NowTalk
//
//  Created by 장성구 on 2020/05/21.
//  Copyright © 2020 com.sg. All rights reserved.
//


import ObjectMapper



@objcMembers
class ChatModel: Mappable {

    
    public var users :Dictionary<String,Bool> = [:] //채팅방에 참여한 사람들

    public var comments :Dictionary<String,Comment> = [:] //채팅방의 대화내용

    required init?(map: Map) {

        

    }

    func mapping(map: Map) {

        users <- map["users"]

        comments <- map["comments"]

    }

    public class Comment :Mappable{

        public var uid : String?

        public var message : String?
        
        public var timestamp : Int?

        public required init?(map: Map) {

            

        }

        public  func mapping(map: Map) {

            uid <- map["uid"]

            message <- map["message"]
            timestamp <- map["timestamp"]

        }

    }

    

}
