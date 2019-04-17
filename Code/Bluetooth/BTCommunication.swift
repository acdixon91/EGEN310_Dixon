//
//  BTCommunication.swift
//  ArduinoBluetooth
//
//  Created by Andrew Dixon on 3/31/19.
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
    var previousDataE: Data?
    
    
    /// Takes in controller inputs and prepares them to be sent on to the BT device
    ///
    /// - Parameter position: A snapshot of all inputs on the controller, taken every 1ms
    func sendRemoteData(_ position : GCExtendedGamepadSnapshot){
        print("Sending Controller data ----->")
        var leftTrigger = String(format: "%.0f", (position.leftTrigger.value + 0.5) * 150)
        var rightTrigger = String(format: "%.0f", (position.rightTrigger.value + 0.5) * 150)
        var leftThumbStick = String(format: "%.0f", (position.leftThumbstick.xAxis.value + 1) * 90)
        var rightThumbStick = String(format: "%.0f", (position.rightThumbstick.xAxis.value + 1) * 90)
        
        leftTrigger = (intSize(leftTrigger))
        rightTrigger = (intSize(rightTrigger))
        leftThumbStick = (intSize(leftThumbStick))
        rightThumbStick = (intSize(rightThumbStick))
        
        leftThumbStick = thumbLimiter(leftThumbStick)
        rightThumbStick = thumbLimiter(rightThumbStick)
//        leftThumbStick = formatThumbInput(leftThumbStick)
//        rightThumbStick = formatThumbInput(rightThumbStick)
        
        leftThumbStick = (intSize(leftThumbStick))

        let firstPos = "!C:lt\(leftTrigger)rs\(rightThumbStick)$" as NSString
        let secondPos = "!D:rt\(rightTrigger)ls\(leftThumbStick)$" as NSString
        let thirdPos = "!Et\(rightTrigger)s\(leftThumbStick)t\(leftTrigger)$" as NSString
        
        let firstPosData = firstPos.data(using: String.Encoding.utf8.rawValue)
        let secondPosData = secondPos.data(using: String.Encoding.utf8.rawValue)
        let thirdPosData = thirdPos.data(using: String.Encoding.utf8.rawValue)
        
        newPosition(firstPosData!, "C", leftTrigger, rightThumbStick)
        newPosition(secondPosData!, "D", rightTrigger, leftThumbStick)
        newPosition(thirdPosData!, "E", rightTrigger, leftThumbStick, leftTrigger)

    }
    
    // Check to see if the position has has already been sent
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
            print(position)
        }
    }
    
    func newPosition(_ position: Data, _ name: NSString, _ triggerA: String, _ thumb: String, _ triggerB: String){
        
        if name == "E" && position != previousDataC {
            print("Sending E - L Trigger: \(triggerA) R Thumb: \(thumb) R Trigger: \(triggerB)")
//            sendPosition(position)
            previousDataC = position
        }
        
    }
    
    //takes in postion data. Checks to see if 1ms timer has ended; if so - it sends data, if not - it adds to the buffer to be sent afterwards
    func sendPosition(_ position: Data) {
        
        if !allowTX {
            if(position != previousData){
                buffer.append(position)
                inBuffer = true
            }
            return
        }
        
        if let bleService = btDiscoverySharedInstance.bleService {          // Send position to BLE Shield (if service exists and is connected)
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
    
    //timer object
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
    
    //turns off timer
    func stopTimerTXDelay() {
        
        if self.timerTXDelay == nil {
            return
        }
        timerTXDelay?.invalidate()
        self.timerTXDelay = nil
    }
    
    
    //Changes the format of the outgoing string so that its always sending 3 digets
    func intSize(_ position: String) -> String{
        var stringPos = position
        let inPos = (position as NSString).integerValue
        
        if case 0 ... 9 = inPos{
            stringPos = "00\(stringPos)"
            return stringPos
        }
        else if case 10 ... 99 = inPos{
            stringPos = "0\(stringPos)"
            return stringPos
        }
        else{
        return stringPos
        }
    }
    
    
    //limits the thumbstick output to 60 - 120 degrees
    func formatThumbInput(_ position: String) -> String {
        var stringPos = position
        let inPos = (position as NSString).integerValue
        
        if case 0 ... 70 = inPos{
            stringPos = "070"
            return stringPos
        }
        else if case 110 ... 180 = inPos{
            stringPos = "110"
            return stringPos
        }
        else{
            return stringPos
        }
    }
    
    
    func thumbLimiter(_ position: String) -> String {
        var inPos = (position as NSString).integerValue
        
        switch inPos {
        case 0 ... 20:
            inPos = 70
            
        case 21 ... 40:
            inPos = 73
            
        case 41 ... 60:
            inPos = 78
        
        case 61 ... 80:
            inPos = 82
            
        case 81 ... 89:
            inPos = 87
        
        case 90:
            inPos = 90
            
        case 91 ... 100:
            inPos = 93
            
        case 101 ... 120:
            inPos = 98
            
        case 121 ... 140:
            inPos = 102
            
        case 141 ... 160:
            inPos = 107
            
        case 161 ... 180:
            inPos = 110
        
        default:
            inPos = 90
        }
        
        return String(inPos)
    }
}
