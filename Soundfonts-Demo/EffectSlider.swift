//
//  EffectSlider.swift
//  Soundfonts-Demo
//
//  Created by Chris Penny on 4/18/15.
//  Copyright (c) 2015 Intrinsic Audio. All rights reserved.
//

import Foundation
import UIKit

class EffectSlider : UIView {
    var fill = UIView()
    var currentWidth :CGFloat = 0.0
    var sendString: ((String, String) ->())!
    var effect = ""
    let height: CGFloat = 47
    let width: CGFloat = 305
    var label = UILabel()
    var receiver: String!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let fillFrame = CGRectMake(0, 0, 0, height)
        fill = UIView(frame: fillFrame)
        fill.backgroundColor = UIColor(hue: 0.47222, saturation: 0.6, brightness: 0.50, alpha: 0.7)
        
        self.addSubview(fill)
        
        let labelFrame = CGRectMake(0, 0, width, height)
        label = UILabel(frame: labelFrame)
        label.textAlignment = NSTextAlignment.Center
        label.text = "foo"
        
        self.addSubview(label)
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
    
    func updateFill(touchPoint: CGPoint){
        var newWidth = touchPoint.x
        
        if newWidth > self.frame.size.width {
            newWidth = self.frame.size.width
        } else if newWidth < 0 {
            newWidth = 0
        }
        
        self.fill.frame = CGRectMake(0, 0, newWidth, self.frame.size.height)
        currentWidth = newWidth
    }
    
    func updateValue(touchPoint: CGPoint) {
        var scaleFactor = currentWidth / width
        
        var value = Int(127 * scaleFactor)
        
        sendString("\(effect) \(value)", receiver)
        
    }
}