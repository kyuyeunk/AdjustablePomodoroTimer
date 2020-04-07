//
//  SwitchTableViewCell.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/16.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {

    var settingStackView = UIStackView()
    var settingTextLabel = UILabel()
    var settingSwitch = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(settingStackView)
        settingStackView.addArrangedSubview(settingTextLabel)
        settingStackView.addArrangedSubview(settingSwitch)

        settingStackView.axis = .horizontal
        settingStackView.distribution = .fill
        
        settingStackView.translatesAutoresizingMaskIntoConstraints = false
        settingStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        settingStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        settingStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        settingStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
