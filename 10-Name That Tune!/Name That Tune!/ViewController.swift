//
//  ViewController.swift
//  Name That Tune!
//
//  Created by Juan Gabriel Gomila Salas on 12/8/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import UIKit
import GameplayKit
import StoreKit

class ViewController: UIViewController {

    let devToken = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IkRRM04yM0I3V00ifQ.eyJpc3MiOiJMVjRWNDhBVEs5IiwiaWF0IjoxNTAyOTkyOTAxLCJleHAiOjE1MDMwMzYxMDF9.A_AOhcReiZyslACv_FsPhaIApGLd70YMygWq1clwO7tfggkw8bpl9AueYa6-K6XtxlveI8BroSM8BDnfZZp1bw"
    
    let urlSession : URLSession = URLSession(configuration: .default)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let playButton = UIButton(type: .system)
        view.addSubview(playButton)
        
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 90)
    
        playButton.setTitle("Empezar el juego", for: .normal)
        
        playButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func startGame(){
        switch SKCloudServiceController.authorizationStatus() {
        case .notDetermined:
            SKCloudServiceController.requestAuthorization({ [weak self] authorizationStatus in
                DispatchQueue.main.async {
                    self?.startGame()
                }
            })
        case .authorized:
            requestCapabilities()
        default:
            self.showNoGameMessage("No tenemos permisos para utilizar la librería de Apple Music")
        }
    }
    
    func requestCapabilities(){
        print("requesting capabilities")

        let controller = SKCloudServiceController()
        controller.requestCapabilities { [weak self] (capabilities, error) in
            
            print("capabilities fetched")

            DispatchQueue.main.async {
                
                if let error = error {
                    self?.showNoGameMessage(error.localizedDescription)
                    return
                }
                
                if capabilities.contains(.musicCatalogPlayback){
                    //Podemos reproducir música =D
                    print("requesting country")

                    controller.requestStorefrontCountryCode(completionHandler: { (countryCode, error) in
                        if let countryCode = countryCode {
                            self?.fetchSongs(fromCountry: countryCode)
                        }else {
                            self?.showNoGameMessage("Imposible determinar el país del usuario...")
                        }
                    })
                }else if capabilities.contains(.musicCatalogSubscriptionEligible){
                    //Nos podemos suscribir (gratis o no) para jugar
                    print("creating subscribe controller")

                    let subscribeController = SKCloudServiceSetupViewController()
                    let options : [SKCloudServiceSetupOptionsKey: Any] =
                        [.action : SKCloudServiceSetupAction.subscribe,
                         .messageIdentifier: SKCloudServiceSetupMessageIdentifier.playMusic]
                    subscribeController.load(options: options, completionHandler: { (success, error) in
                        if success {
                            print("succes controller")
                            self?.present(subscribeController, animated: true)
                        }else {
                            self?.showNoGameMessage(error?.localizedDescription ?? "Error desconocido")
                        }
                    })
                }else {
                    //nada que hacer...
                    self?.showNoGameMessage("No puedes suscribirte a Apple Music...")
                }
                
            }
        
        }
        
        
        
    }
    
    func showNoGameMessage(_ message: String){
        let alertController = UIAlertController(title: "No puedes jugar", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }

    
    func fetchSongs(fromCountry countryCode: String){
        print("fetchSongs")
        var urlRequest = URLRequest(url: URL(string:"https://api.music.apple.com/v1/catalog/\(countryCode)/charts?types=songs")!)
        urlRequest.addValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                //Programar la lógica del procesado
                
                do{
                    //intentar descondificar el JSON
                    let decoder = JSONDecoder()
                    let musicResult = try decoder.decode(MusicResult.self, from: data)
                    
                    if let songs = musicResult.results.songs.first?.data {
                        let shuffledSongs = (songs as NSArray).shuffled() as! [Song]
                        //Mostrar el VC del juego
                        let gameVC = GameViewController()
                        gameVC.songs = shuffledSongs
                        self.present(gameVC, animated: true)
                        return
                    }
                    
                } catch{
                    //imprimir un mensaje de error al usuario...
                    print(error.localizedDescription)
                }
                self.showNoGameMessage("No se puede recibir información del servidor de Apple Music")
                
            }
        }
        task.resume()
    }

}

