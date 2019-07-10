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
    private var planeWorldFMUrl: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("worldMapURL")
        } catch {
            fatalError("Error getting world map URL from document directory.")
        }
    }()
    
    var datectedPlanes = [UUID:PlaneObj]()
    
    init() {
    }
    
    
    func archieveMap(worldMap : ARWorldMap) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
        try data.write(to: self.planeWorldFMUrl, options: [.atomic])
    }
    
    func unarchiveMap(worldMapData data: Data) -> ARWorldMap? {
        guard let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) else { return nil }
        return worldMap
    }
    
    
    func retrieveAllPlane() -> Data? {
        do {
            return try Data(contentsOf: self.planeWorldFMUrl)
        } catch {
            
            return nil
        }
    }
    
}
