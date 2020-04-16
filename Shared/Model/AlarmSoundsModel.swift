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
        let soundList = availableSystemSounds.sorted { $0.0 < $1.0 }
        for sound in soundList {
            list.append(alarmSoundInfo(id: sound.key, name: sound.value))
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

let availableSystemSounds: [Int: String] = [
    1000: "MailReceived"
    , 1001: "MailSent"
    , 1002: "VoicemailReceived"
    , 1003: "SMSReceived"
    , 1004: "SMSSent"
    , 1005: "CalendarAlert"
    , 1006: "LowPower"
    , 1007: "SMSReceived_Alert"
    , 1008: "SMSReceived_Alert"
    , 1009: "SMSReceived_Alert"
    , 1010: "SMSReceived_Alert"
    , 1011: "SMSReceived_Vibrate"
    , 1012: "SMSReceived_Alert"
    , 1013: "SMSReceived_Alert"
    , 1014: "SMSReceived_Alert"
    , 1015: "-"
    , 1016: "SMSSent"
    , 1020: "SMSReceived_Alert"
    , 1021: "SMSReceived_Alert"
    , 1022: "SMSReceived_Alert"
    , 1023: "SMSReceived_Alert"
    , 1024: "SMSReceived_Alert"
    , 1025: "SMSReceived_Alert"
    , 1026: "SMSReceived_Alert"
    , 1027: "SMSReceived_Alert"
    , 1028: "SMSReceived_Alert"
    , 1029: "SMSReceived_Alert"
    , 1030: "SMSReceived_Alert"
    , 1031: "SMSReceived_Alert"
    , 1032: "SMSReceived_Alert"
    , 1033: "SMSReceived_Alert"
    , 1034: "SMSReceived_Alert"
    , 1035: "SMSReceived_Alert"
    , 1036: "SMSReceived_Alert"
    , 1050: "USSDAlert"
    , 1051: "SIMToolkitTone"
    , 1052: "SIMToolkitTone"
    , 1053: "SIMToolkitTone"
    , 1054: "SIMToolkitTone"
    , 1055: "SIMToolkitTone"
    , 1057: "PINKeyPressed"
    , 1070: "AudioToneBusy"
    , 1071: "AudioToneCongestion"
    , 1072: "AudioTonePathAcknowledge"
    , 1073: "AudioToneError"
    , 1074: "AudioToneCallWaiting"
    , 1075: "AudioToneKey2"
    , 1100: "ScreenLocked"
    , 1101: "ScreenUnlocked"
    , 1102: "FailedUnlock"
    , 1103: "KeyPressed"
    , 1104: "KeyPressed"
    , 1105: "KeyPressed"
    , 1106: "ConnectedToPower"
    , 1107: "RingerSwitchIndication"
    , 1108: "CameraShutter"
    , 1109: "ShakeToShuffle"
    , 1110: "JBL_Begin"
    , 1111: "JBL_Confirm"
    , 1112: "JBL_Cancel"
    , 1113: "BeginRecording"
    , 1114: "EndRecording"
    , 1115: "JBL_Ambiguous"
    , 1116: "JBL_NoMatch"
    , 1117: "BeginVideoRecording"
    , 1118: "EndVideoRecording"
    , 1150: "VCInvitationAccepted"
    , 1151: "VCRinging"
    , 1152: "VCEnded"
    , 1153: "VCCallWaiting"
    , 1154: "VCCallUpgrade"
    , 1200: "TouchTone"
    , 1201: "TouchTone"
    , 1202: "TouchTone"
    , 1203: "TouchTone"
    , 1204: "TouchTone"
    , 1205: "TouchTone"
    , 1206: "TouchTone"
    , 1207: "TouchTone"
    , 1208: "TouchTone"
    , 1209: "TouchTone"
    , 1210: "TouchTone"
    , 1211: "TouchTone"
    , 1254: "Headset_StartCall"
    , 1255: "Headset_Redial"
    , 1256: "Headset_AnswerCall"
    , 1257: "Headset_EndCall"
    , 1258: "Headset_CallWaitingActions"
    , 1259: "Headset_TransitionEnd"
    , 1300: "SystemSoundPreview"
    , 1301: "SystemSoundPreview"
    , 1302: "SystemSoundPreview"
    , 1303: "SystemSoundPreview"
    , 1304: "SystemSoundPreview"
    , 1305: "SystemSoundPreview"
    , 1306: "KeyPressClickPreview"
    , 1307: "SMSReceived_Selection"
    , 1308: "SMSReceived_Selection"
    , 1309: "SMSReceived_Selection"
    , 1310: "SMSReceived_Selection"
    , 1311: "SMSReceived_Vibrate"
    , 1312: "SMSReceived_Selection"
    , 1313: "SMSReceived_Selection"
    , 1314: "SMSReceived_Selection"
    , 1315: "SystemSoundPreview"
    , 1320: "SMSReceived_Selection"
    , 1321: "SMSReceived_Selection"
    , 1322: "SMSReceived_Selection"
    , 1323: "SMSReceived_Selection"
    , 1324: "SMSReceived_Selection"
    , 1325: "SMSReceived_Selection"
    , 1326: "SMSReceived_Selection"
    , 1327: "SMSReceived_Selection"
    , 1328: "SMSReceived_Selection"
    , 1329: "SMSReceived_Selection"
    , 1330: "SMSReceived_Selection"
    , 1331: "SMSReceived_Selection"
    , 1332: "SMSReceived_Selection"
    , 1333: "SMSReceived_Selection"
    , 1334: "SMSReceived_Selection"
    , 1335: "SMSReceived_Selection"
    , 1336: "SMSReceived_Selection"
    , 1350: "RingerVibeChanged"
    , 1351: "SilentVibeChanged"
    , 4095: "Vibrate" ]
