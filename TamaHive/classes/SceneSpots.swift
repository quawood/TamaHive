//
//  SceneSpots.swift
//  TamaHive
//
//  Created by Qualan Woodard on 6/16/17.
//  Copyright © 2017 Qualan Woodard. All rights reserved.
//

import UIKit
import CoreGraphics

class SceneSpot {
    var rect: CGRect!
    var isOccupied: Bool!
    var scene: Int!
    init(rect: CGRect) {
        self.rect = rect
        self.isOccupied = false
        self.scene = nil
    }
    

}

