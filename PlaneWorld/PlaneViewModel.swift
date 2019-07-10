//
//  PlaneViewModel.swift
//  PlaneWorld
//
//  Created by abdul khan on 03/07/19.
//  Copyright © 2019 abdul khan. All rights reserved.
//

import Foundation
import ARKit


class PlaneViewModel {
    
    var datectedPlanes = [UUID:PlaneObj]() //dictionary to save rectangles

    private var planeWorldFMUrl: URL = { // Url for storing worldmap data into local storage
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("worldMapURL")
        } catch {
            fatalError("Error getting world map URL from document directory.")
        }
    }()
    
    
    /// Function to transform / archieve ARWorldMap object to Data object to be save in storage
    ///
    /// - Parameter worldMap: ARWorldMap
    /// - Throws: may throw errs
    func archieveMap(worldMap : ARWorldMap) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
        try data.write(to: self.planeWorldFMUrl, options: [.atomic])
    }
    
    
    /// Fn to convert Data object to ARWorldMap object to be loaded in sceneView
    ///
    /// - Parameter data: Data object from local storage
    /// - Returns: ARWorldMap
    func unarchiveMap(worldMapData data: Data) -> ARWorldMap? {
        guard let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) else { return nil }
        return worldMap
    }
    
    
    /// Fn to get Data object stored in local storage
    ///
    /// - Returns: Data object
    func retrieveAllPlane() -> Data? {
        do {
            return try Data(contentsOf: self.planeWorldFMUrl)
        } catch {
            
            return nil
        }
    }
    
}
