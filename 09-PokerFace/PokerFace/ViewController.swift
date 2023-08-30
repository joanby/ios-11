//
//  ViewController.swift
//  PokerFace
//
//  Created by Juan Gabriel Gomila Salas on 7/7/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @IBOutlet weak var blurSlider: UISlider!
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    var inputImage : UIImage?
    
    var showSquares = true
    
    var detectedFaces = [(observation: VNFaceObservation, isBlurred: Bool)]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.isUserInteractionEnabled = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(toggleSquares))
        recognizer.numberOfTapsRequired = 2
        self.imageView.addGestureRecognizer(recognizer)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takePhoto))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePhoto))
        
        
        let filters = CIFilter.filterNames(inCategories: nil)
        
        for filterName in filters {
            print("Filter : \(filterName)")
            //print("Parámetros: \(CIFilter(name: filterName)?.attributes)")
        }
        
        
        
        
            
    }
    
    override func viewDidLayoutSubviews() {
        addFaceRects()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @objc func takePhoto(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let pickedImage = info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage else {
            return
        }
        
        self.inputImage = pickedImage
        self.imageView.image = self.inputImage
        
        dismiss(animated: true) {
            //Detectar la cara de los usuarios
            self.detectFaces()
        }
    }
    
    
    func detectFaces(){
        guard let inputImage = self.inputImage else { return }
        guard let ciImage = CIImage(image: inputImage) else { return }
        
        let request = VNDetectFaceRectanglesRequest {  [unowned self]
            request, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let observations = request.results as? [VNFaceObservation] else { return }
                
                self.detectedFaces = Array(zip(observations, [Bool](repeating: false, count: observations.count)))
                
                self.addFaceRects()
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        do{
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
    
    
    func addFaceRects(){
        //Elimina rectángulos anteriores
        self.imageView.subviews.forEach {$0.removeFromSuperview()}
        
        //Define el tamaño de la imagen dentro de la image view
        let imageRect = self.imageView.contentClippingRect
        
        for (index, face) in self.detectedFaces.enumerated(){
            //las fronteras de la cara
            let boundingBox = face.observation.boundingBox
            //Tamaño de la cara
            let size = CGSize(width: boundingBox.width*imageRect.width ,
                              height: boundingBox.height*imageRect.height)
            
            //POsición de la cara
            var origin = CGPoint(x: boundingBox.minX*imageRect.width,
                                 y: (1-face.observation.boundingBox.minY)*imageRect.height - size.height)
            
            //Offset
            origin.y += imageRect.minY
            
            //Colocamos la UIView
            let vw = UIView(frame: CGRect(origin: origin, size: size))
            vw.tag = index
            vw.layer.borderColor = UIColor.red.cgColor
            if showSquares {
                vw.layer.borderWidth = 2
            } else {
                vw.layer.borderWidth = 0
            }
            
            self.imageView.addSubview(vw)
            
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(faceTapped))
            recognizer.numberOfTapsRequired = 1
            vw.addGestureRecognizer(recognizer)
            
        }
        
    }
    
    func renderBlurredFaces(){
        
        guard let uiImage = inputImage else {return}
        guard let cgImage = uiImage.cgImage else {return}
        let ciImage = CIImage(cgImage: cgImage)
        
        guard let filter = CIFilter(name: "CIPixellate") else { return }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(Int(self.blurSlider.value), forKey: kCIInputScaleKey)
        
        guard let outputImage = filter.outputImage else { return }
        let blurredImage = UIImage(ciImage: outputImage)
         
        
        let renderer = UIGraphicsImageRenderer(size: uiImage.size)
        
        let result = renderer.image { ctx in
            uiImage.draw(at: .zero)
            
            let path = UIBezierPath()
            
            for face in detectedFaces {
                if face.isBlurred {
                    let boundingBox = face.observation.boundingBox
                    let size = CGSize(width: boundingBox.size.width * uiImage.size.width,
                                      height: boundingBox.size.height * uiImage.size.height)
                    let origin = CGPoint(x: boundingBox.minX * uiImage.size.width,
                                         y: (1-boundingBox.minY) * uiImage.size.height - size.height)
                    let rect = CGRect(origin: origin, size: size)
                    path.append(UIBezierPath(rect: rect))
                }
            }
            
            if !path.isEmpty {
                path.addClip()
                blurredImage.draw(at: .zero)
            }
            
        }
        
        self.imageView.image = result
        
    }
    
    @objc func faceTapped(_ sender: UITapGestureRecognizer) {
        
        guard let vw = sender.view else { return }
        let tag = vw.tag
        self.detectedFaces[tag].isBlurred = !self.detectedFaces[tag].isBlurred
        renderBlurredFaces()
    }
    
    
    @objc func sharePhoto(){
        guard let image = self.imageView.image else {return}
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @objc func toggleSquares(){
        showSquares = !showSquares
        detectFaces()
    }
    
    @IBAction func blurChanged() {
        self.renderBlurredFaces()
    }
    
}

