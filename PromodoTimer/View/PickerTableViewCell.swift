//
//  PickerTableViewCell.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/18.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class PickerTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(dataSource[row])
    }
    var dataSource: [Int] = []
    @IBOutlet weak var pickerView: UIPickerView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        pickerView.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
