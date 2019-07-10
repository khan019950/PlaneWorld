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

class ViewController: UIViewController {

    private var isAlertVisible: Bool = false
    private let planeVM = PlaneViewModel()
    private var isLoaded :Bool = false
    
    @IBOutlet weak var sceneLabel: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setLabel(withTxt: "Loading configuration, Please wait")
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        self.addGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.debugOptions = [ ARSCNDebugOptions.showFeaturePoints ]
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        
        if let worldMap = reloadWorld() {
            configuration.initialWorldMap = worldMap
            self.setLabel(withTxt: "Found saved world map.")
        } else {
            self.setLabel(withTxt: "Move camera around to map your surrounding space.")
        }
        
        sceneView.session.run(configuration, options: options)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.storePlane()
        sceneView.session.pause()
    }
    

    func addGestures() -> Void {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addPlaneToVMap(withGestureRecognizer:)))
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.removePlaneFromVMap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        sceneView.addGestureRecognizer(longTapGestureRecognizer)

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
    
    func setLabel(withTxt txt: String) -> Void {
        DispatchQueue.main.async {
            self.sceneLabel.text = txt
        }
        
    }
    
    func reloadWorld() -> ARWorldMap? {
        guard let worldMapData = self.planeVM.retrieveAllPlane(),
            let worldMap = self.planeVM.unarchiveMap(worldMapData: worldMapData) else { return nil }
        return worldMap
    }
    
    func storePlane() -> Void {
        sceneView.session.getCurrentWorldMap { (worldMap, error) in
            guard let worldMap = worldMap else {
                return self.setLabel(withTxt: "Error getting current world map.")
            }
            do {
                try self.planeVM.archieveMap(worldMap: worldMap)
                DispatchQueue.main.async {
                    self.setLabel(withTxt: "World map is saved.")
                }
            } catch {
                fatalError("Error saving world map: \(error.localizedDescription)")
            }
        }
    }
}


extension ViewController: ARSCNViewDelegate {
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        showAlert(withTitle: "Uable to start session!", withMsg: error.localizedDescription, isErr: true)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        setLabel(withTxt: "Session interrupted!")
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        setLabel(withTxt: "Session resumed")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    
        DispatchQueue.main.async {
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            self.addRectangle(node: node, anchor: planeAnchor)
        }
    
    }
    
    
    func addRectangle(node: SCNNode, anchor: ARPlaneAnchor) -> Void {
        let plane = PlaneObj(anchor)
        self.planeVM.datectedPlanes[anchor.identifier] = plane
        node.addChildNode(plane)
    }
    
    @objc func addPlaneToVMap(withGestureRecognizer recognizer: UIGestureRecognizer){

        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        guard let hitTestResult = hitTestResults.first else { return }
        if let identifier = hitTestResult.anchor?.identifier{
            if let plane =  self.planeVM.datectedPlanes[identifier] {
                self.setLabel(withTxt: "Area = \(plane.getArea()) m")
            }
        }

    }

    @objc func removePlaneFromVMap(withGestureRecognizer recognizer: UIGestureRecognizer){
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        guard let hitTestResult = hitTestResults.first else { return }
        
        if let identifier = hitTestResult.anchor?.identifier {
            let plane = self.planeVM.datectedPlanes[identifier]
            self.planeVM.datectedPlanes.removeValue(forKey: identifier)
            plane?.removeFromParentNode()
            self.setLabel(withTxt: "Plane removed")
        }
    }
    
    
}
