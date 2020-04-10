//
//  AlarmSoundsInfo.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/04/10.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation

class AlarmSounds {
    var list: [alarmSoundInfo] = []
    
    init() {
        for i in 0 ..< availableSystemSoundID.count {
            list.append(alarmSoundInfo(id: availableSystemSoundID[i], name: correspondingSystemSoundName[i]))
        }
    }
}

struct alarmSoundInfo {
    var systemSoundID: Int
    var alarmName: String
    
    init(id: Int, name: String) {
        systemSoundID = id
        alarmName = name
    }
}


let availableSystemSoundID: [Int] = [ 1000
    , 1001
    , 1002
    , 1003
    , 1004
    , 1005
    , 1006
    , 1007
    , 1008
    , 1009
    , 1010
    , 1011
    , 1012
    , 1013
    , 1014
    , 1015
    , 1016
    , 1020
    , 1021
    , 1022
    , 1023
    , 1024
    , 1025
    , 1026
    , 1027
    , 1028
    , 1029
    , 1030
    , 1031
    , 1032
    , 1033
    , 1034
    , 1035
    , 1036
    , 1050
    , 1051
    , 1052
    , 1053
    , 1054
    , 1055
    , 1057
    , 1070
    , 1071
    , 1072
    , 1073
    , 1074
    , 1075
    , 1100
    , 1101
    , 1102
    , 1103
    , 1104
    , 1105
    , 1106
    , 1107
    , 1108
    , 1109
    , 1110
    , 1111
    , 1112
    , 1113
    , 1114
    , 1115
    , 1116
    , 1117
    , 1118
    , 1150
    , 1151
    , 1152
    , 1153
    , 1154
    , 1200
    , 1201
    , 1202
    , 1203
    , 1204
    , 1205
    , 1206
    , 1207
    , 1208
    , 1209
    , 1210
    , 1211
    , 1254
    , 1255
    , 1256
    , 1257
    , 1258
    , 1259
    , 1300
    , 1301
    , 1302
    , 1303
    , 1304
    , 1305
    , 1306
    , 1307
    , 1308
    , 1309
    , 1310
    , 1311
    , 1312
    , 1313
    , 1314
    , 1315
    , 1320
    , 1321
    , 1322
    , 1323
    , 1324
    , 1325
    , 1326
    , 1327
    , 1328
    , 1329
    , 1330
    , 1331
    , 1332
    , 1333
    , 1334
    , 1335
    , 1336
    , 1350
    , 1351
    , 4095 ]

let correspondingSystemSoundName: [String] = [ "MailReceived"
    , "MailSent"
    , "VoicemailReceived"
    , "SMSReceived"
    , "SMSSent"
    , "CalendarAlert"
    , "LowPower"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Vibrate"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "-"
    , "SMSSent"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "SMSReceived_Alert"
    , "USSDAlert"
    , "SIMToolkitTone"
    , "SIMToolkitTone"
    , "SIMToolkitTone"
    , "SIMToolkitTone"
    , "SIMToolkitTone"
    , "PINKeyPressed"
    , "AudioToneBusy"
    , "AudioToneCongestion"
    , "AudioTonePathAcknowledge"
    , "AudioToneError"
    , "AudioToneCallWaiting"
    , "AudioToneKey2"
    , "ScreenLocked"
    , "ScreenUnlocked"
    , "FailedUnlock"
    , "KeyPressed"
    , "KeyPressed"
    , "KeyPressed"
    , "ConnectedToPower"
    , "RingerSwitchIndication"
    , "CameraShutter"
    , "ShakeToShuffle"
    , "JBL_Begin"
    , "JBL_Confirm"
    , "JBL_Cancel"
    , "BeginRecording"
    , "EndRecording"
    , "JBL_Ambiguous"
    , "JBL_NoMatch"
    , "BeginVideoRecording"
    , "EndVideoRecording"
    , "VCInvitationAccepted"
    , "VCRinging"
    , "VCEnded"
    , "VCCallWaiting"
    , "VCCallUpgrade"
    , "TouchTone"
    , "TouchTone"
    , "TouchTone"
    , "TouchTone"
    , "TouchTone"
    , "TouchTone"
    , "TouchTone"
    , "TouchTone"
    , "TouchTone"
    , "TouchTone"
    , "TouchTone"
    , "TouchTone"
    , "Headset_StartCall"
    , "Headset_Redial"
    , "Headset_AnswerCall"
    , "Headset_EndCall"
    , "Headset_CallWaitingActions"
    , "Headset_TransitionEnd"
    , "SystemSoundPreview"
    , "SystemSoundPreview"
    , "SystemSoundPreview"
    , "SystemSoundPreview"
    , "SystemSoundPreview"
    , "SystemSoundPreview"
    , "KeyPressClickPreview"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Vibrate"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SystemSoundPreview"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "SMSReceived_Selection"
    , "RingerVibeChanged"
    , "SilentVibeChanged"
    , "Vibrate" ]
