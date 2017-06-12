//
//  GameScene.swift
//  TamaHive
//
//  Created by Qualan Woodard on 6/8/17.
//  Copyright © 2017 Qualan Woodard. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?

    
    func setupGrid() {
        let tamaImage = UIImage(named: "memetchi.png")?.cgImage
        let arrayColors = tamaImage?.colors
        let w = Int((tamaImage?.width)!)
        let h = Int((tamaImage?.height)!)
        var count = 0
        for i in 0...w-1 {
            for j in 0...h-1 {
                let pixel = SKSpriteNode(color: (arrayColors?[count])!, size: CGSize(width: 2, height: 2))
                pixel.position = CGPoint(x: 3*i, y:-3*j )
                //grid[i, j] = pixel
                self.scene?.addChild(pixel)
                count += 1
            }
        }
        
    }
    
    
    override func didMove(to view: SKView) {
        self.size = view.bounds.size
        setupGrid()
    }

    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}

