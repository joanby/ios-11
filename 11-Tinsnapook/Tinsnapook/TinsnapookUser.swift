//
//  User.swift
//  Tinsnapook
//
//  Created by Juan Gabriel Gomila Salas on 15/7/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import Foundation

struct TinsnapookUser {
    private var _username : String
    private var _uid : String
    
    var uid: String {
        return _uid
    }
    
    var username:String{
        get{
            return _username
        }
        set {
            self._username = newValue
        }
    }
    
    init(uid:String, firstName:String, lastName: String){
        self._uid = uid
        self._username = "\(firstName) \(lastName)"
    }

}
