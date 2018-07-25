//
//  DriveQueueCell.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit

protocol DriveQueueCellDelegate{
    func pickupPushed(cell: DriveQueueCell)
}

class DriveQueueCell: UITableViewCell {
    
    var delegate: DriveQueueCellDelegate?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBAction func pickupPushed(_ sender: UIButton) {
        delegate!.pickupPushed(cell: self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
