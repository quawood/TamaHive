//
//  Today+LLF.swift
//  TamaWidget
//
//  Created by Qualan Woodard on 6/26/17.
//  Copyright © 2017 Qualan Woodard. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
extension TodayViewController {
    func setupTamagotchis() {
        
        sceneView.backgroundColor = currentScene.color1 as? UIColor
        //sceneView.layer.cornerRadius = 7
        
        let xOffset = (sceneView.frame.size.width/CGFloat((currentScene.tamagotchi?.count)! + 1))
        var count = CGFloat(1)
        
        for tamagotchi in (currentScene.tamagotchi as! Set<TamagotchiEntity>) {
            let tamagotchiImage = UIImage(named: tamagotchi.tamaName!)?.resizeImage(scale: 2)
            let imageView = UIImageView(image: tamagotchiImage)
            imageView.frame.size = (tamagotchiImage?.size)!
            
            let setPoint = CGPoint(x:(count * xOffset) - (imageView.frame.size.width/2) , y: 60)
            imageView.center = setPoint
            imageView.tag = Int(tamagotchi.id)
            sceneView.addSubview(imageView)
            sceneView.layer.zPosition = 1
            
            count = count + 1
        }
    }
    
    func giveHunger() {
        var count = 0
        for tamagotchi in (currentScene.tamagotchi as? Set<TamagotchiEntity>)! {
            let xOffset = (hungerView.frame.size.width/6) - 7
            for i in 0..<TAttributes.maxHealth {
                var imageView: UIImageView!
                if i <= tamagotchi.hunger {
                    let fullheartImage = UIImage(named: "heartfull")?.resizeImage(scale: 3)
                    imageView = UIImageView(image: fullheartImage)
                } else {
                    let emptyheartImage = UIImage(named: "heartempty")?.resizeImage(scale: 3)
                    imageView = UIImageView(image: emptyheartImage)
                }
                imageView.frame.origin = CGPoint(x: CGFloat(i) * xOffset + 2, y: 2)
                hungerView.addSubview(imageView)
                imageView.layer.zPosition = 1
            }
        }
    }
    
    @objc func updateTamagotchis(_ sender: Any?) {
        for item in sceneView.subviews {
            if let imageview = item as? UIImageView {
                
                let randomdir = Int(arc4random_uniform(3)) - 1
                var testRandom = randomdir
                if randomdir == 0 {
                    testRandom = Int(arc4random_uniform(2))
                    testRandom = (2*testRandom) - 1
                }
                
                
                imageview.transform = CGAffineTransform.init(scaleX: CGFloat((testRandom)), y: 1)
                let parentScene = sceneView
                let pWidth = parentScene?.frame.size.width
                let nextPos = CGPoint(x: CGFloat(randomdir)*(pWidth!/CGFloat(25*(currentScene.tamagotchi?.count)!))+imageview.center.x, y: imageview.center.y)
                if abs(nextPos.x) < abs((pWidth)!){
                    imageview.center = nextPos
                    
                }
                
                
                
                
                let date = Date()
                let correspondingTama = currentScene.tamagotchi?.first(where: {($0 as! TamagotchiEntity).id == Int16(imageview.tag)}) as! TamagotchiEntity
                print(correspondingTama)
                let newAge = date.interval(ofComponent: TAttributes.tunit, fromDate:correspondingTama.dateCreated!)/TAttributes.tint
                
                
                if Int16(newAge) != correspondingTama.age && (correspondingTama.age) < 4  {
                    var randomTama = String()
                    switch newAge {
                    case 1:
                        randomTama = "baby"
                    case 2 :
                        randomTama = "toddler,\(correspondingTama.gender!)"
                    case 3:
                        randomTama = "teen,\(correspondingTama.gender!)"
                        
                    default:
                        randomTama = "adult,\(correspondingTama.family!),\(correspondingTama.gender!)"
                    }
                    let parent = sceneView
                    if currentScene.tamagotchi?.count == 1 || (parent?.subviews.count == 3 && correspondingTama.id == 2) {
                        let tamaImg = TAttributes.generateRandomTama(1, appendingPC: randomTama)[0]
                        imageview.image = UIImage(named: tamaImg)?.resizeImage(scale: 2)
                        print("here")
                        correspondingTama.tamaName = tamaImg
                        save()
                    }
                    
                    
                    
                    
                }
                if newAge > TAttributes.marriageAge && currentScene.tamagotchi?.count == 1 {
                    let marriageMedal = UIImage(named: "marrybutton")?.resizeImage(scale: 1)
                    let medalImageView = UIImageView(image: marriageMedal)
                    medalImageView.layer.zPosition = 1
                    medalImageView.frame.origin = CGPoint(x: self.view.frame.size.width - 40, y: 0 + 10)
                    
                    self.view.addSubview(medalImageView)
                    
                }
                if let childTama = currentScene.tamagotchi?.first(where: {($0 as! TamagotchiEntity).id == 2}) as? TamagotchiEntity {
                    if childTama.age > TAttributes.leaveAge {
                        let leaveMedal = UIImage(named: "leavebutton")?.resizeImage(scale: 0.5)
                        let medalImageView = UIImageView(image: leaveMedal)
                        medalImageView.layer.zPosition = 1
                        medalImageView.frame.origin = CGPoint(x: self.view.frame.size.width - 10, y: 0 + 2)
                        
                        self.view.addSubview(medalImageView)
                    }
                }
                
                correspondingTama.age = Int16(newAge)
                save()
            }
            
            
            
            
            
        }
        
        
    }
}
