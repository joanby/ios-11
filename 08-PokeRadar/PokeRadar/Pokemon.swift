//
//  Pokemon.swift
//  PokeRadar
//
//  Created by Juan Gabriel Gomila Salas on 3/7/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import Foundation
import UIKit

class Pokemon: NSObject {
    var id : Int
    var name: String
    var image: UIImage
    
    init(id: Int, name: String){
        
        self.id = id
        self.name = name
        self.image = UIImage(named: "\(id).png")!
        
    }
    
    
    
}
