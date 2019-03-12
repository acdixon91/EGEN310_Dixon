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
            print("DPAD : \( dpad )")
        }
        
        //left thumbstick
        gamepad?.leftThumbstick.valueChangedHandler = { (leftThumbstick, xValue, yValue) in
            print("Left Thumbstick : \( leftThumbstick )")
        }
        
        //right thumbstick
        gamepad?.rightThumbstick.valueChangedHandler = { (rightThumbstick, xValue, yValue) in
            print("Right Thumbstick : \( rightThumbstick )")
        }
        
        //right trigger
        gamepad?.rightTrigger.valueChangedHandler = { (rightTrigger, value, pressed) in
            print("Right Trigger : \( rightTrigger )")
        }
        
        //left trigger
        gamepad?.leftTrigger.valueChangedHandler = { (leftTrigger, value, pressed) in
            print("Left Trigger : \( leftTrigger )")
        }
    }
    
}
