//
//  TamasScene+LLF.swift
//  TamaHive
//
//  Created by Qualan Woodard on 6/24/17.
//  Copyright © 2017 Qualan Woodard. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreData

extension TamasScene {
    func deleteTama(tamatoDelete: TamagotchiEntity) {
        let sceneEntity = sceneEntites.first(where: {($0.tamagotchi as! Set<TamagotchiEntity>).contains(tamatoDelete)})
        let index = Int(sceneEntity!.id)
        
        sceneEntity?.removeFromTamagotchi(tamatoDelete)
        tamaViewScenes[index].tamagotchis.first(where:{$0.id > 1})?.removeFromParent()
        tamaViewScenes[index].tamagotchis.remove(at: tamaViewScenes[index].tamagotchis.index(where: {$0.id > 1})!)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        sceneEntites = getScenes()
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
        sceneEntites = getScenes()
        
        
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
    
    @objc func createNewSceneEntity(_ sender: FTButtonNode?) {
        if !isEditing {
            sender?.removeFromParent()
        }
        DispatchQueue.main.async {
            if self.sceneEntites.count < 10 {
                
                let scene = TamaSceneEntity(context:self.context)
                scene.id = Int16(self.sceneEntites.count)
                scene.color1 = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
                scene.color2 = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
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
                tama.tamaName = "egg.png"
                tama.id = 0
                tama.gender = genders[Int(arc4random_uniform(2))]
                tama.family = self.familyNames[randomFam]
                tama.dateCreated = date
                tama.tamascene = scene
                scene.addToTamagotchi(tama)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                self.sceneEntites = self.getScenes()
                self.setupScene(scene: scene)
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    func setupScene(scene: TamaSceneEntity) {
        //setup individual tamagotchi
        let scale = viewScale!
        var tamaScene: TamaHouse!
        switch scene.span! {
        case "n":
            tamaScene = TamaHouse(textureNamed: "normaltamaHome.png", scale: Int(scale))
            
            
        case "l":
            tamaScene = TamaHouse(textureNamed: "longtamaHome.png", scale: Int(scale))
            
            
        default:
            break
        }
        
        
        
        
        //create new tamascene
        tamaScene.position = (scene.spot?.toPoint())!
        tamaScene.color1 = scene.color1 as! UIColor
        tamaScene.color2 = scene.color2 as! UIColor
        tamaScene.span = scene.span
        let generation = (scene.tamagotchi?.first(where: {_ in true}) as! TamagotchiEntity).generation
        let label = SKLabelNode(text: String(generation))
        label.position = CGPoint(x:-(tamaScene.size.width/2) + 20, y: (tamaScene.size.height/2) - 20)
        label.fontSize = 13
        label.fontColor = UIColor.black
        label.fontName = "HelveticaNeue-CondensedBlack"
        label.zPosition = 1
        
        scene.tamagotchi?.forEach({
            let newTama = tamaFromEntity(tama: $0 as! TamagotchiEntity)
            newTama.zPosition = 1
            tamaScene.tamagotchis.append(newTama)
            
        })
        
        //setup tamagotchi border
        let tile = SKShapeNode(rectOf: tamaScene.size, cornerRadius: 7)
        tile.strokeColor = tamaScene.color1
        
        tile.lineWidth = CGFloat(viewScale * 3)
        tile.position = CGPoint.zero
        tile.zPosition = 1
        tamaScene.zPosition = CGFloat(zCounter)
        tile.name = "border"
        
        addChild(tamaScene)
        tamaScene.displayTamagotchis()
        tamaScene.addChild(tile)
        
        tamaScene.addChild(label)
        tamaViewScenes.append(tamaScene)
        tile.zPosition = 1
        label.zPosition = 1
        
        
        zCounter += 2
        
    }
    
    
    func tamaFromEntity(tama: TamagotchiEntity) -> Tamagotchi {
        let newTama = Tamagotchi(textureNamed: (tama.value(forKey: "tamaName") as! String), scale: viewScale)
        newTama.age = tama.age
        newTama.hunger = tama.hunger
        newTama.dateCreated = tama.dateCreated
        newTama.family = tama.family
        newTama.generation = tama.generation
        newTama.happiness = tama.happiness
        newTama.id = tama.id
        newTama.gender = tama.gender
        newTama.tamaName = tama.tamaName
        return newTama
    }
    
    

    
    
    
    func cancelPrepare() {
        counting = false
        timeSincePress = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touch = touches.first!
        
        
        top: for i in 0..<tamaViewScenes.count {
            if tamaViewScenes[i].frame.contains((touch.location(in: self.scene!))) {
                let scene = tamaViewScenes[i]
                currentTama = scene
                touchdx = touch.location(in: self.scene!).x - (currentTama?.position.x)!
                touchdy = touch.location(in: self.scene!).y - (currentTama?.position.y)!
                currentTama.zPosition = CGFloat(maxZposition + 2)
                if isEditing == true  {
                    
                    beginPos = currentTama.position
                    self.isBeingDragged = true
                    touchdx = touch.location(in: self.scene!).x - (currentTama?.position.x)!
                    touchdy = touch.location(in: self.scene!).y - (currentTama?.position.y)!
                    
                    let scale = SKAction.scale(to: 1.2, duration: 0)
                    currentTama.run(scale)
                    
                    
                    break top;
                } else {
                    let colorizeAction = SKAction.colorize(with: UIColor.gray, colorBlendFactor: 0.8, duration: 0)
                    currentTama.run(colorizeAction)
                    counting = true
                    timeSincePress = 0
                    break top;
                    
                }
                
                
            }
        }
        guard (currentTama) != nil else{
            if isEditing {
                isEditing = false
                self.childNode(withName: "trashB")?.removeFromParent()
                if tamaViewScenes.count > 0 {
                    self.childNode(withName: "CreateB")?.removeFromParent()
                }
                
                cancelPrepare()
                
            }
            return
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let newTouch = touches.first
        if counting {
            if !currentTama.frame.contains((newTouch?.location(in: self.scene!))!) {
                cancelPrepare()
                currentTama.run(uncolorizeAction)
            }
            
        }
        
        if isEditing{
            if newTouch == touch {
                if let tama = currentTama {
                    
                    let newLoc = (newTouch?.location(in: self.scene!))!
                    
                    tama.position = CGPoint(x: newLoc.x - touchdx, y: newLoc.y - touchdy)
                    
                    
                }
            }
        }
        
        
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let endPos = touches.first?.location(in: self.scene!)
        
        checkForContains: if currentTama != nil {
            if !isEditing {
                currentTama.run(uncolorizeAction)
                isEditing = false
                cancelPrepare()
                
                
            } else if isEditing {
                //delete tama if in trash node
                if trashPlace.frame.contains(endPos!) {
                    
                    let indexed = tamaViewScenes.index(of: currentTama)
                    deleteTask(atPos: indexed!)
                    
                    break checkForContains
                }
                
                var newPoint: CGPoint! = currentTama.position
                let xRange: CountableClosedRange = Int(-currentTama.size.width/2)...Int(self.size.width/2)
                let yRange: CountableClosedRange = Int(-currentTama.size.height/2)...Int(self.size.height/2)
                if !xRange.contains(Int(abs(currentTama.position.x) + currentTama.size.width/2)) {
                    newPoint = CGPoint(x: CGFloat(currentTama.position.x.sign())*(self.size.width/2 - currentTama.size.width/2 - 5), y: currentTama.position.y)
                }
                if !yRange.contains(Int(abs(currentTama.position.y) + currentTama.size.height/2)) {
                    newPoint = CGPoint(x: currentTama.position.x, y:  CGFloat(currentTama.position.y.sign())*(self.size.height/2 - currentTama.size.height/2 - 5))
                }
                let snapBackAction = SKAction.move(to: newPoint, duration: 0.1)
                currentTama.run(snapBackAction)
                let scaleaction = SKAction.scale(to: 1, duration: 0)
                currentTama.run(scaleaction, completion: {
                    self.isBeingDragged = false
                })
                
                maxZposition = Int(currentTama.zPosition)
            }
            
        }
        currentTama = nil
        
    }
    
    
    
    
    func saveViewsToEntities() {
        for i in 0..<sceneEntites.count {
            let index = sceneEntites.index(where: { $0.id == i})
            sceneEntites[index!].spot = tamaViewScenes[i].position.toString()
            sceneEntites[index!].tamagotchi?.forEach({
                let tama = $0 as! TamagotchiEntity
                let modelTama = tamaViewScenes[i].tamagotchis.first(where: {$0.id == tama.id})
                tama.age = (modelTama?.age!)!
                tama.tamaName = modelTama?.tamaName
            })
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    
    
    
    @objc func FTbuttonAction(_ sender: Any) {
        if let button1 = sender as? FTButtonNode {
            button1.action()
            button1.removeFromParent()
        }
    }
    
    
    func updateTamas() {
        if isBeingDragged == false {
            var count = 0
            var count1 = 0
            tamaViewScenes.forEach({scene in
                let tamagotchis = scene.tamagotchis
                let firstTama = tamagotchis![0]
                
                tamagotchis?.forEach({tama in
                    updateTamagotchiTexture(fromTama: tama)
                    count += 1
                })
                
                
                var childTamagotchi = Tamagotchi(textureNamed: "egg", scale: viewScale)
                if let child = scene.tamagotchis.first(where: {$0.id  > 1}) {
                    childTamagotchi = child
                }
                let sceneEntity = sceneEntites.first(where: {$0.id == count1})
                
                checkForMarriage: if firstTama.age > 7 && tamagotchis!.count == 1 {
                    for sceneToCheck in tamaViewScenes {
                        if sceneToCheck != scene {
                            let xDist = sceneToCheck.position.x - scene.position.x
                            let yDist = sceneToCheck.position.y - scene.position.y
                            
                            if abs(xDist) < scene.size.width + 50 && abs(yDist) < 30 {
                                updateTmamagotchiMarriage(scene: scene, rNeighbor: sceneToCheck)
                                break checkForMarriage
                                
                            }
                            
                        }
                        
                    }
                    if let button = scene.children.first(where: {$0 is FTButtonNode}) {
                        button.removeFromParent()
                    }
                    
                }
                if tamagotchis![0].age > 15 && scene.tamagotchis.count == 2 && sceneEntity!.isDone == false{
                    addTamagotchiChild(scene: scene, sceneEntity: sceneEntity!)
                }
                if childTamagotchi.age > 10 && scene.tamagotchis.count > 2 {
                    updateTamagotchiLeave(scene: scene)
                    
                }
                
                count1 = count1 + 1
            })
            
            
        }
        
    }
    
    
    
    
    
    
    func newFamilyScene(scene: TamaHouse, tama1: Tamagotchi, tama2: Tamagotchi, span: String) {
        let newscene = TamaSceneEntity(context:self.context)
        newscene.id = Int16(self.sceneEntites.count)
        newscene.color1 = scene.color1
        newscene.color2 = scene.color2
        newscene.spot = scene.position.toString()
        newscene.span = span
        
        let index1 = tamaViewScenes.index(of: tamaViewScenes.first(where: {$0.tamagotchis.first! == tama1})!)
        var index2 = tamaViewScenes.index(of: tamaViewScenes.first(where: {$0.tamagotchis.first! == tama2})!)
        var newtama1 = TamagotchiEntity(context:self.context)
        var newtama2 = TamagotchiEntity(context:self.context)
        newtama1 = sceneEntites!.first(where: {$0.id == tamaViewScenes.startIndex.distance(to: index1!)})?.tamagotchi?.first(where: {_ in true}) as! TamagotchiEntity
        newtama2 = sceneEntites!.first(where: {$0.id == tamaViewScenes.startIndex.distance(to: index2!)})?.tamagotchi?.first(where: {_ in true}) as! TamagotchiEntity
        newtama2.id = 1
        newscene.addToTamagotchi(newtama1)
        newscene.addToTamagotchi(newtama2)
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        sceneEntites = getScenes()
        deleteTask(atPos: index1!)
        index2 = tamaViewScenes.index(of: tamaViewScenes.first(where: {$0.tamagotchis.first! == tama2})!)
        deleteTask(atPos: index2!)
        
        
        setupScene(scene: newscene)
        
    }
    
    func changeTamagotchiTexture(fromTama: Tamagotchi, toTama: String) {
        let index = tamaViewScenes.index(where: {$0.tamagotchis.contains(fromTama)})
        let i = tamaViewScenes[index!]
        let correspondingEntity = sceneEntites.first(where: {$0.id == tamaViewScenes.startIndex.distance(to: index!)})
        let tama = i.tamagotchis.first(where: {$0.id == fromTama.id})
        let randomTama = generateRandomTama(1, appendingPC: toTama)[0]
        let tamaEntity = correspondingEntity?.tamagotchi?.first(where: {($0 as! TamagotchiEntity).id == fromTama.id}) as! TamagotchiEntity
        tama?.tamaName = randomTama
        tamaEntity.tamaName = tama?.tamaName
        let image = UIImage(named: (randomTama))?.resizeImage(scale: CGFloat(viewScale))
        tama?.texture = SKTexture(cgImage: (image?.cgImage)!)
        tama?.size = (tama?.texture?.size())!
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        sceneEntites = getScenes()
    }
    
    func updateTamagotchiTexture(fromTama: Tamagotchi) {
        let date = Date()
        let newAge = date.interval(ofComponent: .second, fromDate:fromTama.dateCreated)/1
        if Int16(newAge) != fromTama.age && (fromTama.age)! < 4  {
            var randomTama = String()
            switch newAge {
            case 1:
                randomTama = "baby"
            case 2 :
                randomTama = "toddler,\(fromTama.gender!)"
                
            case 3:
                randomTama = "teen,\(fromTama.gender!)"
                
            default:
                randomTama = "adult,\(fromTama.family!),\(fromTama.gender!)"
            }
            let parent = fromTama.parent as! TamaHouse
            if parent.tamagotchis.count == 1 || (parent.tamagotchis.count == 3 && fromTama.id == 2) {
                changeTamagotchiTexture(fromTama: fromTama, toTama: randomTama)
            }
            
            
            
            
        }
        
        fromTama.age = Int16(newAge)
    }
    
    func updateTmamagotchiMarriage(scene: TamaHouse, rNeighbor: TamaHouse) {
        let firstTama = scene.tamagotchis.first!
        let rNeighbortama = rNeighbor.tamagotchis.first
        if rNeighbortama!.age > 7 && rNeighbortama!.gender != firstTama.gender && rNeighbor.tamagotchis.count == 1 {
            
            let buttonTexture: SKTexture! = SKTexture(imageNamed: "marrybutton.png")
            let buttonTextureSelected: SKTexture! = SKTexture(imageNamed: "marrybuttonselected.png")
            let marrybutton = FTButtonNode(defaultTexture: buttonTexture, selectedTexture: buttonTextureSelected, action: {
                self.changeTamagotchiTexture(fromTama: firstTama, toTama: "parents,\(firstTama.family!),\(firstTama.gender!)")
                self.changeTamagotchiTexture(fromTama: rNeighbortama!, toTama: "parents,\(rNeighbortama!.family!),\(rNeighbortama!.gender!)")
                self.newFamilyScene(scene: scene, tama1: firstTama, tama2: rNeighbortama!, span:"l")
            })
            marrybutton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(FTbuttonAction(_:)))
            marrybutton.position = CGPoint(x: scene.size.width/2, y: -scene.size.height/2)
            
            
            var hasAButton: Bool! = false
            for child in scene.children {
                if child is FTButtonNode {
                    hasAButton = true
                }
                
            }
            if !hasAButton {
                scene.addChild(marrybutton)
            }
            
        }
        
    }
    
    func updateTamagotchiLeave(scene: TamaHouse) {
        self.sceneEntites = self.getScenes()
        self.saveViewsToEntities()
        
        
        
        let count1 = tamaViewScenes.index(of: scene)
        let tamasPar = self.sceneEntites.first(where: {$0.id == Int16(tamaViewScenes.startIndex.distance(to: count1!))})?.tamagotchi
        let tamatoDelete = tamasPar?.first(where: {($0 as! TamagotchiEntity).id > 1}) as! TamagotchiEntity
        let buttonTexture: SKTexture! = SKTexture(imageNamed: "leavebutton.png")
        let buttonTextureSelected: SKTexture! = SKTexture(imageNamed: "leavebuttonselected.png")
        let leavebutton = FTButtonNode(defaultTexture: buttonTexture, selectedTexture: buttonTextureSelected, action: {
            self.moveChildTamagotchi(scene: scene, tamatoDelete: tamatoDelete)
            
        })
        leavebutton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(FTbuttonAction(_:)))
        leavebutton.position = CGPoint(x: scene.size.width/2, y: -scene.size.height/2)
        
        var containsB: Bool! = false
        for child in scene.children {
            if child is FTButtonNode {
                containsB = true
            }
            
        }
        if containsB == false {
            scene.addChild(leavebutton)
            leavebutton.zPosition = 1
            
        }
        if tamaViewScenes.count == 10 {
            
            if let button = scene.children.first(where: {$0 is FTButtonNode}) {
                button.removeFromParent()
            }
        }
        
        
    }
    
    func addTamagotchiChild(scene: TamaHouse, sceneEntity: TamaSceneEntity) {
        
        self.view?.isPaused = true
        let newTama = TamagotchiEntity(context: self.context)
        newTama.age = 0
        newTama.generation = scene.tamagotchis![0].generation
        newTama.happiness = 5
        newTama.hunger = 5
        newTama.tamaName = "egg.png"
        newTama.id = 2
        newTama.gender = scene.tamagotchis![Int(arc4random_uniform(2))].gender
        newTama.family = scene.tamagotchis![Int(arc4random_uniform(2))].family
        let date = Date()
        newTama.dateCreated = date
        newTama.tamascene = sceneEntity
        sceneEntity.addToTamagotchi(newTama)
        sceneEntity.isDone = true
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        sceneEntites = getScenes()
        self.view?.isPaused = false
        scene.tamagotchis.append(tamaFromEntity(tama: newTama))
        for children in scene.children {
            if children is Tamagotchi {
                children.removeFromParent()
            }
        }
        scene.displayTamagotchis()
    }
    
    func moveChildTamagotchi(scene: TamaHouse, tamatoDelete: TamagotchiEntity) {
        let newScene = TamaSceneEntity(context: self.context)
        
        newScene.color1 = self.generateRandomColor(previousColor: scene.color1)
        newScene.color2 = self.generateRandomColor(previousColor: scene.color1)
        newScene.span = "n"
        
        var foundNewPosition: Bool! = false
        var degreeCount = Double(0)
        while foundNewPosition == false && degreeCount <= 360 {
            let x = scene.size.height*CGFloat(cos(degreeCount * .pi/180))+scene.position.x + 30
            let y = scene.size.height*CGFloat(sin(degreeCount * .pi/180))+scene.position.y + 30
            let newPos = CGPoint(x: x,y: y)
            if CGRect(origin:CGPoint(x:self.frame.origin.x + scene.size.width/2,y:self.frame.origin.y + scene.size.height/2),size:CGSize(width:self.frame.width-scene.size.width,height:self.frame.height - scene.size.height)).contains(newPos) {
                foundNewPosition = true
                newScene.spot = newPos.toString()
            }
            degreeCount = degreeCount + 1
        }
        //newScene.spot = CGPoint(x: scene.position.x, y: scene.position.y + scene.size.height + 30).toString()
        newScene.id = Int16(self.sceneEntites.count)
        var newTama = TamagotchiEntity(context: self.context)
        
        
        self.deleteTama(tamatoDelete: tamatoDelete)
        newTama = tamatoDelete
        newTama.id = 0
        newTama.generation = tamatoDelete.generation + 1
        newTama.tamascene = newScene
        newScene.addToTamagotchi(newTama)
        
        
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        self.sceneEntites = self.getScenes()
        self.setupScene(scene: newScene)
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
        return "\(Int(self.x)),\(Int(self.y))"
    }
}






