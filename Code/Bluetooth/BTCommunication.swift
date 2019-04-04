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
    var previousDataC: Data?
    var previousDataD: Data?
    
    
    /// Takes in controller inputs and prepares them to be sent on to the BT device
    ///
    /// - Parameter position: A snapshot of all inputs on the controller, taken every 1ms
    func sendRemoteData(_ position : GCExtendedGamepadSnapshot){
        print("Sending Controller data ----->")
        let leftTrigger = String(format: "%.2f", position.leftTrigger.value)
        let rightTrigger = String(format: "%.2f", position.rightTrigger.value)
        let leftThumbStick = String(format: "%.2f", position.leftThumbstick.xAxis.value)
        let rightThumbStick = String(format: "%.2f", position.rightThumbstick.xAxis.value)

        let firstPos = "!C:lf\(leftTrigger):rs\(rightThumbStick)$" as NSString
        let secondPos = "!D:rt\(rightTrigger):ls\(leftThumbStick)$" as NSString

        
        let firstPosData = firstPos.data(using: String.Encoding.utf8.rawValue)
        let secondPosData = secondPos.data(using: String.Encoding.utf8.rawValue)
        newPosition(firstPosData!, "C", leftTrigger, rightThumbStick)
        newPosition(secondPosData!, "D", rightTrigger, leftThumbStick)

    }
    
    // Check to see if the possition has has already been sent
    func newPosition(_ position: Data, _ name: NSString, _ trigger: String, _ thumb: String){
        if name == "C" && position != previousDataC {
            print("Sending C - L Trigger: \(trigger) R Thumb: \(thumb)")
            sendPosition(position)
            previousDataC = position
        }
        else if name == "D" && position != previousDataD {
            print("Sending D - R Trigger: \(trigger) L Thumb: \(thumb)")
            sendPosition(position)
            previousDataD = position
        }
    }
    

    func sendPosition(_ position: Data) {
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
