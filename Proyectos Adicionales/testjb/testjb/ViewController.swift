//
//  ViewController.swift
//  testjb
//
//  Created by Juan Gabriel Gomila Salas on 9/6/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var titleImageView: UIImageView!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var pressButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleImageView.isHidden = true
        self.backgroundImageView.isHidden = true
        self.pressButton.isHidden = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        print("He pulsado un botóoon 🤡")
        
        self.titleImageView.isHidden = false
        self.backgroundImageView.isHidden = false
        self.pressButton.isHidden = true
        
    }
    
    

}

