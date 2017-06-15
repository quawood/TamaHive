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
    var tamaScene: TamaScene!
    var timeSinceMove: Double! = 0
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?

    
    func setupScene(scale: CGFloat) {
        //background color for parent scene
        
        
        //setup individual tamagotchi
        
        tamaScene = TamaScene(textureNamed: "tamaHome.png", scale: Int(scale))
        DispatchQueue.main.async {
            self.tamaScene.tama = Tamagotchi(textureNamed: "mametchi.png", scale: Int(scale))
            self.tamaScene.displayTama()
            self.tamaScene.tama.zPosition = 11
        }
        
        //setup tamagotchi border
        let tile = SKShapeNode(rectOf: tamaScene.size, cornerRadius: 12)
        tile.strokeColor = UIColor.black
        tile.zPosition = 10
        tile.lineWidth = 7
        
        
        addChild(tile)
        addChild(tamaScene)
        
        
    }
    
    override func didMove(to view: SKView) {
        //self.size = view.bounds.size
        setupScene(scale: 4)
        self.backgroundColor = UIColor(red: 106/255, green: 107/255, blue: 91/255, alpha: 1.0)
        tamaScene.color1 = UIColor.green
        
    }

    
    override func update(_ currentTime: TimeInterval) {
        
        // Called before each frame is rendered
        if timeSinceMove >= 2 {
            tamaScene.tama.move()
            timeSinceMove = 0
        }
        
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
        timeSinceMove = timeSinceMove + dt
    }
}

