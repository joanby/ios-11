//
//  DatabaseService.swift
//  Tinsnapook
//
//  Created by Juan Gabriel Gomila Salas on 14/7/17.
//  Copyright © 2017 Frogames. All rights reserved.
//


let FIR_CHILD_USERS = "users"


import Foundation
import FirebaseDatabase
import FirebaseStorage

class DatabaseService {
    
    private static let _shared = DatabaseService()
    
    static var shared : DatabaseService {
        return _shared
    }
    
    var mainRef : DatabaseReference {
        return Database.database().reference()
    }
    
    var usersRef : DatabaseReference {
        return mainRef.child(FIR_CHILD_USERS)
    }
    
    var snapsRef : DatabaseReference {
        return mainRef.child("snaps")
    }
    
    var mainStorageRef : StorageReference {
        return Storage.storage().reference(forURL: "gs://tinsnapook-edaab.appspot.com/")
    }
    
    var imageStorageRef:StorageReference {
        return mainStorageRef.child("images")
    }
    
    var videoStorageRef:StorageReference {
        return mainStorageRef.child("videos")
    }
    
    func saveUser(uid: String){
       
        let profile: Dictionary<String, AnyObject> = ["firstName": "" as AnyObject, "lastName": "" as AnyObject]
        self.mainRef.child(FIR_CHILD_USERS).child(uid).child("profile").setValue(profile)
    }
    
    func sendSnap(senderUID: String, receivers: Dictionary<String,TinsnapookUser>, mediaURL: URL, textSnippet : String? = nil){
        
        var users = Dictionary<String, Bool>()
        
        for uid in receivers.keys {
            users[uid] = true
        }
        
        
        let snap : Dictionary<String, AnyObject> = [
            "mediaURL": mediaURL.absoluteString as AnyObject,
            "textSnippet" : textSnippet as AnyObject,
            "userID"  : senderUID as AnyObject,
            "openCount" : 0 as AnyObject,
            "timeStamp" : String(describing: Date()) as AnyObject,
            "message"  : "" as AnyObject,
            "receivers" : users as AnyObject
        ]
        
        let child = self.snapsRef.childByAutoId()
        child.setValue(snap)
    
        let key = child.key //identificador del snap
        
        
    self.usersRef.child(AuthService.shared.user!.uid).child("snapsSent").observeSingleEvent(of: .value) { (snapshot) in
            
            var snapsSent = [String]()
            if let currentSnaps = snapshot.value as? [String]{
                snapsSent = currentSnaps
            }
        snapsSent.append(key!)
        self.usersRef.child(AuthService.shared.user!.uid).child("snapsSent").setValue(snapsSent)
        }
        
        
        for uid in receivers.keys {
            self.usersRef.child(uid).child("snapsReceived").observeSingleEvent(of: .value) { (snapshot) in
                
                var snapsReceived = [String]()
                if let currentSnaps = snapshot.value as? [String]{
                    snapsReceived = currentSnaps
                }
                snapsReceived.append(key!)
            self.usersRef.child(uid).child("snapsReceived").setValue(snapsReceived)
            }
        }
    }
    
    
}
