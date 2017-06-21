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
    
    var touch = UITouch()
    var currentTama: TamaHouse!
    var touchdx: CGFloat!
    var touchdy: CGFloat!
    
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
    
    
    
    
    
    
    
    
    
    
    
    func deleteTask(atPos: Int) {
        let request = NSFetchRequest<TamaSceneEntity>(entityName: "TamaSceneEntity")
        var sceneIDs = [Int16]()
        do {
            let searchResults = try self.context.fetch(request)
            sceneIDs = searchResults.map( {$0.id})
            self.context.delete(searchResults[sceneIDs.index(where: {$0 == Int16(atPos)})!])
            
        } catch {
            print("Error with request: \(error)")
        }
        
        tamaViewScenes[atPos].removeFromParent()
        tamaViewScenes.remove(at: atPos)
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        sceneEntites = getScenes()
        sceneIDs = sceneEntites.map( {$0.id})
        for i in 0..<sceneIDs.count {
            if sceneIDs[i] > atPos {
                let sceneIndex = sceneEntites.index(where: {$0.id == Int16(sceneIDs[i])})
                sceneEntites[sceneIndex!].id = sceneEntites[sceneIndex!].id - 1
                
            }
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
    }
    
    func getScenes() -> [TamaSceneEntity] {
        var entities: [TamaSceneEntity]! = []
        do {
            entities = try context.fetch(TamaSceneEntity.fetchRequest())
        }catch {
            print("Error fetching data from CoreData")
        }
        return entities
    }
    
    @objc func createNewSceneEntity() {
        DispatchQueue.main.async {
            if self.sceneEntites.count < self.sceneRects.count() {
                
                let scene = TamaSceneEntity(context:self.self.context)
                scene.id = Int16(self.sceneEntites.count)
                scene.color1 = self.generateRandomColor()
                scene.color2 = self.generateRandomColor()
                var newSpot: Int!
                var count = 0
                let spotsArray = self.tamaViewScenes.map( {$0.spot})
                topLevel: for i in self.sceneRects {
                    for _ in i {
                        guard spotsArray.index(where: {$0 == count}) != nil else {
                            newSpot = count
                            break topLevel;
                        }
                        
                        count += 1
                    }
                }
                scene.spot = Int16(newSpot)
                let tama = TamagotchiEntity(context: self.context)
                let genders = ["m","f"]
                let date = Date()
                let randomFam = Int(arc4random_uniform(UInt32(self.familyNames.count)))
                
                tama.age = 0
                tama.generation = 1
                tama.happiness = 5
                tama.hunger = 5
                tama.tamaName = "egg"
                tama.id = scene.id
                tama.gender = genders[Int(arc4random_uniform(2))]
                tama.family = self.self.familyNames[randomFam]
                tama.dateCreated = date
                tama.tamascene = scene
                scene.tamagotchi = tama
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                self.sceneEntites = self.getScenes()
                self.setupScene(scale: CGFloat(self.viewScale), scene: scene)
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func didMove(to view: SKView) {
        self.size = (self.view?.frame.size)!
        setUpSceneRects()
        CreateScenesFromEntities()
        self.addChild(newTamaButton)
        self.addChild(trashPlace)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.appWillTerminate), name: Notification.Name.UIApplicationWillTerminate, object: nil)
        
        
    }
    
    
    func setupScene(scale: CGFloat, scene: TamaSceneEntity) {
        //setup individual tamagotchi
        
        let tamaScene = TamaHouse(textureNamed: "normaltamaHome.png", scale: Int(scale))
        
        tamaScene.tama = Tamagotchi(textureNamed: (scene.tamagotchi?.tamaName)!, scale: Int(scale))
        
        //create new tamascene
        let holderSpot = sceneRects.rowedIndex(Int(scene.spot)).0 as! CGRect
        tamaScene.color1 = scene.color1 as! UIColor
        tamaScene.color2 = scene.color2 as! UIColor
        tamaScene.spot = Int(scene.spot)
        tamaScene.position = CGPoint(x: holderSpot.origin.x , y: holderSpot.origin.y)
        
        tamaScene.tama.zPosition = 10
        tamaScene.tama.age = Int(scene.tamagotchi?.age)
        tamaScene.tama.gender = scene.tamagotchi?.gender
        //setup tamagotchi border
        let tile = SKShapeNode(rectOf: tamaScene.size, cornerRadius: 7)
        tile.strokeColor = tamaScene.color2
        tile.zPosition = 10
        tile.lineWidth = CGFloat(viewScale * 3)
        tile.position = CGPoint.zero
        
        addChild(tamaScene)
        tamaScene.displayTama()
        tamaScene.addChild(tile)
        tamaViewScenes.append(tamaScene)
        
        
        
        
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
        updateTamas(isUpdating: false)
        let sceneSorted = sceneEntites.sorted(by: { $0.id < $1.id })
        for scene in sceneSorted {
            setupScene(scale: CGFloat(viewScale), scene: scene)
        }
        
    }
    
    
    func setUpSceneRects() {
        
        let imageWidth = Int((UIImage(named: "normaltamaHome.png")?.size.width)!) * viewScale
        let imageHeight = Int((UIImage(named: "normaltamaHome.png")?.size.height)!) * viewScale
        let length = Int(self.size.width/CGFloat(imageWidth))
        
        
        let widthSpacing = (Int(self.size.width) - (length * imageWidth))/(length + 1)
        let height = Int(self.size.height/(CGFloat(imageHeight) + CGFloat(widthSpacing)))
        let heightSpacing = widthSpacing
        let topLeft = CGPoint(x: Int(-(self.size.width/2)), y: Int(self.size.height/2))
        sceneRects = [[CGRect]](repeating:[CGRect](repeating: CGRect.zero, count: length), count: height)
        for w in 0..<length {
            for l in 0..<height {
                let offsetX = (w+1)*widthSpacing + w*imageWidth
                let offsetY = (l+1)*heightSpacing + l*imageHeight
                let point = (Int(topLeft.x) + offsetX + (imageWidth/2), Int(topLeft.y) - offsetY - (imageHeight/2))
                let rect = CGRect(x: point.0, y: point.1, width: imageWidth, height: imageHeight)
                sceneRects[l][w] = rect
                
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    func updateTamas(isUpdating: Bool) {
        tamaViewScenes.forEach({
            let scene = $0
            let tama = scene.tama
            let index = tamaViewScenes!.index(of: scene)
            let correspondingEntity = sceneEntites.first(where: {x in
                x.id == Int16()
            })
            
            if (tama?.age)! < 4 {
                let date = Date()
                
                let newAge = date.interval(ofComponent: .second, fromDate: (correspondingEntity?.tamagotchi?.dateCreated!)!)/2
                if Int16(newAge) != tama?.age {
                    var randomTama = String()
                    switch newAge {
                    case 1:
                        randomTama = "baby"
                    case 2 :
                        randomTama = "toddler,\(tama!.gender!)"
                        
                    case 3:
                        randomTama = "teen,\(tama!.gender!)"
                        
                    default:
                        randomTama = "adult,\(tama!.gender!)"
                        
                    }
                    changeTextureOfTama(fromTama: tama!, toTama: randomTama, isUpdating: isUpdating)
                    tama?.age = Int16(newAge)
                    
                        
                    }
                
                }
            
        })
    
    }
    
    func changeTextureOfTama(fromTama: Tamagotchi, toTama: String, isUpdating: Bool) {
        let randomTama = generateRandomTama(1, appendingPC: toTama)[0]
        let i = tamaViewScenes.first(where: {$0.tama == fromTama})
        let tama = tamaViewScenes![Int(i!)!].tama
        let image = UIImage(named: (randomTama))?.resizeImage(scale: CGFloat(viewScale))
        tama?.texture = SKTexture(cgImage: (image?.cgImage)!)
        tama?.size = (tamaViewScenes![Int(i!)].tama.texture?.size())!
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touch = touches.first!
        
        
        for i in 0..<tamaViewScenes.count {
            if tamaViewScenes[i].frame.contains((touch.location(in: self.scene!))) {
                let scene = tamaViewScenes[i]
                currentTama = scene
                scene.isBeingDragged = true
                touchdx = touch.location(in: self.scene!).x - (currentTama?.position.x)!
                touchdy = touch.location(in: self.scene!).y - (currentTama?.position.y)!
                currentTama.zPosition = 50
                let flip = SKAction.scale(to: 1.3, duration: 0)
                currentTama.run(flip)
                
                break;
                
            }
        }
        
        //self.view?.isPaused = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let newTouch = touches.first
        if newTouch == touch {
            if let tama = currentTama {
                
                let newLoc = (newTouch?.location(in: self.scene!))!
                
                tama.position = CGPoint(x: newLoc.x - touchdx, y: newLoc.y - touchdy)
                topLevel: for p1 in self.tamaViewScenes {
                    if p1 != currentTama {
                        let test = SKShapeNode(rectOf: (sceneRects.rowedIndex(p1.spot).0 as! CGRect).size)
                        test.position = (sceneRects.rowedIndex(p1.spot).0 as! CGRect).origin
                        if test.frame.contains(newLoc) {
                            let spotP = p1.spot
                            p1.spot = self.currentTama.spot
                            self.currentTama.spot = spotP
                            
                            let ph = (self.sceneRects.rowedIndex(p1.spot).0 as! CGRect).origin
                            if p1.position != ph {
                                let animatePosition = SKAction.move(to: ph, duration: 0.1)
                                p1.run(animatePosition)
                            }
                            break topLevel
                            
                        }
                    }
                    
                }
                
                
            }
        }
        
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let endPos = touches.first?.location(in: self.scene!)
        
        checkForContains: if currentTama != nil {
            //delete tama if in trash node
            if trashPlace.frame.contains(endPos!) {
                let indexed = tamaViewScenes.index(where: {$0.spot == currentTama.spot})
                deleteTask(atPos: indexed!)
                
                break checkForContains
            }
            
            
            //check if node is within another spot
            var count = 0
            topLevel: for place0 in sceneRects {
                for place in place0 {
                    let test = SKShapeNode(rectOf: place.size)
                    test.position = place.origin
                    if test.frame.contains(endPos!) {
                        currentTama.spot = count
                        currentTama.position = (sceneRects.rowedIndex(currentTama.spot).0 as! CGRect).origin
                        break topLevel;
                        
                        
                    }
                    //if no frame contains tama, set position equal to before
                    currentTama?.position = (sceneRects.rowedIndex((currentTama?.spot)!).0 as! CGRect).origin
                    count += 1
                }
            }
            
            
            
            currentTama.zPosition = 10
            let scaleaction = SKAction.scale(to: 1, duration: 0)
            currentTama.run(scaleaction)
        }
        
        currentTama = nil
    }
    
    
    
    
    
    
    
    @objc func appWillTerminate () {
        for i in 0..<sceneEntites.count {
            let index = sceneEntites.index(where: { $0.id == i})
            sceneEntites[index!].spot = Int16(tamaViewScenes[i].spot)
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
    }
    
    
    
    
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if timeSinceMove >= 2 {
            tamaViewScenes.forEach( {
                $0.tama.move()
            })
            timeSinceMove = 0
            
        }
        if checkForEvol >= 1 {
            updateTamas(isUpdating: true)
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




