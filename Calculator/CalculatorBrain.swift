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
    var formatter: NSNumberFormatter?

    private var ops = [String]()
    
    var description: String {
        set {
//            print("set", ops.description, internalProgram.description, description, newValue)
            if newValue.isEmpty {
                ops.removeAll()
            } else {
                let symbol = newValue.stringByReplacingOccurrencesOfString(description, withString: "")
                ops.append(symbol)
            }
        }
        get {
            print("get", ops.description, internalProgram.description, isPartialResult)
            var output = ""
            var lastOpIndex = output.startIndex
            if !ops.isEmpty {
                var currentPartial = false
                for op in ops {
                    if let operation = operations[op] {
                        switch operation {
                        case .UnaryOperation:
                            if (!currentPartial) {
                                lastOpIndex = output.startIndex
                                if output.isEmpty {
                                    output = "0"
                                }
                                output.replaceRange(lastOpIndex..<output.endIndex, with: op+"("+output+")")
                            } else {
                                let lastOperand = output.substringFromIndex(lastOpIndex)
                                output.replaceRange(lastOpIndex..<output.endIndex, with: op+"("+lastOperand+")")
                            }
                        case .BinaryOperation:
                            if output.isEmpty {
                                output = "0"
                            }
                            output.appendContentsOf(op)
                            lastOpIndex = output.endIndex
                            currentPartial = true
                        case .Equals:
                            if currentPartial {
                                currentPartial = false
                            }
                        default:
                            output.appendContentsOf(op)
                        }
                    } else if variableValues[op] != nil {
                        output.appendContentsOf(op)
                    } else {
                        if !currentPartial {
                            lastOpIndex = output.startIndex
                            output = ""
                        }
                        output.appendContentsOf(op)
                    }
                }
            }
            return output
        }
    }

/*    private var lastOpIndex = "".startIndex

    var description: String = "" {
        didSet {
            let update = description
            var output = oldValue
            if update.isEmpty {
                lastOpIndex = output.startIndex
                output = " "
            } else {
                let symbol = update.stringByReplacingOccurrencesOfString(output, withString: "")
                if let operation = operations[symbol] {
                    switch operation {
                    case .UnaryOperation:
                        if (!isPartialResult) {
                            lastOpIndex = output.startIndex
                            output.replaceRange(lastOpIndex..<output.endIndex, with: symbol+"("+output+")")
                        } else {
                            let lastOperand = output.substringFromIndex(lastOpIndex)
                            output.replaceRange(lastOpIndex..<output.endIndex, with: symbol+"("+lastOperand+")")
                        }
                    case .BinaryOperation:
                        output.appendContentsOf(symbol)
                        lastOpIndex = output.endIndex
                    default:
                        output.appendContentsOf(symbol)
                    }
                } else if variableValues[symbol] != nil {
                    output.appendContentsOf(symbol)
                } else {
                    if !isPartialResult {
                        lastOpIndex = output.startIndex
                        output = " "
                    }
                    output.appendContentsOf(symbol)
                }
            }
            description = output
        }
    }
*/
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
        ops.append(formatter == nil ? operand.description : formatter!.stringFromNumber(operand)!)
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "±": Operation.UnaryOperation({ -$0 }),
        "√": Operation.UnaryOperation(sqrt),
        "cos": Operation.UnaryOperation(cos),
        "sin": Operation.UnaryOperation(sin),
        "tan": Operation.UnaryOperation(tan),
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
        "^": Operation.BinaryOperation({pow($0, $1)}),
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
        ops.append(symbol)
        if let operation = operations[symbol] {   //return optional as key may not exist
            switch operation {  //dot: inferred type = Operation
            case .Constant(let value):
                accumulator = value
            case .Nullary(let function):
                accumulator = function()
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
                        if operations[operation] != nil {
                            performOperation(operation)
                        } else {
                            setOperand(operation)
                        }
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
    var error: Bool {
        get {
            return accumulator.isNaN || accumulator.isInfinite
        }
    }

    func clear() {
        pending = nil
        accumulator = 0.0
        description = ""
        internalProgram.removeAll()
    }
    
    var variableValues = [String: Double]() {
        didSet {
            program = internalProgram
        }
    }
    
    func setOperand(variableName: String) {
        if let value = variableValues[variableName] {
            setOperand(value)
            ops.removeLast()
            ops.append(variableName)
            internalProgram.removeLast()
            internalProgram.append(variableName)
        } else {
            accumulator = 0.0
            internalProgram.append(variableName)
            ops.append(variableName)
        }
    }
    
    func undo() {
        if !internalProgram.isEmpty {
            internalProgram.removeLast()
            program = internalProgram
        }
    }
    
}
