//
//  ViewController.swift
//  AimForThat2017
//
//  Created by Juan Gabriel Gomila Salas on 27/6/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import UIKit
import QuartzCore

class GameViewController: UIViewController {
    
    
    var currentValue : Int = 0
    var targetValue  : Int = 0
    var score        : Int = 0
    var round        : Int = 0
    var time         : Int = 0
    var timer        : Timer?
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var targetLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var roundLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var maxScoreLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSlider()
        
        resetGame()
        updateLabels()
    }
    
    func setupSlider(){
        let thumbImageNormal = #imageLiteral(resourceName: "SliderThumb-Normal")
        let thumbImageHighlighted = #imageLiteral(resourceName: "SliderThumb-Highlighted")
        let trackLeftImage = #imageLiteral(resourceName: "SliderTrackLeft")
        let trackRightImage = #imageLiteral(resourceName: "SliderTrackRight")
        
        self.slider.setThumbImage(thumbImageNormal, for: .normal)
        self.slider.setThumbImage(thumbImageHighlighted, for: .highlighted)
        
        let insets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        
        let trackLeftResizable = trackLeftImage.resizableImage(withCapInsets: insets)
        let trackRightResizable = trackRightImage.resizableImage(withCapInsets: insets)
        
        self.slider.setMinimumTrackImage(trackLeftResizable, for: .normal)
        self.slider.setMaximumTrackImage(trackRightResizable, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showAlert() {
        
        /*var difference : Int = 0
        
        if self.currentValue > self.targetValue {
            difference = self.currentValue - self.targetValue
        } else {
            difference = self.targetValue - self.currentValue
        }*/
        
        /*var difference : Int = self.currentValue - self.targetValue
        if difference < 0 {
            difference *= -1
        }*/
        
        let difference : Int = abs(self.currentValue - self.targetValue)
        
        var points = 100 - difference
        
        let title: String
        
        switch difference {
        case 0:
            title = "¡¡¡Puntuación perfecta!!!"
            points = Int(10.0*Float(points))
        case 1...5:
            title = "Casi perfecto!"
            points = Int(1.5*Float(points))
        case 6...12:
            title = "Te ha faltado poco..."
            points = Int(1.2*Float(points))
        default:
            title = "Has ido lejos..."
        }
        
        let message = "Has marcado \(points) puntos"
        
        self.score += points
        
        let alert = UIAlertController(title: title,
                                      message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK!", style: .default, handler:
            { action in
                self.startNewRound()
            
                self.updateLabels()
            })
        
        alert.addAction(action)
        
        present(alert, animated: true)
        
        
    }
    
    @IBAction func sliderMoved(_ sender: UISlider) {
        self.currentValue = lroundf(sender.value)
        
    }
    
    
    func startNewRound(){
        self.targetValue = 1 + Int(arc4random_uniform(100))
        self.currentValue = 50
        self.slider.value = Float(self.currentValue)
        self.round += 1
    }
    
    func updateLabels() {
        self.targetLabel.text = "\(self.targetValue)"
        self.scoreLabel.text  = "\(self.score)"
        self.roundLabel.text  = "\(self.round)"
        self.timeLabel.text   = "\(self.time)"
    }
    
    @IBAction func startNewGame(){
        resetGame()
        updateLabels()
        
        let transition = CATransition()
        transition.type = CATransitionType.fade//UPDATE 2023
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        self.view.layer.add(transition, forKey: nil)//UPDATE 2023
    }
    
    func resetGame(){
        //Comprobamos puntuación máxima aquí
        var maxscore = UserDefaults.standard.integer(forKey: "maxscore")
        
        if maxscore < self.score {
            maxscore = self.score
            UserDefaults.standard.set(maxscore, forKey: "maxscore")
        }
        
        self.maxScoreLabel.text = "\(maxscore)"
        
        //Reiniciamos variables de juego
        self.score = 0
        self.round = 0
        self.time = 60
        
        //Reiniciamos el temporizador
        if timer != nil {
            timer?.invalidate()
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        
        self.updateLabels()
        
        self.startNewRound()
    }
    
    @objc func tick(){
        
        self.time -= 1
        self.timeLabel.text   = "\(self.time)"
        
        if self.time <= 0 {
            
            self.resetGame()
        }
    }
    

}

