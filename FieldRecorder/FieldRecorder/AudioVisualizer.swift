//
//  AudioVisualizer.swift
//  FieldRecorder
//
//  Created by Amartya Banerjee on 2/22/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation
import UIKit

class AudioVisualizer: UIView {
    var rect = CGRect(x: 20, y: 20, width: 0, height: 0)
    var color = UIColor.init(red:0.5, green:0.5, blue: 0.5, alpha: 0.5)
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: self.rect)
        self.color.setFill()
        path.fill()
    }
    
    static func scale(_ valueIn: Double, baseMin: Double, baseMax: Double, limitMin: Double, limitMax: Double) -> Double {
        return ((limitMax - limitMin) * (valueIn - baseMin) / (baseMax - baseMin)) + limitMin;
    }
}
