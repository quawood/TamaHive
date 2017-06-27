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
    
    var sceneRects: [[CGRect]]! {
        
        let imageWidth = Int((UIImage(named: "normaltamaHome.png")?.size.width)!) * viewScale
        let imageHeight = Int((UIImage(named: "normaltamaHome.png")?.size.height)!) * viewScale
        let length = Int(self.size.width/CGFloat(imageWidth))
        
        
        let widthSpacing = (Int(self.size.width) - (length * imageWidth))/(length + 1)
        let height = Int(self.size.height-50/(CGFloat(imageHeight) + CGFloat(widthSpacing)))
        let heightSpacing = widthSpacing-20
        let topLeft = CGPoint(x: Int(-(self.size.width/2)), y: Int(self.size.height/2))
        var sceneRs = [[CGRect]](repeating:[CGRect](repeating: CGRect.zero, count: length), count: height)
        for w in 0..<length {
            for l in 0..<height {
                let offsetX = (w+1)*widthSpacing + w*imageWidth
                let offsetY = (l+1)*heightSpacing + l*imageHeight
                let point = (Int(topLeft.x) + offsetX + (imageWidth/2), Int(topLeft.y) - offsetY - (imageHeight/2))
                let rect = CGRect(x: point.0, y: point.1, width: imageWidth, height: imageHeight)
                sceneRs[l][w] = rect
                
            }
        }
        return sceneRs
    }
    
    let context = CoreDataStack.sharedInstance.managedObjectContext
    let familyNames = ["mame","meme","kuchi","large","ninja","secret","small","space","violet"]
     var sceneEntites: [TamaSceneEntity]! = TAttributes.sceneEntites
    
    var tamaViewScenes: [TamaHouse]! = []
    let viewScale: Int! = 2
    var maxZposition = 0
    var zCounter = 0
    
    var isEditing: Bool! = false
    var touch = UITouch()
    var currentTama: TamaHouse!
    var touchdx: CGFloat!
    var touchdy: CGFloat!
    var beginPos: CGPoint!
    var isBeingDragged: Bool! = false
    
    let uncolorizeAction = SKAction.colorize(with: UIColor.clear, colorBlendFactor: 0, duration: 0)
    
    private var lastUpdateTime : TimeInterval = 0
    var timeSinceMove: Double! = 0
    var checkForEvol: Double! = 0
    var counting: Bool! = false
    var timeSincePress: Double! = 0
    
    var newTamaButton: FTButtonNode {
        let buttonTexture: SKTexture! = SKTexture(imageNamed: "button.png")
        let buttonTextureSelected: SKTexture! = SKTexture(imageNamed: "button.png")
        let button = FTButtonNode(normalTexture: buttonTexture, selectedTexture: buttonTextureSelected, disabledTexture: buttonTexture)
        button.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(TamasScene.createNewSceneEntity))
        button.position = CGPoint(x:155,y:-300)
        button.zPosition = 15
        button.name = "CreateB"
        button.scale(to: CGSize(width: 40 , height: 40))
        
        
        return button
    }
    
    var trashPlace: SKSpriteNode {
        let trashTexture: SKTexture! = SKTexture(imageNamed: "trash.png")
        let place = SKSpriteNode(texture: trashTexture)
        place.position = CGPoint(x: -155, y: -300)
        place.zPosition = 15
        place.scale(to: CGSize(width: 40 , height: 40))
        place.name = "trashB"
        return place
    }
    
    var spotlightPlace: SKSpriteNode {
        let sltexture: SKTexture! = SKTexture(imageNamed: "spotlight.png")
        let place = SKSpriteNode(texture: sltexture)
        place.position = CGPoint(x: 0, y: -300)
        place.zPosition = 15
        place.scale(to: CGSize(width: 40 , height: 40))
        place.name = "SpotlightB"
        return place
    }
    
    
    
    
    override func didMove(to view: SKView) {
        self.size = (self.view?.frame.size)!
        maxZposition = zCounter
        
        CreateScenesFromEntities()
        if tamaViewScenes.count == 0 {
            self.addChild(newTamaButton)
        }
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.appWillTerminate), name: Notification.Name.UIApplicationWillTerminate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.appWillEnterBackground), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.appWillEnterForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        
        
        
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
    
    
    
    
    
    @objc func appWillTerminate () {
        saveViewsToEntities()
        
    }
    
    @objc func appWillEnterBackground() {
        saveViewsToEntities()
        self.view?.isPaused = true
    }
    @objc func appWillEnterForeground() {
        updateTamas()
        self.view?.isPaused = false
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
        if counting {
            timeSincePress = timeSincePress + dt
            if timeSincePress >= 1 {
                isEditing = true
                let scaleAciton = SKAction.scale(by: 1.2, duration: 0)
                let colorizeAction = SKAction.colorize(with: UIColor.clear, colorBlendFactor: 0, duration: 0)
                currentTama.run(scaleAciton)
                currentTama.run(colorizeAction)
                
                self.addChild(newTamaButton)
                self.addChild(trashPlace)
                self.addChild(spotlightPlace)
                counting = false
                
            }
        }
        
        timeSinceMove = timeSinceMove + dt
        checkForEvol = checkForEvol + dt
        
    }
    
    
    
    
}

extension TamasScene {
    func generateRandomTama(_ n: Int, appendingPC: String) -> [String] {
        let appends:[String] = appendingPC.components(separatedBy: ",")
        var tamas: [String]! = []
        var resourcePath = NSURL(string: Bundle.main.resourcePath!)?.appendingPathComponent("tamahive.bundle")?.appendingPathComponent("tamas")
        appends.forEach({
            resourcePath?.appendPathComponent($0)
        })
        let resourcesContent = try! FileManager().contentsOfDirectory(at: resourcePath!, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
        
        for url in resourcesContent {
            tamas.append(url.lastPathComponent)
            
        }
        var returnArray: [String] = []
        for _ in 0..<n {
            let randInd = arc4random_uniform(UInt32(tamas.count))
            returnArray.append(tamas[Int(randInd)])
        }
        
        return returnArray
        
    }
    
    func generateRandomColor(previousColor: UIColor) -> UIColor {
        /* let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
         let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
         let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
         return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)*/
        
        return UIColor(red:   previousColor.components.red + (CGFloat.randomoz() * CGFloat.random()),
                       green: previousColor.components.green + (CGFloat.randomoz() * CGFloat.random()),
                       blue:  previousColor.components.blue + (CGFloat.randomoz() * CGFloat.random()),
                       alpha: 1.0)
    }
    
    
}













