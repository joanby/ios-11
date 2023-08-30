//
//  UserTableViewCell.swift
//  Tinsnapook
//
//  Created by Juan Gabriel Gomila Salas on 15/7/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setCheckMark(selected: false)
    }

    func setCheckMark(selected: Bool){
        let image = selected ? #imageLiteral(resourceName: "msg_indicator_chk_1") : #imageLiteral(resourceName: "msg_indicator_1")
        self.accessoryView = UIImageView(image: image)
    }
    
    func updateUserUI(user: TinsnapookUser){
        self.userNameLabel.text = user.username
    }

}
