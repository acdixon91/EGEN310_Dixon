//
//  ExtendedGamepad.swift
//  ArduinoBluetooth
//
//  Created by Andrew Dixon on 3/8/19.
//  Copyright © 2019 Andrew Dixon. All rights reserved.
//

import Foundation
import GameController
import GameKit

public class ExtendedGamePad{
    
    var btCom = BTCommunication()
    private var timerTXDelay : Timer?
    private var allowTX = true
    public var gamepad : GCExtendedGamepad? {
        didSet {
            gamepadInputs()
        }
    }
    
    
    public init(gamepad: GCExtendedGamepad) {
        self.gamepad = gamepad
        gamepadInputs()
    }

    
    func gamepadInputs() {
        //dpad
        gamepad?.dpad.valueChangedHandler = { (dpad, xValue, yValue) in
            self.timerCheck()
        }
        
        //left thumbstick
        gamepad?.leftThumbstick.valueChangedHandler = { (leftThumbstick, xValue, yValue) in
            self.timerCheck()
        }
        
        //right thumbstick
        gamepad?.rightThumbstick.valueChangedHandler = { (rightThumbstick, xValue, yValue) in
            self.timerCheck()
        }
        
        //right trigger
        gamepad?.rightTrigger.valueChangedHandler = { (rightTrigger, value, pressed) in

            self.timerCheck()
        }
        
        //left trigger
        gamepad?.leftTrigger.valueChangedHandler = { (leftTrigger, value, pressed) in
            self.timerCheck()
        }
    }
    
    
    func timerCheck() {

        if self.allowTX == true {
            self.allowTX = false
            if timerTXDelay == nil {
                timerTXDelay = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(sendTimer), userInfo: nil, repeats: false)
            }
        }
    }
    

    @objc func sendTimer() {
        self.allowTX = true
        stopTimerTXDelay()
        let snapshot = gamepad?.saveSnapshot()
        btCom.sendRemoteData(snapshot!)
    }
    
    
    func stopTimerTXDelay(){
        if self.timerTXDelay == nil{
            return
        }
        timerTXDelay?.invalidate()
        self.timerTXDelay = nil
    }
}
