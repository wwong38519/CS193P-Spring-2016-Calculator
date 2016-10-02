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
    private var internalProgram = [AnyObject]()
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "±": Operation.UnaryOperation({ -$0 }),
        "√": Operation.UnaryOperation(sqrt),
        "cos": Operation.UnaryOperation(cos),
//        "×": Operation.BinaryOperation({ (op1: Double, op2: Double) -> Double in
//            return op1 * op2;
//        }),
//        "×": Operation.BinaryOperation({ (op1, op2) in return op1 * op2 }),
//        "×": Operation.BinaryOperation({ ($0, $1) in return $0 * $1 }),
//        "×": Operation.BinaryOperation({ return $0 * $1 }),
        "×": Operation.BinaryOperation({ $0 * $1 }),
        "÷": Operation.BinaryOperation({ $0 / $1 }),
        "+": Operation.BinaryOperation({ $0 + $1 }),
        "−": Operation.BinaryOperation({ $0 - $1 }),
        "=": Operation.Equals
    ]
    
    /*
    enum Optional<T> {
        case None
        case Some(T)
    }
    */
    
    private enum Operation {
        // cannot have vars, no inheritance, pass by value (struct)
        case Constant(Double)
        case UnaryOperation((Double) -> (Double))
        case BinaryOperation((Double, Double) -> (Double))
        case Equals
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {   //return optional as key may not exist
            switch operation {  //dot: inferred type = Operation
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    // structs, enum - pass by value (stack)
    // copied unless mutaed
    // classes - pass by reference (heap)
    // free initializer of classes - none of the var
    // free initializer of structs - all of the var
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            // array is value type, hence it's a copy that returned
            return internalProgram
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    var result: Double {    //readonly
        get {
            return accumulator
        }
    }
}
