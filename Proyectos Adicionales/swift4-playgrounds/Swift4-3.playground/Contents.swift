//: Playground - noun: a place where people can play

import UIKit

//Keypaths mejorados

struct Crew {
    var name:String
    var rank:String
}

struct Spaceship {
    var name:String
    var maxSpeed:Double
    var captain:Crew
    
    func goToMaxSpeed(){
        print("\(name) ahora va a velocidad máxima de \(maxSpeed).")
    }
}

let janeway = Crew(name: "Kathryn Janeway", rank: "Capitana")
var voyager = Spaceship(name: "Voyager", maxSpeed: 5.5, captain: janeway)

let enterMaxSpeed = voyager.goToMaxSpeed

enterMaxSpeed()

let theCapt = voyager.captain.name

let jb = Crew(name: "JB", rank: "Novato")
voyager.captain = jb

print(theCapt)

let nameKeypath = \Spaceship.name
let speedKeypath = \Spaceship.maxSpeed
let captainName = \Spaceship.captain.name

let spaceshipName = voyager[keyPath: nameKeypath]
let spaceshipSpeed = voyager[keyPath: speedKeypath]
let spaceshipCaptain = voyager[keyPath: captainName]

let capt = \Spaceship.captain
let captName = capt.appending(path: \.name)
print(voyager[keyPath:captName])


