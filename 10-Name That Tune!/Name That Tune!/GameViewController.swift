//
//  GameViewController.swift
//  Name That Tune!
//
//  Created by Juan Gabriel Gomila Salas on 16/8/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import UIKit
import MediaPlayer

class GameViewController: UIViewController {

    var songs = [Song]()
    var currentSong: Song!
    
    var player1: PlayerView!
    var player2: PlayerView!
    
    let score1Label = UILabel()
    let score2Label = UILabel()
    
    let musicPlayerController : MPMusicPlayerController = .systemMusicPlayer
    
    
    var score1 = 0 {
        didSet{
            score1Label.text = "ROJO: \(score1)"
        }
    }
    
    var score2 = 0 {
        didSet{
            score2Label.text = "AZUL: \(score2)"
        }
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configurePlayerViews()
        configureScoreLabels()
        
        playNextSong()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func configurePlayerViews(){
        player1 = PlayerView(color: .red, songs: songs, controller: self)
        player2 = PlayerView(color: .blue, songs: songs, controller: self)
        
        
        for case let playerView? in [player1, player2]{
            playerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(playerView)
            
            //Hacer que cada player view ocupe todo el espacio que queramos
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            playerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5, constant: -25).isActive = true
        }
        
        player1.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        player2.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        player1.transform = CGAffineTransform(rotationAngle: .pi)
    }
    
    func configureScoreLabels(){
        for score in [score1Label, score2Label]{
            
            score.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(score)
            
            score.textAlignment = .center
            score.textColor = .white
            score.font = UIFont.boldSystemFont(ofSize: 20)
            score.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            score.heightAnchor.constraint(equalToConstant: 50).isActive = true
            score.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
            
        }
        
        score1Label.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        score2Label.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        score1Label.backgroundColor = .red
        score2Label.backgroundColor = .blue
        
        score1Label.transform = CGAffineTransform(rotationAngle: .pi)
        
        score1 = 0
        score2 = 0
        
    }
    
    
    func playNextSong(){
        if let song = songs.popLast() {
            currentSong = song
            let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: [song.id])
            musicPlayerController.setQueue(with: descriptor)
            musicPlayerController.play()
        } else {
            musicPlayerController.stop()
            let alertController = UIAlertController(title: "Fin del Juego", message: "J1: \(score1)\nJ2: \(score2)", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true)
        }
    }
    
    func selectSong(player: UIColor, playerAnswer: Song){
        if playerAnswer == currentSong{
            if player == .red {
                score1 += 1
            } else {
                score2 += 1
            }
            
            playNextSong()
        }
        
    }


}
