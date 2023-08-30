//
//  SnapTableViewCell.swift
//  Tinsnapook
//
//  Created by Juan Gabriel Gomila Salas on 17/7/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import UIKit

class SnapTableViewCell: UITableViewCell {
    @IBOutlet weak var snapImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var timeStampLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
