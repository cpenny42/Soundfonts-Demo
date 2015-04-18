//
//  soundfontsViewController.swift
//  Soundfonts-Demo
//
//  Created by Chris Penny on 4/15/15.
//  Copyright (c) 2015 Intrinsic Audio. All rights reserved.
//

import Foundation
import UIKit

// Data stored for each soundfont
struct SfData {
    var name: String
    var color: UIColor
    
    // ... other parameters go here ...
}

class SoundfontsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var patch: UnsafeMutablePointer<Void>
    var soundfontsReceiver: String
    var reverbLevelReceiver: String
    var _$0: Int32
    
    // Path where the soundfonts live
    var path = NSBundle.mainBundle().resourcePath! + "/"
    
    var currentSoundfont = 4
    var currentOctave = 5
    
    let soundfonts = ["analog_age", "banjo_1", "beautiful_pad", "bolivianflute", "Campbells_strings", "Campbells_Verby_Vocal", "church_organ", "das_moog", "DCs_Mellotron_Flute", "ElPiano1", "enigma_flute", "flugelhorn", "janos_lead", "jonnypad1", "jonnypad3", "jonnypad4", "jonnypad5", "jonnypad6", "jonnypad7", "jonnypad8", "LesPaul", "piano_1", "muted_trombone", "saz", "SC88Drumset", "StomperSet"]
    
    var soundfontsData: [String: SfData]
    
    required init(coder aDecoder: NSCoder) {
        
        // Add all patches in the main bundle to Pd's search path, set up externals (needed for [soundfonts])
        PdBase.addToSearchPath(NSBundle.mainBundle().resourcePath)
        PdExternals.setup()
        
        // Open file, get $0 number & use it to set the receiver
        patch = PdBase.openFile("Soundfonts-Demo.pd", path: NSBundle.mainBundle().resourcePath)
        _$0 = PdBase.dollarZeroForFile(patch)
        soundfontsReceiver = "\(_$0)-input"
        reverbLevelReceiver = "\(_$0)-reverb.level"
        
        // Store extra data for each soundfont - not really necessary but useful
        soundfontsData = [String: SfData]()
        
        super.init(coder: aDecoder)
        
        // Initialize data for each soundfont - just name & background color for now
        for soundfont in soundfonts {
            soundfontsData[soundfont] = SfData(name: soundfont, color: getColor())
        }

        sendString("pitchbend_range 12", toReceiver: soundfontsReceiver)
        
        // Chorus can be weird but it does work - the units seem to be pretty arbitrary though. You're probably better off using a chorus patch.
        // Reverb only works with the default settings - try to change any of it and it breaks.  I used a reverb patch instead.
        // This will print an error message saying "speed is too low". Don't worry about it - the error message is wrong. Gotta love working with 15 year-old libraries.
        sendString("chorus_speed 1", toReceiver: soundfontsReceiver)
        sendString("chorus_depth 8", toReceiver: soundfontsReceiver)
        sendString("chorus_level 9", toReceiver: soundfontsReceiver)
        sendString("chorus_n 3", toReceiver: soundfontsReceiver)

    }
    
    // Gets a random color for each soundfont to use as the background color because why not
    func getColor() -> UIColor {
        return UIColor(hue: CGFloat(Float(arc4random()) / Float(UINT32_MAX)), saturation: 0.16, brightness: 0.96, alpha: 1)
    }
    
    // PdBase.sendMessage has some weird functionality that can be pretty tricky to figure out.  Instead I use PdBase.sendList, which takes each word or symbol in the message as elements in an array (aka ["init", 0, "stereo", "channels~"]).
    // I like sending the message as a string more (aka "init 0 stereo channels~", so I wrote this method to convert a String into an array of Floats or Strings. Using this for sending messages to Pd will prevent a lot of headaches.
    // In Pd the message is received as a list, so you'll probably need a [list trim] after the receiver in your patch to convert the list to a regular message.
    // You can definitely use PdBase.sendMessage instead if you want
    func sendString(message: String, toReceiver: String) {
        
        var finalMessage = [AnyObject]()
        for item in message.componentsSeparatedByString(" ") {
            
            // If the element is a number append it as a Float, otherwise as a String
            var number = (item as NSString).floatValue
            if item.toInt() == nil {
                finalMessage.append(item)
            } else {
                finalMessage.append(number)
            }
        }
        
        PdBase.sendList(finalMessage, toReceiver: soundfontsReceiver)
    }
    
    func setSoundfont(soundfont: String) {

        sendString("set \(path + soundfont).sf2", toReceiver: soundfontsReceiver)
        
//        With PdBase.sendMessage it would be:
//        PdBase.sendMessage("set", withArguments: [path + soundfont + ".sf2"], toReceiver: soundfontsReceiver)
        
    }
    
    ///////////////////////////// UI STUFF /////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inputMethod.delegate = self
        self.soundfontSelector.delegate = self
        self.soundfontSelector.dataSource = self
        
        self.soundfontSelector.selectRow(currentSoundfont, inComponent: 0, animated: true)
        setSoundfont(soundfonts[currentSoundfont])
        soundfontTitle.text = soundfonts[currentSoundfont]
        
        pianoKeys = [noteC, noteCsharp, noteD, noteDsharp, noteE, noteF, noteFsharp, noteG, noteGsharp, noteA, noteAsharp, noteB, noteCplus]
        
        for (rootNote, pianoKey) in enumerate(pianoKeys) {
            pianoKey.note = rootNote
            pianoKey.octave = currentOctave
            pianoKey.soundfontsReceiver = soundfontsReceiver
            pianoKey.sendString = sendString
        }
        
        octaveIndicator.text = String(currentOctave)
        
        pitchbendSlider.soundfontsReceiver = soundfontsReceiver
        pitchbendSlider.sendString = sendString
        
        modSlider.soundfontsReceiver = soundfontsReceiver
        modSlider.sendString = sendString
        
        reverbSlider.sendString = sendString
        reverbSlider.effect = "reverb_level"
        reverbSlider.label.text = "reverb"
        reverbSlider.receiver = "\(_$0)-reverb.level"
        
        chorusSlider.sendString = sendString
        chorusSlider.effect = "chorus_amount"
        chorusSlider.label.text = "chorus"
        chorusSlider.receiver = soundfontsReceiver
    }
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var soundfontTitle: UILabel!
    @IBOutlet weak var inputMethod: UITextField!
    
    // Change the color stored with the current soundfont
    @IBAction func newColor() {
        let newColor = getColor()
        self.soundfontsData[soundfonts[currentSoundfont]]?.color = newColor
        self.backgroundView.backgroundColor = newColor
    }
    
    // Enter button
    @IBAction func enter() {
        
        var method = self.inputMethod.text!
        
        sendString(method,toReceiver: soundfontsReceiver)
        println(method)
        
        self.inputMethod.text! = ""
    }
    
    // Make keyboard enter submit the text box
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        enter()
        return true
    }
    
    // Picker view stuff
    
    @IBOutlet weak var soundfontSelector: UIPickerView!
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return soundfonts.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return soundfonts[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentSoundfont = row
        let soundfont = soundfonts[row]
        soundfontTitle.text = soundfont
        setSoundfont(soundfont)
        self.backgroundView.backgroundColor = self.soundfontsData[soundfont]?.color
    }
    
    // Piano Keys:
    
    @IBOutlet weak var noteC: PianoKey!
    @IBOutlet weak var noteCsharp: PianoKey!
    @IBOutlet weak var noteD: PianoKey!
    @IBOutlet weak var noteDsharp: PianoKey!
    @IBOutlet weak var noteE: PianoKey!
    @IBOutlet weak var noteF: PianoKey!
    @IBOutlet weak var noteFsharp: PianoKey!
    @IBOutlet weak var noteG: PianoKey!
    @IBOutlet weak var noteGsharp: PianoKey!
    @IBOutlet weak var noteA: PianoKey!
    @IBOutlet weak var noteAsharp: PianoKey!
    @IBOutlet weak var noteB: PianoKey!
    @IBOutlet weak var noteCplus: PianoKey!
    
    var pianoKeys = [PianoKey]()
    
    func setOctave(octave: Int) {
        if (octave <= 9) && (octave >= 0) {
            currentOctave = octave
            octaveIndicator.text = String(octave)
            
            for key in pianoKeys {
                key.octave = octave
            }
        } else {
            println("WARNING - Octave must be from 0 to 9")
        }
    }
    
    @IBAction func octaveUp() {
        setOctave(currentOctave + 1)
    }
    
    @IBAction func octaveDown() {
        setOctave(currentOctave - 1)
    }
    
    @IBOutlet weak var octaveIndicator: UILabel!
    
    // Sliders
    // The Fluidsynth Reverb is shitty and mostly broken, so I used a reverb patch that comes with Pd-Vanilla instead
    
    // The chorus effect works but can also be weird - also the range is unpredictable, though you can get a feel for it by playing with it in the Pd patch
    
    @IBOutlet weak var pitchbendSlider: PitchbendSlider!
    @IBOutlet weak var modSlider: ModSlider!
    @IBOutlet weak var reverbSlider: EffectSlider!
    @IBOutlet weak var chorusSlider: EffectSlider!
    
}