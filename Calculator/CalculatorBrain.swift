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
    
    private var ops = [String]()
    private var lastOpIndex = 0
    
    var description: String {
        get {
            return ops.joinWithSeparator("")
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    func setOperand(operand: Double) {
        if (!isPartialResult) {
            ops.removeAll()
        }
        ops.append(formatter.stringFromNumber(operand)!)
        accumulator = operand
        internalProgram.append(operand)
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "±": Operation.UnaryOperation({ -$0 }),
        "√": Operation.UnaryOperation(sqrt),
        "x2": Operation.UnaryOperation({pow($0, 2)}),
        "cos": Operation.UnaryOperation(cos),
        "sin": Operation.UnaryOperation(cos),
        "tan": Operation.UnaryOperation(cos),
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
        "=": Operation.Equals,
        "R": Operation.Nullary(drand48)
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
        case Nullary(() -> (Double))
        case UnaryOperation((Double) -> (Double))
        case BinaryOperation((Double, Double) -> (Double))
        case Equals
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {   //return optional as key may not exist
            switch operation {  //dot: inferred type = Operation
            case .Constant(let value):
                ops.append(symbol)
                accumulator = value
            case .Nullary(let function):
                ops.append(symbol)
                accumulator = function()
            case .UnaryOperation(let function):
                if (!isPartialResult) {
                    lastOpIndex = 0
                    ops.insert(symbol+"(", atIndex: 0)
                    ops.append(")")
                } else {
                    ops.insert(symbol+"(", atIndex: lastOpIndex+1)
                    ops.append(")")
                }
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                ops.append(symbol)
                lastOpIndex = ops.count-1
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
    
    var result: Double {    //readonly
        get {
            return accumulator
        }
    }
    
    func clear() {
        pending = nil
        accumulator = 0.0
        ops.removeAll()
        lastOpIndex = 0
        internalProgram.removeAll()
    }
    
    let formatter: NSNumberFormatter = {
        var f = NSNumberFormatter()
        f.minimumIntegerDigits = 1
        f.maximumFractionDigits = 6
        f.minimumFractionDigits = 0
        return f
    }()
}
