//
//  ViewController.swift
//  Calculator
//
//  Created by Winnie on 14/5/2016.
//  Copyright © 2016 Winnie. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    private struct Storyboard {
        static let ShowGraphSegueIdentifier = "Show Graph"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        brain.formatter = formatter
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet private weak var display: UILabel!    // implicitly unwrapped optional

    @IBOutlet weak var history: UILabel!
    
    @IBOutlet weak var graphButton: UIButton!
    
    // all properties except optionals must be initialized
    // all optionals are initialized with 'not set'
    //var userIsInTheMiddleOfTyping: Bool = false
    private var userIsInTheMiddleOfTyping = false   // type inference
    
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        print("touch \(digit) digit")
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            //display.text = nil // unset optional
            //display.text = textCurrentlyInDisplay + digit  // set associate value for an optional
            display.text = (digit == "." && textCurrentlyInDisplay.containsString(digit) ? textCurrentlyInDisplay : textCurrentlyInDisplay + digit)  // set associate value for an optional
        } else {
            display.text = digit == "." ? "0." : digit
        }
        userIsInTheMiddleOfTyping = true
        updateHistoryLabel()
    }
    
    private var error: Bool?

    private var displayValue: Double? {  //computed property
        get {
            if let text = display.text, value = Double(text) {
                return value
            } else {
                return nil
            }
        }
        set {
            error = newValue == nil ? false : brain.error
            if let isError = error where isError {
                display.text = "ERROR"
            } else {
                if let value = newValue {
                    display.text = formatter.stringFromNumber(value) //special value (: Double)
                } else {
                    display.text = "0"
                }
            }
            updateHistoryLabel()
            graphButton?.enabled = !brain.isPartialResult
        }
    }

    private func updateHistoryLabel() {
        if !brain.description.isEmpty {
            history.text = brain.isPartialResult ? brain.description + "..." : brain.description
        } else {
            history.text = " "
        }
    }
    
    //private var brain: CalculatorBrain = CalculatorBrain()
    private var brain = CalculatorBrain()
    
    
    @IBAction private func performOperation(sender: UIButton) {
        if let operand = displayValue where userIsInTheMiddleOfTyping {
            brain.setOperand(operand)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {   //mathematicalSymbol is defined only in scope
            brain.performOperation(mathematicalSymbol)
            displayValue = brain.result
        }
        // else fatal error: unexpectedly found nil while unwrapping an Optional value
    }
    
    @IBAction private func clear() {
        brain.clear()
        brain.variableValues.removeAll()
        brain.description = ""
        displayValue = nil
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction private func backspace() {
        if display.text!.isEmpty {
            userIsInTheMiddleOfTyping = false
            displayValue = brain.result
        } else {
            if let isError = error where !isError && userIsInTheMiddleOfTyping {
                display.text!.removeAtIndex(display.text!.endIndex.predecessor())
                if display.text!.isEmpty {
                    display.text = " "
                }
                updateHistoryLabel()
            }
        }
    }
    
    @IBAction func undo(sender: UIButton) {
        if history.text!.isEmpty || userIsInTheMiddleOfTyping {
            backspace()
        } else {
            brain.undo()
            updateHistoryLabel()
        }
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction private func save() {
        savedProgram = brain.program
    }
    
    @IBAction private func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    @IBAction private func getVar(sender: UIButton) {
        if let variableName = sender.currentTitle {
            brain.setOperand(variableName)
            if let value = brain.variableValues[variableName] {
                displayValue = value
            } else {
                updateHistoryLabel()
            }
        }
    }
    
    @IBAction private func setVar(sender: UIButton) {
        if let variableName = sender.currentTitle?.substringFromIndex((sender.currentTitle?.startIndex.successor())!) {
            userIsInTheMiddleOfTyping = false
            brain.variableValues[variableName] = displayValue
            displayValue = brain.result
        }
    }
    
    let formatter: NSNumberFormatter = {
        var f = NSNumberFormatter()
        f.minimumIntegerDigits = 1
        f.maximumFractionDigits = 6
        f.minimumFractionDigits = 0
        return f
    }()
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationvc = segue.destinationViewController
        if let graphvc = destinationvc.contentViewController as? GraphViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case Storyboard.ShowGraphSegueIdentifier:
                    if !brain.isPartialResult {
                        graphvc.navigationItem.title = brain.description
                        /*
                        pass a function (takes a Double, returns a Double) as a closure to GraphViewController
                        type declaration (x: Double) -> Double? is inferred from graphvc.function if it is set in one line
                        */
//                        let function = { [weak weakSelf = self] (x: Double) -> Double? in
//                            weakSelf?.brain.variableValues["M"] = x
//                            return weakSelf?.brain.result
//                        }
//                        graphvc.function = function
                        graphvc.function = { [weak weakSelf = self] x in
                            weakSelf?.brain.variableValues["M"] = x
                            return weakSelf?.brain.result
                        }
                    }
                default:
                    break
                }
            }
        }
    }
}

extension UIViewController {
    var contentViewController: UIViewController? {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController
        } else {
            return self
        }
    }
}

