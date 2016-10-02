//
//  ViewController.swift
//  Calculator
//
//  Created by Winnie on 14/5/2016.
//  Copyright © 2016 Winnie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet private weak var display: UILabel!    // implicitly unwrapped optional
    
    // all properties except optionals must be initialized
    // all optionals are initialized with 'not set'
    //var userIsInTheMiddleOfTyping: Bool = false
    private var userIsInTheMiddleOfTyping = false   // type inference
    
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        print("touch \(digit) digit")
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = nil // unset optional
            display.text = textCurrentlyInDisplay + digit  // set associate value for an optional
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    private var displayValue: Double {  //computed property
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue) //special value (: Double)
        }
    }
    
    var savedProgram: CalculatorBrain.PropertyList? // type, i.e. AnyObject
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    //private var brain: CalculatorBrain = CalculatorBrain()
    private var brain = CalculatorBrain()

    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {   //mathematicalSymbol is defined only in scope
            brain.performOperation(mathematicalSymbol)
            displayValue = brain.result
        }
        // else fatal error: unexpectedly found nil while unwrapping an Optional value
        
        
    }
}

