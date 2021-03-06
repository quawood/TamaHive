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
    
    /** CORE DATA **/
    func getScenes() -> [TamaSceneEntity] {
        var entities: [TamaSceneEntity]! = []
        do {
            entities = try context.fetch(TamaSceneEntity.fetchRequest())
        }catch {
            print("Error fetching data from CoreData")
        }
        return entities
    }
    
    
    func deleteTama(tamatoDelete: TamagotchiEntity) {
        let sceneEntity = sceneEntites.first(where: {($0.tamagotchi as! Set<TamagotchiEntity>).contains(tamatoDelete)})
        let index = Int(sceneEntity!.id)
        
        sceneEntity?.removeFromTamagotchi(tamatoDelete)
        tamaViewScenes[index].tamagotchis.first(where:{$0.id > 1})?.removeFromParent()
        tamaViewScenes[index].tamagotchis.remove(at: tamaViewScenes[index].tamagotchis.index(where: {$0.id > 1})!)
        save()
        sceneEntites = getScenes()
    }
    
    
    
    func deleteScene(scene: TamaHouse) {
        let atPos = tamaViewScenes.index(of: scene)!.advanced(by: 0)
        let request = NSFetchRequest<TamaSceneEntity>(entityName: "TamaSceneEntity")
        var sceneIDs = [Int16]()
        do {
            let searchResults = try self.context.fetch(request)
            sceneIDs = searchResults.map( {$0.id})
            self.context.delete(searchResults[sceneIDs.index(where: {$0 == Int16(atPos)})!])
            if let slInd = UserDefaults(suiteName: "group.Anjour.TamaHive")!.object(forKey: "spotlightInd") as? Int {
                if slInd == atPos {
                    UserDefaults(suiteName: "group.Anjour.TamaHive")!.set(nil, forKey: "spotlightInd")
                }
                
            }
            
        } catch {
            print("Error with request: \(error)")
        }
        
        tamaViewScenes[atPos].removeFromParent()
        tamaViewScenes.remove(at: atPos)
        
        save()
        
        
        sceneEntites = getScenes()
        sceneIDs = sceneEntites.map( {$0.id})
        for i in 0..<sceneIDs.count {
            if sceneIDs[i] > atPos {
                let sceneIndex = sceneEntites.index(where: {$0.id == Int16(sceneIDs[i])})
                sceneEntites[sceneIndex!].id = sceneEntites[sceneIndex!].id - 1
                
            }
        }
        save()
        sceneEntites = getScenes()
        
        
    }
    
    
    func save() {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("\(nserror.localizedDescription)")
            } 
    }
    
    
    func saveViewsToEntities() {
        for i in 0..<sceneEntites.count {
                var temp: TamaHouse!
                    temp = tamaViewScenes[i]
                
                let index = sceneEntites.index(where: { $0.id == i})
                    sceneEntites[index!].spot = temp.position.toString()
                
                
                
                sceneEntites[index!].tamagotchi?.forEach({
                    let tama = $0 as! TamagotchiEntity
                    let modelTama = temp.tamagotchis.first(where: {$0.id == tama.id})
                    tama.age = (modelTama?.age!)!
                    tama.tamaName = modelTama?.tamaName
                })
            
        }
        
        save()
        TAttributes.sceneEntites = sceneEntites
    }
    
    
    
    

    
    @objc func createNewSceneEntity(_ sender: FTButtonNode?) {
        if !isEditing {
            sender?.removeFromParent()
        }
        DispatchQueue.main.async {
            if self.sceneEntites.count < TAttributes.maxTamas {
                
                let scene = TamaSceneEntity(context:self.context)
                scene.id = Int16(self.sceneEntites.count)
                scene.color1 = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
                scene.color2 = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
                scene.span = "n"
                scene.spot = (self.sceneRects.rowedIndex(self.sceneEntites.count).0 as! CGRect).origin.toString()
                let tama = TamagotchiEntity(context: self.context)
                let genders = ["m","f"]
                let date = Date()
                let randomFam = Int(arc4random_uniform(UInt32(TAttributes.familyNames.count)))
                
                scene.dateCreated = date
                let sets = self.sceneEntites.map({$0.tamagotchi})
                let generations = sets.map({Int((($0 as! Set<TamagotchiEntity>).first)!.generation)})

                    tama.generation = Int16(Int(generations.average))
                    
                tama.tamaName = "egg.png"
                tama.id = 0
                let gender = genders[Int(arc4random_uniform(2))]
                tama.gender = gender
                let randomInd = arc4random_uniform(5)
                let temp = Int(randomInd)
                
                tama.cycle = self.generateCycle(gender: gender, family: TAttributes.familyNames[randomFam]) as NSObject
                tama.family = TAttributes.familyNames[randomFam]
                tama.dateCreated = date
                tama.tamascene = scene
                scene.addToTamagotchi(tama)
                self.save()
                self.sceneEntites = self.getScenes()
                self.setupScene(scene: scene)
                self.updateTamas()
            }
        }
        
    }
    
    func generateCycle(gender: String, family: String) -> [String] {
        var cycles:[String] = []
        cycles.append(self.generateRandomTama(1, appendingPC: "\(TAttributes.forms[0])")[0])
        for i in 1..<3 {
            let appendString = "\(TAttributes.forms[i]),\(gender)"
            let tamaS = self.generateRandomTama(1, appendingPC: appendString)[0]
            cycles.append(tamaS)
        }
        for i in 3..<5 {
            let appendString = "\(TAttributes.forms[i]),\(family),\(gender)"
            let tamaS = self.generateRandomTama(1, appendingPC: appendString)[0]
            cycles.append(tamaS)
        }
        
        return cycles
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
        newTama.dateCreated = tama.dateCreated
        newTama.cycle = tama.cycle as! [String]
        return newTama
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
        tamaScene.dateCreated = scene.dateCreated
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touch = touches.first!
        let touchLocation = touch.location(in: self)
        
        top: for i in 0..<tamaViewScenes.count {
            if tamaViewScenes[i].frame.contains(touchLocation) {
                currentTama = tamaViewScenes[i]
                beginPos = currentTama.position
                currentTama.zPosition = CGFloat(maxZposition + 2)
                touchdx = touchLocation.x - (currentTama?.position.x)!
                touchdy = touchLocation.y - (currentTama?.position.y)!
                if isEditing == true  {
                    
                    
                    
                    let scale = SKAction.scale(to: 1.2, duration: 0)
                    currentTama.run(scale)
                    
                } else {
                    let colorizeAction = SKAction.colorize(with: UIColor.gray, colorBlendFactor: 0.8, duration: 0)
                    currentTama.run(colorizeAction)
                    counting = true
                    timeSincePress = 0
                    
                    
                }
                break top;
                
                
            }
        }
        guard (currentTama) != nil else{
            if isEditing {
                isEditing = false
                self.childNode(withName: "trashB")?.removeFromParent()
                self.childNode(withName: "SpotlightB")?.removeFromParent()
                if tamaViewScenes.count > 0 {
                    self.childNode(withName: "CreateB")?.removeFromParent()
                }
                
                cancelPrepare()
                
            }
            return
        }
        
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, currentTama != nil {
            let location = touch.location(in: self)
            if isEditing {
                currentTama.position = CGPoint(x: location.x - touchdx, y: location.y - touchdy)
            }
            if counting {
                if !currentTama.frame.contains(location) {
                    cancelPrepare()
                    currentTama.run(uncolorizeAction)
                }
                
            }
            
            
        }
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, currentTama != nil {
            let location = touch.location(in: self)
            if isEditing {
                if trashPlace.frame.contains(location) {
                    deleteScene(scene: currentTama)
                } else if spotlightPlace.frame.contains(location) {
                    let index = tamaViewScenes.index(of: currentTama)
                    UserDefaults(suiteName: "group.Anjour.TamaHive")!.set(index!, forKey: "spotlightInd")
                    
                    let snapBackAction = SKAction.move(to: beginPos, duration: 0.1)
                    let scaledownAction = SKAction.scale(to: 1, duration: 0)
                    currentTama.run(snapBackAction)
                    currentTama.run(scaledownAction)
                } else {
                    var newPoint: CGPoint! = currentTama.position
                    let xRange: CountableClosedRange = Int(-self.size.width/2)...Int(self.size.width/2)
                    let yRange: CountableClosedRange = Int((-self.size.height/2)+49)...Int(self.size.height/2)
                    if !xRange.contains(Int(abs(currentTama.position.x) + currentTama.size.width/2)) {
                        newPoint = CGPoint(x: CGFloat(currentTama.position.x.sign())*(self.size.width/2 - currentTama.size.width/2 - 5), y: currentTama.position.y)
                    }
                    if !yRange.contains(Int(currentTama.position.y + CGFloat(currentTama.position.y.sign())*(currentTama.size.height/2))) {
                        switch currentTama.position.y.sign() {
                        case 1:
                            newPoint = CGPoint(x: currentTama.position.x, y:  (CGFloat(yRange.upperBound) - currentTama.size.height/2 - 5))
                        case -1:
                            newPoint = CGPoint(x: currentTama.position.x, y:  sceneRects[4][0].origin.y)
                        default:
                            break
                        }
                        
                    }
                    let snapBackAction = SKAction.move(to: newPoint, duration: 0.1)
                    currentTama.run(snapBackAction)
                    let scaleaction = SKAction.scale(to: 1, duration: 0)
                    currentTama.run(scaleaction, completion: {
                        self.updateTamas()
                    })
                    
                    maxZposition = Int(currentTama.zPosition)
                }
            } else {
                currentTama.run(uncolorizeAction)
                cancelPrepare()
            }
        }
        
            
        currentTama = nil
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func initEditingMode() {
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
    
    
    func cancelPrepare() {
        counting = false
        timeSincePress = 0
    }
    
 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    @objc func FTbuttonAction(_ sender: Any) {
        if let button1 = sender as? FTButtonNode {
            button1.action()
            button1.removeFromParent()
        }
    }
    
    
    func updateTamas() {
        sceneEntites = getScenes()
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
                        
                        checkForMarriage: if firstTama.age > TAttributes.marriageAge && tamagotchis!.count == 1 {
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
                            for child in scene.children {
                                if child is FTButtonNode {
                                    child.removeFromParent()
                                }
                                
                            }
                            
                        }
                        if tamagotchis![0].age > TAttributes.childAge && scene.tamagotchis.count == 2 && sceneEntity!.isDone == false {
                            let date = Date()
                            let newAge = date.interval(ofComponent: TAttributes.tunit, fromDate:scene.dateCreated)/2*TAttributes.tint
                            if newAge >= 2 {
                                addTamagotchiChild(scene: scene, sceneEntity: sceneEntity!)
                            }
                            
                        }
                        if childTamagotchi.age > TAttributes.leaveAge && scene.tamagotchis.count > 2 {
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
        let date = Date()
        newscene.dateCreated = date
        
        let index1 = tamaViewScenes.index(of: tamaViewScenes.first(where: {$0.tamagotchis.first! == tama1})!)
        var index2 = tamaViewScenes.index(of: tamaViewScenes.first(where: {$0.tamagotchis.first! == tama2})!)
        var newtama1 = TamagotchiEntity(context:self.context)
        var newtama2 = TamagotchiEntity(context:self.context)
        newtama1 = sceneEntites!.first(where: {$0.id == tamaViewScenes.startIndex.distance(to: index1!)})?.tamagotchi?.first(where: {_ in true}) as! TamagotchiEntity
        newtama2 = sceneEntites!.first(where: {$0.id == tamaViewScenes.startIndex.distance(to: index2!)})?.tamagotchi?.first(where: {_ in true}) as! TamagotchiEntity
        newtama2.id = 1
        newscene.addToTamagotchi(newtama1)
        newscene.addToTamagotchi(newtama2)
        
        save()
        sceneEntites = getScenes()
        deleteScene(scene: tamaViewScenes[index1!])
        index2 = tamaViewScenes.index(of: tamaViewScenes.first(where: {$0.tamagotchis.first! == tama2})!)
        deleteScene(scene: tamaViewScenes[index2!])
        
        
        setupScene(scene: newscene)
        print(newscene.id)
    }
    
    func updateTamagotchiTexture(fromTama: Tamagotchi) {
        let date = Date()
        let newAge = date.interval(ofComponent: TAttributes.tunit, fromDate:fromTama.dateCreated)/TAttributes.tint
        if Int16(newAge) != fromTama.age {
            var newTexture:String?
            switch newAge {
            case 1:
                newTexture = (fromTama.cycle)[0]
            case 2 :
                newTexture = (fromTama.cycle)[1]
                
            case 3:
                newTexture = (fromTama.cycle )[2]
                
            default:
                newTexture = (fromTama.cycle)[3]
                
            }
            let parent = fromTama.parent as! TamaHouse
            if parent.tamagotchis.count == 1 || fromTama.id == 2 {
                changeTamagotchiTexture(fromTama: fromTama, toTama: newTexture!)
            }
            
            
            
            
            
        }
        
        fromTama.age = Int16(newAge)
    }
    func updateTmamagotchiMarriage(scene: TamaHouse, rNeighbor: TamaHouse) {
        
        
        let firstTama = scene.tamagotchis.first!
        let rNeighbortama = rNeighbor.tamagotchis.first
        if rNeighbortama!.age > TAttributes.marriageAge && rNeighbortama!.gender != firstTama.gender && rNeighbor.tamagotchis.count == 1 && firstTama.generation == rNeighbortama?.generation{
            
            let buttonTexture: SKTexture! = SKTexture(imageNamed: "marrybutton.png")
            let buttonTextureSelected: SKTexture! = SKTexture(imageNamed: "marrybuttonselected.png")
            let marrybutton = FTButtonNode(defaultTexture: buttonTexture, selectedTexture: buttonTextureSelected, action: {
                
                self.newFamilyScene(scene: scene, tama1: firstTama, tama2: rNeighbortama!, span:"l")
                
            })
            marrybutton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(FTbuttonAction(_:)))
            marrybutton.position = CGPoint(x: scene.size.width/2, y: -scene.size.height/2)
            marrybutton.name = "marryB"
            
            
            var hasB = false
            for child in scene.children {
                if child is FTButtonNode {
                    hasB = true
                    
                }
                
            }
            if hasB {
                (scene.childNode(withName: "marryB") as! FTButtonNode).action = marrybutton.action
            } else {
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
        
        var hasB: Bool! = false
        for child in scene.children {
            if child is FTButtonNode {
                hasB = true
            }
            
        }
        if tamaViewScenes.count < TAttributes.maxTamas && !hasB{
            scene.addChild(leavebutton)
            leavebutton.zPosition = 1
        }
        
    }
    
    func addTamagotchiChild(scene: TamaHouse, sceneEntity: TamaSceneEntity) {
        let gender = scene.tamagotchis![Int(arc4random_uniform(2))].gender
        let family = scene.tamagotchis![Int(arc4random_uniform(2))].family
        
        let newTama = TamagotchiEntity(context: self.context)
        newTama.generation = scene.tamagotchis![0].generation
        newTama.tamaName = "egg.png"
        newTama.id = 2
        
        newTama.gender = gender
        newTama.family = family
        newTama.cycle = generateCycle(gender: gender!, family: family!) as NSObject
        let date = Date()
        newTama.dateCreated = date
        newTama.tamascene = sceneEntity
        sceneEntity.addToTamagotchi(newTama)
        sceneEntity.isDone = true
        save()
        sceneEntites = getScenes()
        for tamagotchi in scene.tamagotchis {
            self.changeTamagotchiTexture(fromTama: tamagotchi, toTama: tamagotchi.cycle[4])
        }
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
        let date = Date()
        newScene.dateCreated = date
        
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
        
        
        
        save()
        self.sceneEntites = self.getScenes()
        self.setupScene(scene: newScene)
        newScene.addToTamagotchi(newTama)
        
        
    }
    
    func changeTamagotchiTexture(fromTama: Tamagotchi, toTama: String) {
        let index = tamaViewScenes.index(where: {$0.tamagotchis.contains(fromTama)})
        let i = tamaViewScenes[index!]
        var correspondingEntity: TamaSceneEntity!
            correspondingEntity = sceneEntites.first(where: {$0.id == tamaViewScenes.startIndex.distance(to: index!)})
        
        let tama = i.tamagotchis.first(where: {$0.id == fromTama.id})
        let tamaEntity = correspondingEntity?.tamagotchi?.first(where: {($0 as! TamagotchiEntity).id == fromTama.id}) as! TamagotchiEntity
        tama?.tamaName = toTama
        tamaEntity.tamaName = tama?.tamaName
        let image = UIImage(named: (toTama))?.resizeImage(scale: CGFloat(viewScale))
        tama?.texture = SKTexture(cgImage: (image?.cgImage)!)
        tama?.size = (tama?.texture?.size())!
        save()
        sceneEntites = getScenes()
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
        appDelegate.mpcManager.browser.stopBrowsingForPeers()
    }
    @objc func appWillEnterForeground() {
        context = CoreDataStack.sharedInstance.managedObjectContext
        updateTamas()
        
    }
    
    
    
    
    
    
}


class FTButtonNode: SKSpriteNode {
    var action: () -> () = {}
    enum FTButtonActionType: Int {
        case TouchUpInside = 1,
        TouchDown, TouchUp
    }
    
    var isEnabled: Bool = true {
        didSet {
            if (disabledTexture != nil) {
                texture = isEnabled ? defaultTexture : disabledTexture
            }
        }
    }
    var isSelected: Bool = false {
        didSet {
            texture = isSelected ? selectedTexture : defaultTexture
        }
    }
    
    var defaultTexture: SKTexture
    var selectedTexture: SKTexture
    var label: SKLabelNode
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    init(defaultTexture: SKTexture!, selectedTexture: SKTexture!, action: @escaping ()->()) {
        self.defaultTexture = defaultTexture
        self.selectedTexture = selectedTexture
        self.action = action
        self.label = SKLabelNode(fontNamed: "Helvetica")
        
        super.init(texture: defaultTexture, color: UIColor.white, size: defaultTexture.size())
        isUserInteractionEnabled = true
        self.zPosition = 15
        self.name = "Button"
        self.scale(to: CGSize(width: 20 , height: 20))
    }
    
    init(normalTexture defaultTexture: SKTexture!, selectedTexture:SKTexture!, disabledTexture: SKTexture?) {
        
        self.defaultTexture = defaultTexture
        self.selectedTexture = selectedTexture
        self.disabledTexture = disabledTexture
        self.label = SKLabelNode(fontNamed: "Helvetica");
        
        super.init(texture: defaultTexture, color: UIColor.white, size: defaultTexture.size())
        isUserInteractionEnabled = true
        
        //Creating and adding a blank label, centered on the button
        self.label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center;
        self.label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center;
        addChild(self.label)
        
        // Adding this node as an empty layer. Without it the touch functions are not being called
        // The reason for this is unknown when this was implemented...?
        let bugFixLayerNode = SKSpriteNode(texture: nil, color: UIColor.clear, size: defaultTexture.size())
        bugFixLayerNode.position = self.position
        addChild(bugFixLayerNode)
        
    }
    
    /**
     * Taking a target object and adding an action that is triggered by a button event.
     */
    func setButtonAction(target: AnyObject, triggerEvent event:FTButtonActionType, action:Selector) {
        
        switch (event) {
        case .TouchUpInside:
            targetTouchUpInside = target
            actionTouchUpInside = action
        case .TouchDown:
            targetTouchDown = target
            actionTouchDown = action
        case .TouchUp:
            targetTouchUp = target
            actionTouchUp = action
        }
        
    }
    
    /*
     New function for setting text. Calling function multiple times does
     not create a ton of new labels, just updates existing label.
     You can set the title, font type and font size with this function
     */
    
    func setButtonLabel(title: NSString, font: String, fontSize: CGFloat) {
        self.label.text = title as String
        self.label.fontSize = fontSize
        self.label.fontName = font
    }
    
    var disabledTexture: SKTexture?
    var actionTouchUpInside: Selector?
    var actionTouchUp: Selector?
    var actionTouchDown: Selector?
    weak var targetTouchUpInside: AnyObject?
    weak var targetTouchUp: AnyObject?
    weak var targetTouchDown: AnyObject?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!isEnabled) {
            return
        }
        isSelected = true
        if (targetTouchDown != nil && targetTouchDown!.responds(to: actionTouchDown)) {
            UIApplication.shared.sendAction(actionTouchDown!, to: targetTouchDown, from: self, for: nil)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (!isEnabled) {
            return
        }
        
        let touch: AnyObject! = touches.first
        let touchLocation = touch.location(in: parent!)
        
        if (frame.contains(touchLocation)) {
            isSelected = true
        } else {
            isSelected = false
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!isEnabled) {
            return
        }
        
        isSelected = false
        
        if (targetTouchUpInside != nil && targetTouchUpInside!.responds(to: actionTouchUpInside!)) {
            let touch: AnyObject! = touches.first
            let touchLocation = touch.location(in: parent!)
            
            if (frame.contains(touchLocation) ) {
                UIApplication.shared.sendAction(actionTouchUpInside!, to: targetTouchUpInside, from: self, for: nil)
            }
            
        }
        
        if (targetTouchUp != nil && targetTouchUp!.responds(to: actionTouchUp!)) {
            UIApplication.shared.sendAction(actionTouchUp!, to: targetTouchUp, from: self, for: nil)
        }
    }
    
}









