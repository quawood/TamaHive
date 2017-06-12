//
//  Tama.swift
//  TamaHive
//
//  Created by Qualan Woodard on 6/8/17.
//  Copyright © 2017 Qualan Woodard. All rights reserved.
//

import UIKit
import GameKit
import SpriteKit

struct Tama{
    var pixels: [[SKSpriteNode]]
    
    subscript(coordinate: CGPoint) -> SKSpriteNode {
        get {
            return pixels[Int(coordinate.x)][Int(coordinate.y)]
        }
        set {
            pixels[Int(coordinate.x)][Int(coordinate.y)] = newValue
        }
    }
    
    subscript(x: Int, y: Int) -> SKSpriteNode {
        get {
            return self[CGPoint(x: x, y: y)]
        }
        set {
            self[CGPoint(x: x, y: y)] = newValue
        }
    }
}
