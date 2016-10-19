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
    
    private var origin: CGPoint?

    private let defaults = NSUserDefaults.standardUserDefaults()
    private struct Keys {
        static let Origin = "GraphViewController.Origin"
        static let Scale = "GraphViewController.Scale"
    }
    
//    called from didSet of View / Model such that the view will definitely be updated when either of them is set first
    private func updateUI() {
        graphView?.function = function
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let storedOrigin = defaults.arrayForKey(Keys.Origin), x = storedOrigin[0] as? Double, y = storedOrigin[1] as? Double {
            graphView?.originWrtCenter = CGPoint(x: x, y: y)
        }
        if let storedScale = defaults.objectForKey(Keys.Scale) as? CGFloat {
            graphView?.scale = storedScale
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        origin = graphView?.originWrtCenter
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if origin != nil {
            graphView?.originWrtCenter = origin!
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        defaults.setObject([graphView.originWrtCenter.x, graphView.originWrtCenter.y], forKey: Keys.Origin)
        defaults.setObject(graphView.scale, forKey: Keys.Scale)
    }
    
}
