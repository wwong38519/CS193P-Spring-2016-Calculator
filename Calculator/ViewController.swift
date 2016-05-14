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

    @IBOutlet weak var display: UILabel!    // implicitly unwrapped optional
    
    // all properties except optionals must be initialized
    // all optionals are initialized with 'not set'
    //var userIsInTheMiddleOfTyping: Bool = false
    var userIsInTheMiddleOfTyping = false   // type inference
    
    @IBAction func touchDigit(sender: UIButton) {
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

    @IBAction func performOperation(sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        if let mathematicalSymbol = sender.currentTitle {   //mathematicalSymbol is defined only in scope
            if (mathematicalSymbol == "π") {
                display.text = String(M_PI) //convert to string
            }
        }
        // else fatal error: unexpectedly found nil while unwrapping an Optional value
    }
}

