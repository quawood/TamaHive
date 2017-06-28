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
    var tamagotchis: [UIImageView] {
        var array: [UIImageView]? = []
        for view in sceneView.subviews {
            if let imageV = view as? UIImageView {
                if imageV.tag != 10 {
                    array?.append(imageV)
                }
            }
        }
        return array!
    }
    
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
        for item in tamagotchis {
                let imageview = item
                let randomdir = Int(arc4random_uniform(3)) - 1
                var testRandom = randomdir
                if randomdir == 0 {
                    testRandom = Int(arc4random_uniform(2))
                    testRandom = (2*testRandom) - 1
                }
                
                
                imageview.transform = CGAffineTransform.init(scaleX: CGFloat((-testRandom)), y: 1)
                let parentScene = sceneView
                let pWidth = parentScene?.frame.size.width
                let nextPos = CGPoint(x: CGFloat(randomdir)*(pWidth!/CGFloat(35*(currentScene.tamagotchi?.count)!))+imageview.center.x, y: imageview.center.y)
                if abs(nextPos.x) < abs((pWidth)!){
                    imageview.center = nextPos
                    
                }
                
                
                
                
                let date = Date()
                let correspondingTama = currentScene.tamagotchi?.first(where: {($0 as! TamagotchiEntity).id == Int16(imageview.tag)}) as! TamagotchiEntity
                let newAge = date.interval(ofComponent: TAttributes.tunit, fromDate:correspondingTama.dateCreated!)/TAttributes.tint
                
                
                if Int16(newAge) != correspondingTama.age {
                    var newTexture:String?
                    switch newAge {
                    case 1:
                        newTexture = (correspondingTama.cycle as! [String])[0]
                    case 2 :
                        newTexture = (correspondingTama.cycle as! [String])[1]
                        
                    case 3:
                        newTexture = (correspondingTama.cycle as! [String])[2]
                        
                    default:
                        newTexture = (correspondingTama.cycle as! [String])[3]
                        
                    }
                    if currentScene.tamagotchi?.count == 1 || correspondingTama.id == 2 {
                        imageview.image = UIImage(named: newTexture!)?.resizeImage(scale: 2)
                        correspondingTama.tamaName = newTexture
                        save()
                        
                    }
                    
                    
                    
                }
                var subviewsToAdd: [UIImageView]! = []
                    if newAge > TAttributes.marriageAge && currentScene.tamagotchi?.count == 1 {
                        
                        let marriageMedal = UIImage(named: "marrybutton")?.resizeImage(scale: 1)
                        let medalImageView = UIImageView(image: marriageMedal)
                        medalImageView.layer.zPosition = 1
                        medalImageView.tag = 10
                        
                        subviewsToAdd.append(medalImageView)
                        
                        
                    }
                    if let childTama = currentScene.tamagotchi?.first(where: {($0 as! TamagotchiEntity).id == 2}) as? TamagotchiEntity {
                        if childTama.age > TAttributes.leaveAge {
                            let leaveMedal = UIImage(named: "leavebutton")?.resizeImage(scale: 1)
                            let medalImageView = UIImageView(image: leaveMedal)
                            medalImageView.layer.zPosition = 1
                            medalImageView.tag = 10
                            
                            subviewsToAdd.append(medalImageView)
                        }
                    }
                
                if ((currentScene.tamagotchi?.first(where: {($0 as! TamagotchiEntity).id == 0}) as? TamagotchiEntity)?.age)! > Int16(TAttributes.childAge) && currentScene.tamagotchi?.count == 2 && currentScene!.isDone == false {
                    let date = Date()
                    let newAge = date.interval(ofComponent: TAttributes.tunit, fromDate:currentScene.dateCreated!)/2*TAttributes.tint
                    if newAge >= 2 {
                        let leaveMedal = UIImage(named: "childbutton")?.resizeImage(scale: 1)
                        let medalImageView = UIImageView(image: leaveMedal)
                        medalImageView.layer.zPosition = 1
                        medalImageView.tag = 10
                        if imageview.tag != 2 {
                            let t = currentScene.tamagotchi?.first(where: {($0 as! TamagotchiEntity).id == imageview.tag}) as? TamagotchiEntity
                            let tString = (t?.cycle as! [String])[4]
                            t?.tamaName = tString
                            imageview.image = UIImage(named: tString)?.resizeImage(scale: 2)
                            subviewsToAdd.append(medalImageView)
                        }
                        
                    }
                    
                }
                
                
                
                for i in 0..<subviewsToAdd.count{
                    subviewsToAdd[i].frame.origin = CGPoint(x: self.view.frame.size.width - 60*CGFloat(i+1), y: 0 + 10)
                    
                   var alreadyInSub: Bool! = false
                    for view in sceneView.subviews {
                        if let img = view as? UIImageView {
                            if img.image == subviewsToAdd[i].image {
                                alreadyInSub = true
                            }
                        }
                    }
                    if !alreadyInSub {
                        sceneView.addSubview(subviewsToAdd[i])
                  }
                    
                }
                
                correspondingTama.age = Int16(newAge)
                save()
            }
            
        
        
    }
}
