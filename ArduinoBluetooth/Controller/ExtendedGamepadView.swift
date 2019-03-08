//
//  ExtendedGamepadView.swift
//  Controlla
//
//  Created by Steve Sparks on 12/28/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import GameKit

@IBDesignable
public class ExtendedGamepadView: UIStackView {
    public var gamepad : GCExtendedGamepad? {
        didSet {
            assignGamepad()
        }
    }    

    let identifierLabel = UILabel()
    let leftButtonView = ButtonIndicatorView.with("Left", color: UIColor.white)
    let rightButtonView = ButtonIndicatorView.with("Right", color: UIColor.white)
    let leftTriggerView = ButtonIndicatorView.with("Left", color: UIColor.yellow)
    let rightTriggerView = ButtonIndicatorView.with("Right", color: UIColor.yellow)
    
    let leftThumbstickView = DirectionPadView()
    let leftDpadView = DirectionPadView()
    let rightThumbstickView = DirectionPadView()
    let buttonPad = ButtonPadView()
    let motionView = MotionView()
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public convenience init(gamepad: GCExtendedGamepad) {
        self.init(frame: .zero)
        self.gamepad = gamepad
        setup()
        assignGamepad()
    }
    
   

    func assignGamepad() {
        if let gamepad = gamepad {
            leftThumbstickView.pad = gamepad.leftThumbstick
            rightThumbstickView.pad = gamepad.rightThumbstick
            leftButtonView.input = gamepad.leftShoulder
            leftTriggerView.input = gamepad.leftTrigger
            rightButtonView.input = gamepad.rightShoulder
            rightTriggerView.input = gamepad.rightTrigger
            leftDpadView.pad = gamepad.dpad
            if let motion = gamepad.controller?.motion {
                motionView.motion = motion
                motionView.alpha = 1
            } else {
                motionView.alpha = 0
            }
        } else {
            leftThumbstickView.pad = nil
            rightThumbstickView.pad = nil
            leftButtonView.input = nil
            leftTriggerView.input = nil
            rightButtonView.input = nil
            rightTriggerView.input = nil
            leftDpadView.pad = nil
            motionView.motion = nil
            motionView.alpha = 0
        }
        buttonPad.extendedGamepad = gamepad
    }
    
}
