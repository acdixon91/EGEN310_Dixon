//
//  GameController.swift
//  ArduinoBluetooth
//
//  Created by Andrew Dixon on 3/4/19.
//  Copyright © 2019 Andrew Dixon. All rights reserved.
//

import Foundation
import GameController

class GameController : NSObject{
    
    override init() {
        super.init()
        startWatchingForControllers()
    }
    
    
    func startWatchingForControllers() {
        let ctr = NotificationCenter.default
        ctr.addObserver(forName: .GCControllerDidConnect, object: nil, queue: .main) { note in
            if let ctrl = note.object as? GCController {
                self.add(ctrl)
            }
        }
        ctr.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: .main) { note in
            if let ctrl = note.object as? GCController {
                self.remove(ctrl)
            }
        }
        GCController.startWirelessControllerDiscovery(completionHandler: {})
    }
    
    func stopWatchingForControllers() {
        let ctr = NotificationCenter.default
        ctr.removeObserver(self, name: .GCControllerDidConnect, object: nil)
        ctr.removeObserver(self, name: .GCControllerDidDisconnect, object: nil)
        GCController.stopWirelessControllerDiscovery()
    }
    
    func add(_ controller: GCController) {
        let name = String(describing:controller.vendorName)
        if let gamepad = controller.extendedGamepad {
            print("connect extended \(name)")
            ExtendedGamePad.init(gamepad: gamepad)
            
        } else if let gamepad = controller.gamepad {
            print("connected gamepad \(name)")
            GamePad.init(gamepad: gamepad)
        } else {
            print("Huh? \(name)")
        }
    }
    
    func remove(_ controller: GCController) {
        
    }
    
}
