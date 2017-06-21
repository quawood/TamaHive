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
    var fakeScenes: [TamaHouse]! = []
    let viewScale: Int! = 2
    
    var touch = UITouch()
    var currentTama: TamaHouse!
    var touchdx: CGFloat!
    var touchdy: CGFloat!
    var beginPos: CGPoint!
    
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
            if self.sceneEntites.count < 10 {
                
                let scene = TamaSceneEntity(context:self.context)
                scene.id = Int16(self.sceneEntites.count)
                scene.color1 = self.generateRandomColor()
                scene.color2 = self.generateRandomColor()
                scene.span = "n"
                scene.spot = "0,0"
                let tama = TamagotchiEntity(context: self.context)
                let genders = ["m","f"]
                let date = Date()
                let randomFam = Int(arc4random_uniform(UInt32(self.familyNames.count)))
                
                tama.age = 0
                tama.generation = 1
                tama.happiness = 5
                tama.hunger = 5
                tama.tamaName = "egg"
                tama.id = 0
                tama.gender = genders[Int(arc4random_uniform(2))]
                tama.family = self.self.familyNames[randomFam]
                tama.dateCreated = date
                tama.tamascene = scene
                scene.addToTamagotchi(tama)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                self.sceneEntites = self.getScenes()
                self.setupScene(scene: scene)
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func didMove(to view: SKView) {
        self.size = (self.view?.frame.size)!
       // setUpSceneRects()
        CreateScenesFromEntities()
        self.addChild(newTamaButton)
        self.addChild(trashPlace)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.appWillTerminate), name: Notification.Name.UIApplicationWillTerminate, object: nil)
        
        
    }
    
    
    func setupScene(scene: TamaSceneEntity) {
        //setup individual tamagotchi
        let scale = viewScale!
        var tamaScene: TamaHouse!
        var fakeScene = TamaHouse(textureNamed: "normaltamaHome.png", scale: viewScale)
        switch scene.span! {
        case "n":
            tamaScene = TamaHouse(textureNamed: "normaltamaHome.png", scale: Int(scale))
            
        case "l":
            tamaScene = TamaHouse(textureNamed: "longtamaHome.png", scale: Int(scale))
            
            
        case "t":
            tamaScene = TamaHouse(textureNamed: "talltamaHome.png", scale: Int(scale))
        default:
            break
        }
        
        
        
        
        //create new tamascene
        tamaScene.position = (scene.spot?.toPoint())!
        tamaScene.color1 = scene.color1 as! UIColor
        tamaScene.color2 = scene.color2 as! UIColor
        tamaScene.span = scene.span
        
        
        scene.tamagotchi?.forEach({
            let x = $0 as! TamagotchiEntity
            let newTama = Tamagotchi(textureNamed: (x.tamaName)!, scale: Int(scale))
            newTama.zPosition = 10
            newTama.age = x.age
            newTama.gender = x.gender
            newTama.id = x.id
            newTama.tamaName = x.tamaName
            newTama.family = x.family
            newTama.generation = x.generation
            newTama.hunger = x.hunger
            newTama.happiness = x.happiness
            newTama.dateCreated = x.dateCreated
            tamaScene.tama.append(newTama)
            
        })
        
        if scene.span != "n" {
        fakeScene.size = CGSize.zero
        fakeScene.isFakeScene = true
        //tamaScene.addChild(fakeScene)
            //fakeScenes.append(fakeScene)
        }
        
        //setup tamagotchi border
        let tile = SKShapeNode(rectOf: tamaScene.size, cornerRadius: 7)
        tile.strokeColor = tamaScene.color2
        tile.zPosition = 10
        tile.lineWidth = CGFloat(viewScale * 4)
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
        let sceneSorted = sceneEntites.sorted(by: { $0.id < $1.id })
        for scene in sceneSorted {
            setupScene(scene: scene)
        }
        updateTamas()
        
    }
    
    
    
    
    
    
    
    
    
    
    func updateTamas() {
        var count = 0
        print(tamaViewScenes.count)
        tamaViewScenes.forEach({
            if $0.isFakeScene != true {
                let scene = $0
                let index = tamaViewScenes!.index(of: scene)
                let tama = scene.tama
                var newAge: Int! = 0
                
                tama?.forEach({
                    let correspondingEntity = sceneEntites.first(where: {x in
                        x.id == Int16(tamaViewScenes.startIndex.distance(to: count))
                    })
                    let date = Date()
                    
                    newAge = date.interval(ofComponent: .second, fromDate:$0.dateCreated)/2
                    if Int16(newAge) != $0.age && ($0.age)! < 4  {
                        var randomTama = String()
                        switch newAge {
                        case 1:
                            randomTama = "baby"
                        case 2 :
                            randomTama = "toddler,\($0.gender!)"
                            
                        case 3:
                            randomTama = "teen,\($0.gender!)"
                            
                        default:
                            randomTama = "adult,\($0.gender!)"
                            
                        }
                        if scene.tama.count == 1 {
                            changeTextureOfTama(fromTama: scene, toTama: randomTama)
                        }
                        
                        
                        
                        
                    }
                    $0.age = Int16(newAge)
                    
                    count += 1
                })
                
                if tama![0].age > 7 && scene.tama.count == 1 {
                    let onlyTama = tama?.first
                    let goodRect1 = CGRect(x: scene.position.x+30+scene.size.width, y: scene.position.y + scene.size.height/2, width: scene.size.width + 30, height: 2 * scene.size.height)
                    let goodRect2 = CGRect(x: scene.position.x + scene.size.width/2, y: scene.position.y+30+scene.size.height, width: 2 * scene.size.width, height: scene.size.height + 30)
                    var hasRightNeighbor: Bool! {
                        var boolt: Bool! = false
                        for scene in tamaViewScenes {
                            if goodRect1.contains(scene.position) {
                                boolt = true
                                break;
                            } else {
                                boolt = false
                            }
                        }
                        return boolt
                    }
                    var hasBottomNeighbor: Bool! {
                        var boolt: Bool! = false
                        for scene in tamaViewScenes {
                            if goodRect2.contains(scene.position) {
                                boolt = true
                                break;
                            } else {
                                boolt = false
                            }
                        }
                        return boolt
                    }
                    checkN:  if hasRightNeighbor {
                        
                        if let rightNeighbor = tamaViewScenes.first(where: {goodRect1.contains($0.position)}) {
                            let rightNeighbortama = rightNeighbor.tama.first
                            if rightNeighbortama!.age > 7 && rightNeighbortama!.gender != onlyTama?.gender && rightNeighbor.tama.count == 1 {
                                newFamilyScene(scene: scene, tama1: onlyTama!, tama2: rightNeighbortama!, span:"l")
                                break checkN;
                                
                            }
                        }
                    }
                    else if hasBottomNeighbor {
                        
                        if let bottomNeighbor = tamaViewScenes.first(where: {goodRect2.contains($0.position)}) {
                            let bottomNeighbortama = bottomNeighbor.tama.first
                            if bottomNeighbortama!.age > 7 && bottomNeighbortama!.gender != onlyTama?.gender && bottomNeighbor.tama.count == 1 {
                                newFamilyScene(scene: scene, tama1: onlyTama!, tama2: bottomNeighbortama!, span: "t")
                                
                            }
                        }
                    }
                }
                
            }
            
        })
        
    }
    
    
    func newFamilyScene(scene: TamaHouse, tama1: Tamagotchi, tama2: Tamagotchi, span: String) {
        let newscene = TamaSceneEntity(context:self.context)
        newscene.id = Int16(self.sceneEntites.count) - 2
        newscene.color1 = scene.color1
        newscene.color2 = scene.color2
        newscene.spot = scene.position.toString()
        newscene.span = span
        
        let index1 = tamaViewScenes.index(of: tamaViewScenes.first(where: {$0.tama.first! == tama1})!)
        var index2 = tamaViewScenes.index(of: tamaViewScenes.first(where: {$0.tama.first! == tama2})!)
        var newtama1 = TamagotchiEntity(context:self.context)
        var newtama2 = TamagotchiEntity(context:self.context)
        newtama1 = sceneEntites!.first(where: {$0.id == tamaViewScenes.startIndex.distance(to: index1!)})?.tamagotchi?.first(where: {_ in true}) as! TamagotchiEntity
        newtama2 = sceneEntites!.first(where: {$0.id == tamaViewScenes.startIndex.distance(to: index2!)})?.tamagotchi?.first(where: {_ in true}) as! TamagotchiEntity
        newtama2.id = 1
        newscene.addToTamagotchi(newtama1)
        newscene.addToTamagotchi(newtama2)
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        view?.isPaused = true
        deleteTask(atPos: index1!)
        index2 = tamaViewScenes.index(of: tamaViewScenes.first(where: {$0.tama.first! == tama2})!)
        deleteTask(atPos: index2!)
        
        setupScene(scene: newscene)
        print(tamaViewScenes.count)
        view?.isPaused = false
        
    }
    
    func changeTextureOfTama(fromTama: TamaHouse, toTama: String) {
        
        let index = tamaViewScenes.index(where: {$0 == fromTama})
        let i = tamaViewScenes[index!]
        let correspondingEntity = sceneEntites.first(where: {$0.id == tamaViewScenes.startIndex.distance(to: index!)})
        i.tama.forEach({
            let tama = $0
            let randomTama = generateRandomTama(1, appendingPC: toTama)[0]
            (correspondingEntity?.tamagotchi?.first(where: {($0 as AnyObject).id == tama.id}) as! TamagotchiEntity).tamaName = randomTama
            let image = UIImage(named: (randomTama))?.resizeImage(scale: CGFloat(viewScale))
            $0.tamaName = randomTama
            $0.texture = SKTexture(cgImage: (image?.cgImage)!)
            $0.size = ($0.texture?.size())!
            
            
        })
        
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touch = touches.first!
        
        
        for i in 0..<tamaViewScenes.count {
            if tamaViewScenes[i].frame.contains((touch.location(in: self.scene!))) {
                
                let scene = tamaViewScenes[i]
                currentTama = scene
                beginPos = currentTama.position
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
                        let test = SKShapeNode(rectOf: p1.size)
                        test.position = p1.position
                        if test.frame.contains(newLoc) {
                            let spotP = p1.position
                            p1.position = beginPos
                            self.currentTama.position = spotP
                            
                            let ph = p1.position
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
                let indexed = tamaViewScenes.index(of: currentTama)
                deleteTask(atPos: indexed!)
                
                break checkForContains
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
            sceneEntites[index!].spot = tamaViewScenes[i].position.toString()
            sceneEntites[index!].tamagotchi?.forEach({
                let tama = $0 as! TamagotchiEntity
                tama.age = (tamaViewScenes[i].tama.first(where: {$0.id == tama.id})?.age)!
            })
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
    }
    
    
    
    
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if timeSinceMove >= 2 {
            tamaViewScenes.forEach( {
                $0.tama.forEach({
                    $0.move()
                })
            })
            timeSinceMove = 0
            
        }
        if checkForEvol >= 1 {
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

extension String {
    func toPoint() -> CGPoint{
        let stringARray = self.components(separatedBy: ",")
        let point = CGPoint(x:Int(stringARray[0])!, y:Int(stringARray[1])!)
        return point
    }
}

extension CGPoint {
    func toString() -> String {
        return "\(self.x),\(self.y)"
    }
}





