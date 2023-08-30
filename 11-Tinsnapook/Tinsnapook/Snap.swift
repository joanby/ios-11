//
//  Snap.swift
//  Tinsnapook
//
//  Created by Juan Gabriel Gomila Salas on 17/7/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import Foundation

struct Snap{
    var uid:String
    var snapOrder : Int
    var mediaURL: String?
    var message : String = ""
    var openCount : Int = 0
    var receivers : [TinsnapookUser] = []
    var textSnippet : String?
    var timeStamp : String?
    var sender : TinsnapookUser?
    var mediaData : Data?
    
    init(uid:String, snapOrder: Int){
        self.uid = uid
        self.snapOrder = snapOrder
    }
    
    init(uid: String, snapOrder: Int, mediaURL: String, message: String, openCount : Int, receivers : [TinsnapookUser], textSnippet : String, timeStamp : String, userID : String){
        self.uid = uid
        self.snapOrder = snapOrder
        self.mediaURL = mediaURL
        self.message = message
        self.openCount = openCount
        self.receivers = receivers
        self.textSnippet = textSnippet
        self.timeStamp = timeStamp
        self.sender = TinsnapookUser(uid: userID, firstName: "", lastName: "")
    }
}
