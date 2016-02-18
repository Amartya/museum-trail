//
//  ViewController.swift
//  FieldRecorder
//
//  Created by Amartya on 2/17/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var fieldAudio = FieldAudio()
    
    //use this outlet to get the volume from the slider
    @IBOutlet var sliderValue: UISlider!
    
    @IBAction func stopAudio(sender: UIButton) {
        fieldAudio.player.stop()
        fieldAudio.recorder.stop()
    }
    
    @IBAction func playAudio(sender: UIButton) {
        fieldAudio.player.volume = sliderValue.value
        fieldAudio.player.play()
    }
    
    @IBAction func pauseAudio(sender: UIButton) {
        fieldAudio.player.pause()
    }
    
    
    @IBAction func changeVolume(sender: UISlider) {
        fieldAudio.player.volume = sender.value
    }
    
    
    @IBAction func recordAudio(sender: AnyObject) {
        fieldAudio.setupRecorder()
        fieldAudio.recorder.record()
    }
    
    @IBAction func playRecordedAudio(sender: AnyObject) {
        fieldAudio.playRecord()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

