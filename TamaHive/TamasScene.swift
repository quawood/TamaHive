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
    private var lastUpdateTime : TimeInterval = 0
    
    let familyNames = ["mame","meme","kuchi","large","ninja","secret","small","space","violet"]
    //core data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var sceneEntites: [TamaSceneEntity]! = []
    var tamaViewScenes: [TamaHouse]! = []
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
        
        let tamaScene = TamaHouse(textureNamed: "tamaHome.png", scale: Int(scale))
        
        tamaScene.tama = Tamagotchi(textureNamed: scene.tamagotchi?.tamaName as! String, scale: Int(scale))
        
        //create new tamascene
        let holderSpot = sceneRects.rowedIndex(Int(scene.spot)) as! CGRect
        tamaScene.color1 = scene.color1 as! UIColor
        tamaScene.color2 = scene.color2 as! UIColor
        tamaScene.spot = Int(scene.spot)
        tamaScene.position = CGPoint(x: holderSpot.origin.x , y: holderSpot.origin.y)
        
        tamaScene.tama.zPosition = 10
        //setup tamagotchi border
        let tile = SKShapeNode(rectOf: tamaScene.size, cornerRadius: 7)
        tile.strokeColor = tamaScene.color2
        tile.zPosition = 10
        tile.lineWidth = CGFloat(viewScale * 3)
        tile.position = CGPoint.zero
        
        /*let label = SKLabelNode(text: String(scene.id))
        label.fontSize = 15
        label.fontColor = UIColor.black
        label.fontName = "arial"
        label.position = CGPoint(x: 50, y: 25)
        label.zPosition = 15*/
        
        addChild(tamaScene)
        tamaScene.displayTama()
        tamaScene.addChild(tile)
        //tamaScene.addChild(label)
        tamaViewScenes.append(tamaScene)
        
        
        
        
    }
    
    func deleteTask(atPos: Int) {
        let request = NSFetchRequest<TamaSceneEntity>(entityName: "TamaSceneEntity")
        var ids = [Int16]()
       do {
            let searchResults = try self.context.fetch(request)
            ids = searchResults.map( {$0.id})
            var count = 0
            self.context.delete(searchResults[ids.index(where: {$0 == Int16(atPos)})!])
            
        } catch {
            print("Error with request: \(error)")
        }
        
        tamaViewScenes[atPos].removeFromParent()
        tamaViewScenes.remove(at: atPos)
        
         (UIApplication.shared.delegate as! AppDelegate).saveContext()
        sceneEntites = getScenes()
        ids = sceneEntites.map( {$0.id})
        for i in 0..<ids.count {
            if ids[i] > atPos {
                let sceneIndex = sceneEntites.index(where: {$0.id == Int16(ids[i])})
                let k = sceneEntites[sceneIndex!].id - 1
                sceneEntites[sceneIndex!].id = sceneEntites[sceneIndex!].id - 1
                let test = Int(ids[i]) - 1
                
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
    
    func createNewSceneEntity() {
            if self.sceneEntites.count < self.sceneRects.count() {
                
                let scene = TamaSceneEntity(context:self.self.context)
                scene.id = Int16(self.sceneEntites.count)
                scene.color1 = self.generateRandomColor()
                scene.color2 = self.generateRandomColor()
                var rectS: Int!
                var count = 0
                let spotsArray = self.tamaViewScenes.map( {$0.spot})
                topLevel: for i in self.sceneRects {
                    for scenerect in i {
                        guard let indexOfReplace = spotsArray.index(where: {$0 == count}) else {
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
    func updateTamas(isUpdating: Bool) {
        for i in 0..<sceneEntites.count {
            let tama = sceneEntites[i].tamagotchi
            if (tama?.age)! < 4 {
                let date = Date()
                
                let newAge = date.interval(ofComponent: .second, fromDate: (tama?.dateCreated)!)/2
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
    var currentTama: TamaHouse!
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
                        
                        
                        let spotsArray = tamaViewScenes.map( {$0.spot})
                        if let indexOfReplace = spotsArray.index(where: {$0 == count}) {
                            tamaViewScenes?[indexOfReplace].spot = currentTama.spot
                            tamaViewScenes?[indexOfReplace].position = (sceneRects.rowedIndex(currentTama.spot) as! CGRect).origin
                        }
                        
                        currentTama.spot = count
                        currentTama.position = (sceneRects.rowedIndex(count) as! CGRect).origin
                        /*let ind = tamaViewScenes.index(where: {$0.spot == currentTama.spot})
                        let ind1 = sceneEntites.index(where: {Int($0.id) == ind})!
                        sceneEntites[ind1].spot = Int16(count)*/
                        break topLevel;
                        
                        
                    }
                    //if no frame contains tama, set position equal to before
                    currentTama?.position = (sceneRects.rowedIndex((currentTama?.spot)!) as! CGRect).origin
                    count += 1
                }
            }
            
            
            
            currentTama.zPosition = 10
            let scaleaction = SKAction.scale(to: 1, duration: 0)
            currentTama.run(scaleaction)
        }
        
        currentTama = nil
        
    }
    func setUpSceneRects() {
        
        let imageWidth = Int((UIImage(named: "tamaHome.png")?.size.width)!) * viewScale
        let imageHeight = Int((UIImage(named: "tamaHome.png")?.size.height)!) * viewScale
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
    
    func appWillTerminate () {
        
        for i in 0..<sceneEntites.count {
            let sceneMappedArray = sceneEntites.map( {$0.id})
            let index = sceneEntites.index(where: { $0.id == i})
            sceneEntites[index!].spot = Int16(tamaViewScenes[i].spot)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
        }
        print(sceneEntites)
        
    }
    //1ch _ 0cha 3ba _ _ 4 2pa 6cha 5ch
    
    override func didMove(to view: SKView) {
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.appWillTerminate), name: Notification.Name.UIApplicationWillTerminate, object: nil)
        self.size = (self.view?.frame.size)!
        setUpSceneRects()
        
        
        CreateScenesFromEntities()
        
        //add small buttons
        self.addChild(newTamaButton)
        self.addChild(trashPlace)
        trashPlace.isHidden = true
        print(sceneEntites)
        
        
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
        /*
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
 */
        return UIColor(red:   .random() ,
                       green: .random() ,
                       blue:  .random(),
                       alpha: 1.0)
    }
    
    
}

extension CGFloat {
    static func random() -> CGFloat {
        let ret = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return ret
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




