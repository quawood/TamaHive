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
    
    var sceneRects: [[SceneSpot]]!
    private var lastUpdateTime : TimeInterval = 0
    
    let familyNames = ["mame","meme","kuchi","large","ninja","secret","small","space","violet"]
    //core data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var sceneEntites: [TamaSceneEntity]! = []
    var tamaViewScenes: [TamaScene]! = []
    let viewScale: Int! = 2
    
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
    
    
    
    func setupScene(scale: CGFloat, scene: TamaSceneEntity) {
        //setup individual tamagotchi
        let tamaScene = TamaScene(textureNamed: "tamaHome.png", scale: Int(scale))
        
        tamaScene.tama = Tamagotchi(textureNamed: scene.tamagotchi?.tamaName as! String, scale: Int(scale))
        
        //create new tamascene
        tamaScene.color1 = scene.color1 as! UIColor
        tamaScene.color2 = scene.color2 as! UIColor
        let holderSpot = sceneRects.rowedIndex(Int(scene.spot)) as! SceneSpot
        tamaScene.spot = Int(scene.spot)
        holderSpot.scene = tamaViewScenes.count
        holderSpot.isOccupied = true
        tamaScene.position = CGPoint(x: holderSpot.rect.origin.x , y: holderSpot.rect.origin.y)
        
        
        tamaScene.tama.zPosition = 10
        //setup tamagotchi border
        let tile = SKShapeNode(rectOf: tamaScene.size, cornerRadius: 9)
        tile.strokeColor = tamaScene.color2
        tile.zPosition = 10
        tile.lineWidth = CGFloat(viewScale * 3)
        tile.position = CGPoint.zero
        
        addChild(tamaScene)
        tamaScene.displayTama()
        tamaScene.addChild(tile)
        tamaViewScenes.append(tamaScene)
        
        
        
        
        
        
        
    }
    
    func deleteTask(atPos: Int) {
        let request = NSFetchRequest<TamaSceneEntity>(entityName: "TamaSceneEntity")
        do {
            let searchResults = try self.context.fetch(request)
            self.context.delete(searchResults[atPos])
        } catch {
            print("Error with request: \(error)")
        }
        
        tamaViewScenes[atPos].removeFromParent()
        let holderSpot = sceneRects.rowedIndex((tamaViewScenes[atPos].spot)!) as! SceneSpot
        holderSpot.isOccupied = false
        holderSpot.scene = nil
        tamaViewScenes.remove(at: atPos)
        
        
        sceneEntites = getScenes()
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
    
    func createNewSceneEntity() {
        DispatchQueue.main.async {
            if self.sceneEntites.count < self.sceneRects.count() {
                
                let scene = TamaSceneEntity(context:self.self.context)
                scene.id = Int16(self.sceneEntites.count)
                scene.color1 = self.generateRandomColor()
                scene.color2 = self.generateRandomColor()
                
                var rectS: Int!
                var count = 0
                topLevel: for i in self.sceneRects {
                    for scenerect in i {
                        if scenerect.isOccupied == false {
                            rectS = count
                            break topLevel;
                        }
                        count += 1
                    }
                }
                scene.spot = Int16(rectS)
                let tama = TamagotchiEntity(context: self.context)
                tama.age = 0
                tama.generation = 1
                tama.happiness = 5
                tama.hunger = 5
                tama.tamaName = "egg"
                tama.id = scene.id
                let randomFam = Int(arc4random_uniform(UInt32(self.familyNames.count)))
                tama.family = self.self.familyNames[randomFam]
                //set date
                let date = Date()
                tama.lastOpenDate = date
                tama.dateCreated = date
                
                tama.tamascene = scene
                scene.tamagotchi = tama
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                self.sceneEntites = self.getScenes()
                self.setupScene(scale: CGFloat(self.viewScale), scene: scene)
            }
        }
        
        
        
    }
    
    
    
    
    
    func CreateScenesFromEntities() {
        sceneEntites = []
        sceneEntites = getScenes()
        for node in (self.scene?.children)! {
            if node is TamaScene {
                node.removeFromParent()
            }
        }
        self.tamaViewScenes = []
        updateTamas(isUpdating: false)
        for scene in sceneEntites {
            setupScene(scale: CGFloat(viewScale), scene: scene)
        }
        
    }
    func updateTamas(isUpdating: Bool) {
        for i in 0..<sceneEntites.count {
            let tama = sceneEntites[i].tamagotchi
            if (tama?.age)! < 4 {
                let date = Date()
                
                let newAge = date.interval(ofComponent: .minute, fromDate: (tama?.dateCreated)!)/2
                if Int16(newAge) != tama?.age {
                    switch newAge {
                    case 1:
                        let randomTama = "baby"
                        changeTextureOfTama(i: i, toD: randomTama, isUpdating: isUpdating)
                    case 2 :
                        let randomTama = "toddler"
                        changeTextureOfTama(i: i, toD: randomTama, isUpdating: isUpdating)
                    case 3:
                        let randomTama = "teen"
                        changeTextureOfTama(i: i, toD: randomTama, isUpdating: isUpdating)
                    default:
                        let randomTama = tama?.family as! String
                        changeTextureOfTama(i: i, toD: randomTama, isUpdating: isUpdating)
                        
                        
                    }
                    tama?.age = Int16(newAge)
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                }
                
                
            }
            
        }
        
    }
    
    var touch = UITouch()
    var currentTama: TamaScene!
    var touchdx: CGFloat!
    var touchdy: CGFloat!
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
                
                
                
                
                /*
                 self.view?.isPaused = true
                 tamaViewScenes[i].removeFromParent()
                 deleteTask(atPos: i)
                 tamaViewScenes.remove(at: i)
                 for i in 0..<tamaViewScenes.count {
                 let scene = tamaViewScenes[i]
                 let oneLessRect = sceneRects.countFromLeft(i).0 as! CGRect
                 scene.position = CGPoint(x: oneLessRect.origin.x + (oneLessRect.size.width/2), y: oneLessRect.origin.y - (oneLessRect.size.height/2))
                 
                 }
                 break;*/
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
                
                
            }
        }
        
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let endPos = touches.first?.location(in: self.scene!)
        var count = 0
        checkForContains: if currentTama != nil {
            if trashPlace.frame.contains(endPos!) {
                let indexed = Int(tamaViewScenes.index(of: currentTama!)!)
                deleteTask(atPos: indexed)
                
                break checkForContains
            }
            topLevel: for place0 in sceneRects {
                for place in place0 {
                    let test = SKShapeNode(rectOf: place.rect.size)
                    test.position = place.rect.origin
                    if test.frame.contains(endPos!) {
                        let index = tamaViewScenes.index(of: currentTama!)
                        sceneEntites[index!].spot = Int16(count)
                        
                        let holderSpot = sceneRects.rowedIndex((currentTama?.spot!)!) as! SceneSpot
                        holderSpot.isOccupied = false
                        holderSpot.scene = nil
                        
                        
                        if place.isOccupied {
                            
                            sceneEntites[place.scene].spot = Int16(currentTama.spot)
                            tamaViewScenes[place.scene].spot = currentTama?.spot
                            tamaViewScenes[place.scene].position = holderSpot.rect.origin
                            holderSpot.scene = place.scene
                            holderSpot.isOccupied = true
                            
                        }
                        let sceneInArray = sceneRects.rowedIndex(count) as! SceneSpot
                        sceneInArray.scene = index
                        sceneInArray.isOccupied = true
                        tamaViewScenes[index!].spot = count
                        currentTama?.position = place.rect.origin
                        
                        break topLevel;
                        
                        
                    }
                    currentTama?.position = (sceneRects.rowedIndex((currentTama?.spot)!) as! SceneSpot).rect.origin
                    count += 1
                }
            }
            
            currentTama.zPosition = 10
            let scaleaction = SKAction.scale(to: 1, duration: 0)
            currentTama.run(scaleaction)
        }
        
        currentTama = nil
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    func setUpSceneRects() {
        
        let imageWidth = Int((UIImage(named: "tamaHome.png")?.size.width)!) * viewScale
        let imageHeight = Int((UIImage(named: "tamaHome.png")?.size.height)!) * viewScale
        let length = Int(self.size.width/CGFloat(imageWidth))
        
        
        let widthSpacing = (Int(self.size.width) - (length * imageWidth))/(length + 1)
        let height = Int(self.size.height/(CGFloat(imageHeight) + CGFloat(widthSpacing)))
        let heightSpacing = widthSpacing
        let topLeft = CGPoint(x: Int(-(self.size.width/2)), y: Int(self.size.height/2))
        sceneRects = [[SceneSpot]](repeating:[SceneSpot](repeating: SceneSpot(rect: CGRect.zero), count: length), count: height)
        for w in 0..<length {
            for l in 0..<height {
                let offsetX = (w+1)*widthSpacing + w*imageWidth
                let offsetY = (l+1)*heightSpacing + l*imageHeight
                let point = (Int(topLeft.x) + offsetX + (imageWidth/2), Int(topLeft.y) - offsetY - (imageHeight/2))
                let rect = CGRect(x: point.0, y: point.1, width: imageWidth, height: imageHeight)
                sceneRects[l][w] = SceneSpot(rect: rect)
                
            }
        }
    }
    
    override func didMove(to view: SKView) {
        self.size = (self.view?.frame.size)!
        setUpSceneRects()
        
        
        sceneEntites = getScenes()
        CreateScenesFromEntities()
        
        //add small buttons
        self.addChild(newTamaButton)
        self.addChild(trashPlace)
        trashPlace.isHidden = true
        
        
    }
    
    func changeTextureOfTama(i: Int, toD: String, isUpdating: Bool) {
        let randomTama = generateRandomTama(1, appendingPC: toD)[0]
        sceneEntites[i].tamagotchi?.tamaName = randomTama
        if isUpdating {
            let tama = tamaViewScenes[i].tama
            let image = UIImage(named: (randomTama))?.resizeImage(scale: CGFloat(viewScale))
            tama?.texture = SKTexture(cgImage: (image?.cgImage)!)
            tama?.size = (tamaViewScenes[i].tama.texture?.size())!
        }
        
    }
    
    
    //controlled time interval
    var timeSinceMove: Double! = 0
    var checkForEvol: Double! = 0
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if timeSinceMove >= 2 {
            for tamascene in tamaViewScenes {
                tamascene.tama.move()
            }
            timeSinceMove = 0
            
        }
        if checkForEvol >= 5 {
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

extension TamasScene {
    func generateRandomTama(_ n: Int, appendingPC: String) -> [String] {
        var tamas: [String]! = []
        let resourcePath = NSURL(string: Bundle.main.resourcePath!)?.appendingPathComponent("tamahive.bundle")?.appendingPathComponent("tamas").appendingPathComponent(appendingPC)
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
    
    func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    
}
extension Array where Element: Collection, Element.Index == Int {
    func countFromLeft(_ index: Int) -> (Any, [Any]){
        var holder = [Any]()
        for i in 0..<self.count {
            for j in self[i] {
                holder.append(j)
            }
        }
        return (holder[index] as Any, holder)
    }
    
    func count() -> Int {
        return (countFromLeft(1).1.count)
    }
    
    func rowedIndex(_ i: Int) -> Any{
        let f = i / (Int(self[0].count))
        let s = i % (Int(self[0].count))
        return self[f][s]
    }
    
    
}





