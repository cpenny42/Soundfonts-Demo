//
//  PitchbendSlider.swift
//  Soundfonts-Demo
//
//  Created by Chris Penny on 4/17/15.
//  Copyright (c) 2015 Intrinsic Audio. All rights reserved.
//

import Foundation
import UIKit

class PitchbendSlider : UIView {
    var fill = UIView()
    var currentPosition:CGFloat = 0.0
    let width: CGFloat = 64
    let height: CGFloat = 330
    let barHeight: CGFloat = 5
    var soundfontsReceiver: String!
    var sendString: ((String, String) -> ())!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        var fillFrame = CGRectMake(0, height/2, width, barHeight)
        fill = UIView(frame: fillFrame)
        fill.backgroundColor = UIColor(hue: 0.5388, saturation: 1, brightness: 0.51, alpha: 1)
        
        self.addSubview(fill)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches.first as! UITouch
        var touchPoint = touch.locationInView(self)
        
        self.updateFill(touchPoint)
        self.updateValue(touchPoint)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches.first as! UITouch
        var touchPoint = touch.locationInView(self)
        
        self.updateFill(touchPoint)
        self.updateValue(touchPoint)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        updateFill(CGPoint(x: width/2, y: height/2))
        updateValue(CGPoint(x: width/2, y: height/2))
    }
    
    func updateFill(touchPoint: CGPoint){
        var newPosition = touchPoint.y
        
        if newPosition > height {
            newPosition = height
        } else if newPosition < 0 {
            newPosition = 0
        }
        
        self.fill.frame = CGRectMake(0, newPosition, width, barHeight)
        currentPosition = newPosition

    }
    
    func updateValue(touchPoint: CGPoint) {
        var scaleFactor = currentPosition / height
        
        var value = Int(127 - (127 * scaleFactor))
        
        sendString("pitchbend \(value)", soundfontsReceiver)
        
    }
    
    
}










