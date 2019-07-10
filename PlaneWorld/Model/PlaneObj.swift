//
//  Plane.swift
//  PlaneWorld
//
//  Created by abdul khan on 10/07/19.
//  Copyright © 2019 abdul khan. All rights reserved.
//

import Foundation
import ARKit


class PlaneObj : SCNNode {
    var planeAnchor: ARPlaneAnchor
    var planeGeometry: SCNPlane
    var planeNode: SCNNode
    
    var width : CGFloat
    var height: CGFloat
    
   
    
    init(_ anchor: ARPlaneAnchor) {
        
        self.planeAnchor = anchor
        
       
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let material = SCNMaterial()
        material.diffuse.contents =  UIColor.blue.withAlphaComponent(0.5)
        self.planeGeometry.materials = [material]
        
        self.planeGeometry.firstMaterial?.transparency = 0.5
        self.planeNode = SCNNode(geometry: planeGeometry)
        self.planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        self.width = CGFloat(planeAnchor.extent.x)
        self.height = CGFloat(planeAnchor.extent.z)
        
        super.init()
        
        self.addChildNode(planeNode)
        
        self.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func getArea() -> CGFloat {
        return round((self.width * self.height) * 100.0 ) / 100.0
    }
}
