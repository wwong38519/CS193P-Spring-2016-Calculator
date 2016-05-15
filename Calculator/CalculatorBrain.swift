//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Winnie on 16/5/2016.
//  Copyright © 2016 Winnie. All rights reserved.
//

import Foundation
// Model shoule never import UIKit because Model is UI independent

class CalculatorBrain {
    
    private var accumulator = 0.0
    
    func setOperand(operand: Double) {
        accumulator = operand
    }
    
    func performOperand(symbol: String) {
        switch symbol {
        case "π": accumulator = M_PI
        case "√": accumulator = sqrt(accumulator)
        default: break
            // switch: all case must be considered
        }
    }
    
    var result: Double {    //readonly
        get {
            return accumulator
        }
    }
}