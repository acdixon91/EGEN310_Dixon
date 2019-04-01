//
//  BTCommunication.swift
//  ArduinoBluetooth
//
//  Created by Andrew Dixon on 3/31/19.
//  Copyright © 2019 Andrew Dixon. All rights reserved.
//

import Foundation
import GameController

class BTCommunication {
    
    var previousData
    
    func sendRemoteData(_ position : GCExtendedGamepadSnapshot){
        let leftTrigger = position.leftTrigger
        let rightTrigger = position.rightTrigger
        let leftThumbStick = position.leftThumbstick
        let rightThumbStick = position.rightThumbstick
        let dPad = position.dpad
        
        let totalPos = "!ltr\(leftTrigger.value)rtr\(rightTrigger.value)lth\(leftThumbStick.xAxis.value)rth\(rightThumbStick.xAxis.value)dpa\(dPad.xAxis.value)"
        let totalPosData = totalPos.data(using: String.Encoding.utf8)
        
        
        // Send position to BLE Shield (if service exists and is connected)
        if let bleService = btDiscoverySharedInstance.bleService {
            print("sending location")
            bleService.writeData(totalPosData!)
            previousData = totalPosData
            
            // Start delay timer
            allowTX = false
            if timerTXDelay == nil {
                timerTXDelay = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.timerTXDelayElapsed), userInfo: nil, repeats: false)
            }
        }
    }
}
