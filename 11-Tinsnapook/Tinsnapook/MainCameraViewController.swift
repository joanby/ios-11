//
//  ViewController.swift
//  Tinsnapook
//
//  Created by Juan Gabriel Gomila Salas on 10/7/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import UIKit
import FirebaseAuth

class MainCameraViewController: CameraViewController, AAPLCameraViewDelegate {

    @IBOutlet weak var previewView: PreviewView!
    
    @IBOutlet weak var captureModeControl: UISegmentedControl!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var cameraUnavailableLabel: UILabel!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var livePhotoModeButton: UIButton!
    @IBOutlet weak var depthDataDeliveryButton: UIButton!
    @IBOutlet weak var capturingLivePhotoLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!

    
    override func viewDidLoad() {
        
        self.delegate = self
        
        super._previewView = self.previewView
        
        super._captureModeControl = self.captureModeControl
        self.captureModeControl.addTarget(self, action: #selector(toggleCaptureMode), for: .valueChanged)
        
        super._cameraButton = self.cameraButton
        self.cameraButton.addTarget(self, action: #selector(changeCamera), for: .touchUpInside)
        
        super._photoButton = self.photoButton
        self.photoButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        
        super._livePhotoModeButton = self.livePhotoModeButton
        self.livePhotoModeButton.addTarget(self, action: #selector(toggleLivePhotoMode), for: .touchUpInside)
        
        super._depthDataDeliveryButton = self.depthDataDeliveryButton
        self.depthDataDeliveryButton.addTarget(self, action: #selector(toggleDepthDataDeliveryMode), for: .touchUpInside)
        
        super._recordButton = self.recordButton
        self.recordButton.addTarget(self, action: #selector(toggleMovieRecording), for: .touchUpInside)
        
        super._resumeButton = self.resumeButton
        self.resumeButton.addTarget(self, action: #selector(resumeInterruptedSession), for: .touchUpInside)
        
        super._cameraUnavailableLabel = self.cameraUnavailableLabel
        super._capturingLivePhotoLabel = self.capturingLivePhotoLabel
        
        self.cameraUnavailableLabel.alpha = 0.0
        self.capturingLivePhotoLabel.alpha = 0.0
        
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //performSegue(withIdentifier: "showLoginVC", sender: nil)

        guard Auth.auth().currentUser != nil else {
            performSegue(withIdentifier: "showLoginVC", sender: nil)
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: AAPLCameraViewDelegate Methods
    
    let segueID: String = "ShowFriends"
    
    func videoRecordingComplete(videoURL: URL) {
        print("URL del video \(videoURL)")
        performSegue(withIdentifier: segueID, sender: ["videoURL":videoURL])
    }
    
    func videoRecordingFailed(errorMessage: String?) {
        if let error = errorMessage{
            print(error)
        }
    }

    func imageTaken(data: Data) {
        print("imagen tomada: \(data)")
        performSegue(withIdentifier: segueID, sender : ["imageData":data])
    }
    
    func imageFailed(errorMessage: String?) {
        if let error = errorMessage{
            print(error)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let usersVC = segue.destination as? UsersTableViewController {
            if let videoDict = sender as? Dictionary<String,URL> {
                let videoURL = videoDict["videoURL"]
                usersVC.videoURL = videoURL
            } else if let imageDict = sender as? Dictionary<String, Data> {
                let imageData = imageDict["imageData"]
                usersVC.imageData = imageData
            }
        }
    }
    
    
    @IBAction func leftGesture(_ sender: UISwipeGestureRecognizer) {
        self.performSegue(withIdentifier: "ShowSnaps", sender: nil)
    }
    
    @IBAction func rightGesture(_ sender: UISwipeGestureRecognizer) {
        self.performSegue(withIdentifier: "ShowUsers", sender: nil)
    }
    
    

}

