//
//  AlarmSoundsTableViewController.swift
//  PomodoroTimer
//
//  Created by Kyu Yeun Kim on 2020/04/10.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class AlarmSoundsTableViewController: UITableViewController {
    var selectedAlarmID = 0
    var type: TimerType = .positive
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "defaultCell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(doneButtonPressed))
        navigationItem.title = "Alarms"
        let selectedIndexPath = IndexPath(row: selectedAlarmID, section: 0)
        tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .middle)
    }

    @objc func doneButtonPressed() {
        if let navigation = self.navigationController,
            let timerSettings = navigation.viewControllers[2] as? TimerSettingsTableViewController {
            
            timerSettings.workingTimerModel.timerAlarmID[type] = selectedAlarmID
            timerSettings.tableView.reloadData()
            navigation.popViewController(animated: true)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalVar.alarmSounds.list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        let alarmInfo = GlobalVar.alarmSounds.list[indexPath.row]
        if GlobalVar.alarmSounds.list[selectedAlarmID].systemSoundID == alarmInfo.systemSoundID {
            cell.imageView?.image = UIImage(systemName: "circle.fill")!
        }
        else {
            cell.imageView?.image = UIImage(systemName: "circle")!
        }
        cell.textLabel?.text = alarmInfo.alarmName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alarmInfo = GlobalVar.alarmSounds.list[indexPath.row]
        AudioServicesPlaySystemSound(SystemSoundID(alarmInfo.systemSoundID))
        let prevSelectedIndexPath = IndexPath(row: selectedAlarmID, section: 0)
        selectedAlarmID = indexPath.row
        tableView.reloadRows(at: [prevSelectedIndexPath, indexPath], with: .automatic)
    }
}
