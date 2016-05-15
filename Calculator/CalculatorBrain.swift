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
    
    var operations: Dictionary<String,Double> = [
        "π": M_PI,
        "e": M_E
    ]
    
    func performOperand(symbol: String) {
        if let constant = operations[symbol] {   //return optional as key may not exist
            accumulator = constant
        }
    }
    
    var result: Double {    //readonly
        get {
            return accumulator
        }
    }
}