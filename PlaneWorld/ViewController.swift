//
//  ViewController.swift
//  PlaneWorld
//
//  Created by abdul khan on 03/07/19.
//  Copyright © 2019 abdul khan. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    private var isAlertVisible: Bool = false
    
    
    @IBOutlet weak var sceneLabel: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneLabel.text = "Loading configuration, Please wait"
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.debugOptions = [ ARSCNDebugOptions.showFeaturePoints ]
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }


    
    func session(_ session: ARSession, didFailWithError error: Error) {
        showAlert(withTitle: "Uable to start session!", withMsg: error.localizedDescription, isErr: true)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        
    }
    
    func showAlert(withTitle title : String, withMsg msg: String, isErr: Bool) -> Void {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) -> Void in
            self.isAlertVisible = false
        })
        alert.addAction(alertAction)
        if isErr {
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (UIAlertAction) -> Void in
                self.isAlertVisible = false
                //TODO RETRY
            })
            alert.addAction(retryAction)
        }
        isAlertVisible = true
        present(alert, animated: true)
    }
}
