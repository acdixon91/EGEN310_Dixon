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
import GameController

class ViewController: NSViewController {
    
    @IBOutlet weak var transmit: NSButton!
    @IBOutlet weak var bluetoothSwitch: NSButton!
    @IBOutlet weak var controllerSwitch: NSButton!
    
    var buffer: [Data?] = []
    var inBuffer = false
    var btCom = BTCommunication()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        _ = GameController()
        // Watch Bluetooth connection
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
        
        // Start the Bluetooth discovery process
        _ = btDiscoverySharedInstance
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
    }
    
    @IBAction func send(_ sender: NSButton) {
        print("button pressed: \(sender.alternateTitle)")
        var message = ""
        
        //to prevent lag, the momment button is pushed it is transmitted
        print("initString sent - \"state on\"")
        let initString = ("!B\(sender.tag)\(true)\"$" as NSString).data(using: String.Encoding.utf8.rawValue)
        //changed to calling to btCommunication instead of function inside class
        btCom.sendPosition(initString!)
        
        if(sender.state == .on ){
            message = "!B\(sender.tag)\(true)\"$"
            print("state on")
        }
        else if(sender.state == .off){
            message = "!B\(sender.tag)\(false)\"$"
            //on quick clicks, it only sends the state value of off
            print("state on")
            let finalOnState = ("!B\(sender.tag)\(true)\"$" as NSString).data(using: String.Encoding.utf8.rawValue)
            btCom.sendPosition(finalOnState!)
            sender.state = .on  //needs to turn state back to on
            print("state off")
        }
        let valueString = (message as NSString).data(using: String.Encoding.utf8.rawValue)
        btCom.sendPosition(valueString!)
    }
    
    @objc func connectionChanged(_ notification: Notification) {
        // Connection status changed. Indicate on GUI.
        let userInfo = (notification as NSNotification).userInfo as! [String: Bool]
        
        DispatchQueue.main.async(execute: {
            // Set image based on connection status
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                    print("Connected to BT device")
                    self.bluetoothSwitch.setNextState()
                    
                } else {
                    print("Disconnected")
                }
            }
        });
    }
    
    
   

    
    
}






