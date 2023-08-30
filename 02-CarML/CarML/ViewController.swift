//
//  ViewController.swift
//  CarML
//
//  Created by Juan Gabriel Gomila Salas on 10/6/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var modelSegmentedControl: UISegmentedControl!
    @IBOutlet weak var extrasSwitch: UISwitch!
    @IBOutlet weak var kmsLabel: UILabel!
    @IBOutlet weak var kmsSlider: UISlider!
    @IBOutlet weak var statusSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    
    //let cars = Cars()
    //UPDATE 2023
    let cars: Cars = {
        do {
            let config = MLModelConfiguration()
            return try Cars(configuration: config)
        } catch {
            print(error)
            fatalError("Couldn't create SleepCalculator")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stackView.setCustomSpacing(25, after: self.modelSegmentedControl)
        self.stackView.setCustomSpacing(25, after: self.extrasSwitch)
        self.stackView.setCustomSpacing(25, after: self.kmsSlider)
        self.stackView.setCustomSpacing(50, after: self.statusSegmentedControl)
        
        
        self.calculateValue()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func calculateValue() {
        
        //Formatear el valor del slider
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formattedKms = formatter.string(for: self.kmsSlider.value) ?? "0"
        self.kmsLabel.text = "Kilometraje: \(formattedKms) kms"
        
        //Hacer el cálculo del valor del coche con ML
        
        if let prediction = try? cars.prediction(
            modelo: Double(self.modelSegmentedControl.selectedSegmentIndex),
            extras: self.extrasSwitch.isOn ? Double(1.0) : Double(0.0),
            kilometraje: Double(self.kmsSlider.value),
            estado: Double(self.statusSegmentedControl.selectedSegmentIndex)){
            
            let clampValue = max(500, prediction.precio)
            
            formatter.numberStyle = .currency
            
            self.priceLabel.text = formatter.string(for: clampValue)
            
        } else {
            self.priceLabel.text = "Error"
        }
        
        
    }
    
    
    
}

