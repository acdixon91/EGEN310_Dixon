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
    
    var timerTXDelay: Timer?
    var allowTX = true
    var lastPosition: UInt8 = 255
    var buffer: [Data?] = []
    var inBuffer = false
    var previousData: Data?
    
    func sendRemoteData(_ position : GCExtendedGamepadSnapshot){
        let leftTrigger = position.leftTrigger
        let rightTrigger = position.rightTrigger
        let leftThumbStick = position.leftThumbstick
        let rightThumbStick = position.rightThumbstick
        let dPad = position.dpad
        
        let totalPos = "!ltr\(leftTrigger.value)rtr\(rightTrigger.value)lth\(leftThumbStick.xAxis.value)rth\(rightThumbStick.xAxis.value)dpa\(dPad.xAxis.value)"
        let totalPosData = totalPos.data(using: String.Encoding.utf8)
        
        sendPosition(totalPosData!)
    }
    
    func sendPosition(_ position: Data) {
        // Valid position range: 0 to 180
        print("SendPosition function called from within BTCom")
        print(allowTX)
        if !allowTX {
            if(position != previousData){
                buffer.append(position)
                inBuffer = true
            }
            return
        }
        
        // Send position to BLE Shield (if service exists and is connected)
        if let bleService = btDiscoverySharedInstance.bleService {
            print("sending location")
            bleService.writeData(position)
            
            print(position)
            previousData = position
            
            // Start delay timer
            allowTX = false
            if timerTXDelay == nil {
                timerTXDelay = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BTCommunication.timerTXDelayElapsed), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc func timerTXDelayElapsed() {
        self.allowTX = true
        self.stopTimerTXDelay()
        
        // Send buffer data
        if inBuffer == true {
            sendPosition(buffer.removeFirst()!)
            if(buffer.isEmpty){
                inBuffer = false
            }
        }
    }
    
    func stopTimerTXDelay() {
        if self.timerTXDelay == nil {
            return
        }
        
        timerTXDelay?.invalidate()
        self.timerTXDelay = nil
    }
}
