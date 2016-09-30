//
//  SongTableViewCell.swift
//  musicPlayerRevamped
//
//  Created by Sean Calkins on 9/30/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit

class SongTableViewCell: UITableViewCell {

    @IBOutlet var trackNumberLabel: UILabel!
    @IBOutlet var songTitleLabel: UILabel!
    @IBOutlet var nowPlayingIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
