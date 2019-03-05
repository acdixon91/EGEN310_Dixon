//
//  ViewController.swift
//  ArduinoBluetooth
//
//  Created by Andrew Dixon on 3/3/19.
//  Copyright © 2019 Andrew Dixon. All rights reserved.
//

import Cocoa
import AppKit
import Foundation

class ViewController: NSViewController {
    
    @IBOutlet weak var transmit: NSButton!
    
    var timerTXDelay: Timer?
    var allowTX = true
    var lastPosition: UInt8 = 255
    var buffer: Data?
    var inBuffer = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Watch Bluetooth connection
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
        
        // Start the Bluetooth discovery process
        _ = btDiscoverySharedInstance
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
    }
    
    
    
    @IBAction func transmit(_ sender: NSButton) {
        print("button pressed: \(sender.alternateTitle)")
        var message = ""
        
        if(sender.state == .on ){
            message = "!B\(sender.tag)\(true)\"$"
            print("state on")
        }
        else if(sender.state == .off){
            message = "!B\(sender.tag)\(false)\"$"

            //on quick clicks, it only sends the state value of off
            print("state on")
            let finalOnState = ("!B\(sender.tag)\(true)\"$" as NSString).data(using: String.Encoding.utf8.rawValue)
            sendPosition(finalOnState!)
            
            print("state off")
            sender.state = .on  //needs to turn state back to on
        }
        let valueString = (message as NSString).data(using: String.Encoding.utf8.rawValue)
        sendPosition(valueString!)
        
        
//        if let data = UInt8(sender.tag){
//            print("made it into if let loop")
//            sendPosition(data)
//        }
    }
    
    @objc func connectionChanged(_ notification: Notification) {
        // Connection status changed. Indicate on GUI.
        let userInfo = (notification as NSNotification).userInfo as! [String: Bool]
        
        DispatchQueue.main.async(execute: {
            // Set image based on connection status
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                    print("connected")
                    
                    // Send current slider position
                    //self.sendPosition(UInt8( self.transmit.tag))
                } else {
                    print("disconnected")
                }
            }
        });
    }
    
    func sendPosition(_ position: Data) {
        // Valid position range: 0 to 180
        print("made it to sendPosition")
        print(allowTX)
        if !allowTX {
            buffer = position
            inBuffer = true
            return
        }
        
//        // Validate value
//        print(position)
//        print(lastPosition)
//        if position == lastPosition {
//            return
//        }
//        else if ((position < 0) || (position > 180)) {
//            return
//        }
        
        // Send position to BLE Shield (if service exists and is connected)
        if let bleService = btDiscoverySharedInstance.bleService {
            print("sending location")
            bleService.writePosition(position)
//            lastPosition = position;
            
            // Start delay timer
            allowTX = false
            if timerTXDelay == nil {
                timerTXDelay = Timer.scheduledTimer(timeInterval: 0.0000000001, target: self, selector: #selector(ViewController.timerTXDelayElapsed), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc func timerTXDelayElapsed() {
        self.allowTX = true
        self.stopTimerTXDelay()
        
        // Send buffer data
        if inBuffer == true {
            sendPosition(buffer!)
            inBuffer = false
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
        





