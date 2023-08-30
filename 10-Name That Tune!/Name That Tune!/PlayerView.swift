//
//  PlayerView.swift
//  Name That Tune!
//
//  Created by Juan Gabriel Gomila Salas on 16/8/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import UIKit

class PlayerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    weak var controller: GameViewController?
    var picker = UIPickerView()
    var selectButton = UIButton(type: .custom)
    var sortedSongs = [Song]()
    
    
    init(color: UIColor, songs: [Song], controller: GameViewController){
        
        super.init(frame: .zero)
        
        self.controller = controller
        self.selectButton.backgroundColor = color
        self.sortedSongs = songs.sorted(by: { (s1, s2) -> Bool in
            return s1<s2
        })
        self.backgroundColor = color
        self.picker.backgroundColor = .white
        
        self.picker.dataSource = self
        self.picker.delegate = self
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(picker)
        self.addSubview(selectButton)
        
        picker.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        picker.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        picker.topAnchor.constraint(equalTo: topAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: selectButton.topAnchor).isActive = true
        
        selectButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        selectButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        selectButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        selectButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        selectButton.setTitle("Seleccionar cancion", for: .normal)
        selectButton.setTitleColor(.white, for: .normal)
        selectButton.showsTouchWhenHighlighted = true
        
        selectButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortedSongs.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortedSongs[row].attributes.name
    }
    
    @objc func buttonTapped(){
        let selectedSong = sortedSongs[picker.selectedRow(inComponent: 0)]
        controller?.selectSong(player: selectButton.backgroundColor!, playerAnswer: selectedSong)
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
