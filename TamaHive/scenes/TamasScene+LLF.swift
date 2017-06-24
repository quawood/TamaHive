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
                tama.tamaName = "egg.png"
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
        tile.strokeColor = tamaScene.color2
        
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
        var newTama = Tamagotchi(textureNamed: (tama.value(forKey: "tamaName") as! String), scale: viewScale)
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
    
    
    func updateTamas() {
        if isBeingDragged == false {
            var count = 0
            var count1 = 0
            tamaViewScenes.forEach({
                if $0.isFakeScene != true {
                    let scene = $0
                    let index = tamaViewScenes!.index(of: scene)
                    let tama = scene.tamagotchis
                    var newAge: Int! = 0
                    
                    tama?.forEach({
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
                                randomTama = "adult,\($0.family!),\($0.gender!)"
                                
                            }
                            if scene.tamagotchis.count == 1 || (scene.tamagotchis.count == 3 && $0.id == 2) {
                                changeTextureOfTama(fromTama: $0, toTama: randomTama)
                            }
                            
                            
                            
                            
                        }
                        $0.age = Int16(newAge)
                        
                        count += 1
                    })
                    let didFail: Bool! = true
                    forScenes: if tama![0].age > 7 && scene.tamagotchis.count == 1 {
                        
                        let onlyTama = tama?.first
                        for scene1 in tamaViewScenes {
                            let xDistance = scene1.position.x - scene.position.x
                            let yDistance = scene1.position.y - scene.position.y
                            
                            checkN: if abs(xDistance) < scene.size.width + 50 && abs(yDistance) < 30 {
                                let rightNeighbor = scene1
                                let rightNeighbortama = rightNeighbor.tamagotchis.first
                                if rightNeighbortama!.age > 7 && rightNeighbortama!.gender != onlyTama?.gender && rightNeighbor.tamagotchis.count == 1 && rightNeighbortama?.generation == onlyTama?.generation {
                                    var MarryButton: FTButtonNode {
                                        let buttonTexture: SKTexture! = SKTexture(imageNamed: "marrybutton.png")
                                        let buttonTextureSelected: SKTexture! = SKTexture(imageNamed: "marrybuttonselected.png")
                                        let button = FTButtonNode(normalTexture: buttonTexture, selectedTexture: buttonTextureSelected, disabledTexture: buttonTexture)
                                        button.action = {
                                            self.changeTextureOfTama(fromTama: onlyTama!, toTama: "parents,\(onlyTama!.family!),\(onlyTama!.gender!)")
                                            self.changeTextureOfTama(fromTama: rightNeighbortama!, toTama: "parents,\(rightNeighbortama!.family!),\(rightNeighbortama!.gender!)")
                                            self.newFamilyScene(scene: scene, tama1: onlyTama!, tama2: rightNeighbortama!, span:"l")
                                        }
                                        button.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(marryTamas(_:)))
                                        button.position = CGPoint(x: scene.size.width/2, y: -scene.size.height/2)
                                        button.zPosition = 15
                                        button.name = "Button"
                                        button.scale(to: CGSize(width: 20 , height: 20))
                                        button.zPosition = 7
                                        
                                        
                                        return button
                                    }
                                    
                                    var containsB: Bool! = false
                                    for child in scene.children {
                                        if let one = child as? FTButtonNode {
                                            containsB = true
                                        }
                                        
                                    }
                                    if containsB == false {
                                        scene.addChild(MarryButton)
                                    }
                                    break forScenes;
                                    
                                }
                                
                            }
                            
                        }
                        if let button = scene.children.first(where: {$0 is FTButtonNode}) {
                            button.removeFromParent()
                        }
                        
                    }
                    let sceneEntity = sceneEntites.first(where: {$0.id == count1})
                    if tama![0].age > 15 && scene.tamagotchis.count == 2 && sceneEntity!.isDone == false{
                        self.view?.isPaused = true
                        let newTama = TamagotchiEntity(context: self.context)
                        newTama.age = 0
                        newTama.generation = tama![0].generation
                        newTama.happiness = 5
                        newTama.hunger = 5
                        newTama.tamaName = "egg.png"
                        newTama.id = 2
                        newTama.gender = tama![Int(arc4random_uniform(2))].gender
                        newTama.family = tama![Int(arc4random_uniform(2))].family
                        let date = Date()
                        newTama.dateCreated = date
                        newTama.tamascene = sceneEntity
                        sceneEntity?.addToTamagotchi(newTama)
                        sceneEntity!.isDone = true
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
                    var childt = Tamagotchi(textureNamed: "egg", scale: viewScale)
                    if let child = $0.tamagotchis.first(where: {$0.id  > 1}) {
                        childt = child
                    }
                    if childt.age > 10 && scene.tamagotchis.count > 2 {
                        saveViewsToEntities()
                        sceneEntites = getScenes()
                        self.view?.isPaused = true
                        let newScene = TamaSceneEntity(context: self.context)
                        newScene.color1 = scene.color1
                        newScene.color2 = scene.color2
                        newScene.span = "n"
                        newScene.spot = CGPoint(x: scene.position.x, y: scene.position.y + scene.size.height + 30).toString()
                        newScene.id = Int16(sceneEntites.count)
                        
                        var newTama = TamagotchiEntity(context: self.context)
                        let tamasPar = sceneEntites.first(where: {$0.id == count1})?.tamagotchi
                        let tamatoDelete = tamasPar?.first(where: {($0 as! TamagotchiEntity).id > 1}) as! TamagotchiEntity
                        deleteTama(tamatoDelete: tamatoDelete)
                        newTama = tamatoDelete
                        newTama.id = 0
                        newTama.generation = tamatoDelete.generation + 1
                        newTama.tamascene = newScene
                        newScene.addToTamagotchi(newTama)
                        
                        
                        
                        (UIApplication.shared.delegate as! AppDelegate).saveContext()
                        sceneEntites = getScenes()
                        self.view?.isPaused = false
                        setupScene(scene: newScene)
                    }
                    
                    
                }
                count1 = count1 + 1
            })
            
            
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touch = touches.first!
        
        
        for i in 0..<tamaViewScenes.count {
            if tamaViewScenes[i].frame.contains((touch.location(in: self.scene!))) {
                
                let scene = tamaViewScenes[i]
                currentTama = scene
                beginPos = currentTama.position
                self.isBeingDragged = true
                touchdx = touch.location(in: self.scene!).x - (currentTama?.position.x)!
                touchdy = touch.location(in: self.scene!).y - (currentTama?.position.y)!
                currentTama.zPosition = CGFloat(maxZposition + 2)
                let flip = SKAction.scale(to: 1.2, duration: 0)
                currentTama.run(flip)
                
                
                break;
                
            }
        }
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
                let indexed = tamaViewScenes.index(of: currentTama)
                deleteTask(atPos: indexed!)
                
                break checkForContains
            }
            var newPoint: CGPoint! = currentTama.position
            let xRange: CountableClosedRange = Int(-currentTama.size.width/2)...Int(self.size.width/2)
            let yRange: CountableClosedRange = Int(-currentTama.size.height/2)...Int(self.size.height/2)
            if !xRange.contains(Int(abs(currentTama.position.x) + currentTama.size.width/2)) {
                newPoint = CGPoint(x: CGFloat(currentTama.position.x.sign())*(self.size.width/2 - currentTama.size.width/2 - 5), y: currentTama.position.y)
            } else if !yRange.contains(Int(abs(currentTama.position.y+currentTama.size.height/2))) {
                newPoint = CGPoint(x: currentTama.position.x, y: CGFloat(currentTama.position.y.sign())*self.size.height/2 - currentTama.size.height/2 - 5)
            }
            let snapBackAction = SKAction.move(to: newPoint, duration: 0.1)
            currentTama.run(snapBackAction)
            let scaleaction = SKAction.scale(to: 1, duration: 0)
            currentTama.run(scaleaction, completion: {
                self.isBeingDragged = false
            })
            maxZposition = Int(currentTama.zPosition)
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
    
    func changeTextureOfTama(fromTama: Tamagotchi, toTama: String) {
        
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





