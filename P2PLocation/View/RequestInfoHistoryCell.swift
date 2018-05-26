//
//  RequestInfoHistoryCell.swift
//  P2PLocation
//
//  Created by MyCom on 5/17/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import UIKit

class RequestInfoHistoryCell: UITableViewCell {
    
    @IBOutlet var dateString: UILabel!
    @IBOutlet var latstr: UILabel!
    @IBOutlet var lonstr: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
