//
//  SwitchTableViewCell.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/16.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var settingTextLabel: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initiaization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
