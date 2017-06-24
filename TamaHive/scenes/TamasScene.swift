//
//  TamasScene.swift
//  TamaHive
//
//  Created by Qualan Woodard on 6/8/17.
//  Copyright © 2017 Qualan Woodard. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreData

class TamasScene: SKScene {
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    var sceneRects: [[CGRect]]!
    
    
    let familyNames = ["mame","meme","kuchi","large","ninja","secret","small","space","violet"]
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var sceneEntites: [TamaSceneEntity]! = []
    var tamaViewScenes: [TamaHouse]! = []
    let viewScale: Int! = 2
    var maxZposition = 0
    var zCounter = 0
    
    var touch = UITouch()
    var currentTama: TamaHouse!
    var touchdx: CGFloat!
    var touchdy: CGFloat!
    var beginPos: CGPoint!
    var isBeingDragged: Bool! = false
    
    
    private var lastUpdateTime : TimeInterval = 0
    var timeSinceMove: Double! = 0
    var checkForEvol: Double! = 0
    
    var newTamaButton: FTButtonNode {
        let buttonTexture: SKTexture! = SKTexture(imageNamed: "button.png")
        let buttonTextureSelected: SKTexture! = SKTexture(imageNamed: "button.png")
        let button = FTButtonNode(normalTexture: buttonTexture, selectedTexture: buttonTextureSelected, disabledTexture: buttonTexture)
        button.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(TamasScene.createNewSceneEntity))
        button.position = CGPoint(x:155,y:-300)
        button.zPosition = 15
        button.name = "Button"
        button.scale(to: CGSize(width: 40 , height: 40))
        
        return button
    }
    
    var trashPlace: SKSpriteNode {
        let trashTexture: SKTexture! = SKTexture(imageNamed: "trash.png")
        let place = SKSpriteNode(texture: trashTexture)
        place.position = CGPoint(x: -155, y: -300)
        place.zPosition = 15
        place.scale(to: CGSize(width: 40 , height: 40))
        return place
    }
    
    
    
    func CreateScenesFromEntities() {
        sceneEntites = []
        sceneEntites = getScenes()
        
        for node in (self.scene?.children)! {
            if node is TamaHouse {
                node.removeFromParent()
            }
        }
        self.tamaViewScenes = []
        let sceneSorted = sceneEntites.sorted(by: { $0.id < $1.id })
        for scene in sceneSorted {
            setupScene(scene: scene)
        }
        maxZposition = zCounter
        updateTamas()
        
    }
    
    override func didMove(to view: SKView) {
        maxZposition = zCounter
        self.size = (self.view?.frame.size)!
        CreateScenesFromEntities()
        self.addChild(newTamaButton)
        self.addChild(trashPlace)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.appWillTerminate), name: Notification.Name.UIApplicationWillTerminate, object: nil)
        
        
    }
    
    
    
    
    func marryTamas(_ sender: Any) {
        if let button1 = sender as? FTButtonNode {
            button1.action()
        }
    }
    
    @objc func appWillTerminate () {
        saveViewsToEntities()
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if timeSinceMove >= 2 {
            tamaViewScenes.forEach( {
                $0.tamagotchis.forEach({
                    $0.move()
                })
            })
            timeSinceMove = 0
            
        }
        
        //check if tamas can evolve
        if checkForEvol >= 2 {
            updateTamas()
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
        checkForEvol = checkForEvol + dt
    }
    
    
    


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    

    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   
    
    
    
    
    
    
    
    
    
    
    
}





