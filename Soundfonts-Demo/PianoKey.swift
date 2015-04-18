//
//  PianoKey.swift
//  Soundfonts-Demo
//
//  Created by Chris Penny on 4/17/15.
//  Copyright (c) 2015 Intrinsic Audio. All rights reserved.
//

import Foundation
import UIKit

class PianoKey: UIButton {
    
    var note: Int!
    var octave: Int!
    var soundfontsReceiver: String!
    var sendString: ((String, String) -> ())!
    var currentNote: Int? = nil
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch = touches.first as! UITouch
        
        // Not sure if this is needed since there's no multitouch yet - this should prevent stuck notes.
        if currentNote != nil {
            sendString("\(currentNote!) 0", soundfontsReceiver)
        }
        
        currentNote = note + (12 * octave)
        
        let velocity = Int(127 * (1 - (touch.locationInView(self).y / self.frame.height)))
        
        sendString("\(currentNote!) \(velocity)", soundfontsReceiver)
        
        
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        // Does nothing right now
        
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch = touches.first as! UITouch
        
        sendString("\(currentNote!) 0", soundfontsReceiver)
        currentNote = nil
        
    }
    
}