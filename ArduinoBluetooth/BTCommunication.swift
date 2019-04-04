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
        print("sending remote data ----->")
        let leftTrigger = String(format: "%.2f", position.leftTrigger.value)
        let rightTrigger = String(format: "%.2f", position.rightTrigger.value)
        let leftThumbStick = String(format: "%.2f", position.leftThumbstick.xAxis.value)
        let rightThumbStick = String(format: "%.2f", position.rightThumbstick.xAxis.value)
        let dPad = String(format: "%.2f", position.dpad.xAxis.value)
        
//        let totalPos = "!Cltr:$" as NSString
        let firstPos = "!C:lf\(leftTrigger):rt\(rightTrigger)$" as NSString
        let secondPos = "!D:ls\(leftThumbStick):rs\(rightThumbStick)$" as NSString
        print(firstPos)
        print(secondPos)
        let firstPosData = firstPos.data(using: String.Encoding.utf8.rawValue)
        let secondPosData = secondPos.data(using: String.Encoding.utf8.rawValue)
        sendPosition(firstPosData!)
        sendPosition(secondPosData!)
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
                timerTXDelay = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(BTCommunication.timerTXDelayElapsed), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc func timerTXDelayElapsed() {
        self.allowTX = true
        self.stopTimerTXDelay()
        
        // Send buffer data
        if inBuffer == true {
            sendPosition(buffer.removeFirst()!)
            buffer.removeAll()
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