//
//  GraphViewController.swift
//  Calculator
//
//  Created by Winnie on 8/10/2016.
//  Copyright © 2016 Winnie. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    /*
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    */
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: #selector(GraphView.changePointsPerUnit(_:))))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: #selector(GraphView.moveGraph(_:))))
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: graphView, action: #selector(GraphView.moveOrigin(_:)))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTapGestureRecognizer)
            updateUI()
        }
    }
    
    var function: ((x: Double) -> Double?)? {
        didSet {
            updateUI()
        }
    }
    
//    called from didSet of View / Model such that the view will definitely be updated when either of them is set first
    private func updateUI() {
        graphView?.function = function
    }

}
