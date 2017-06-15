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

    
    func setupScene() {
        let tamaScene = TamaScene(texture: nil, color: UIColor.white, size: CGSize(width: 170, height: 120))
        tamaScene.tama = Tamagotchi(imageNamed: "mametchi.png")
        self.addChild(tamaScene)
        tamaScene.displayTama()
    }
    
    override func didMove(to view: SKView) {
        self.size = view.bounds.size
        setupScene() 
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

