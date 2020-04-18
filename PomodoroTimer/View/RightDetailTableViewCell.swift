//
//  RightDetailTableViewCell.swift
//  PomodoroTimer
//
//  Created by Kyu Yeun Kim on 2020/04/10.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class RightDetailTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
