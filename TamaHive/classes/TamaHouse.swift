//
//  TamaScene.swift
//  TamaHive
//
//  Created by Qualan Woodard on 6/12/17.
//  Copyright  2017 Qualan Woodard. All rights reserved.
//

import UIKit
import GameKit
import SpriteKit

class TamaHouse: SKSpriteNode {
    var tamagotchis: [Tamagotchi]! = []
    var tscale: CGFloat!
    var isBeingDragged: Bool!
    var span: String! = "n"
    var isFakeScene:Bool! = false
    var color1: UIColor! = UIColor.white {
        didSet {
            let newCols = changeColors(from: oldValue, to: color1)
            let image = newCols.imageFromBitmap(width: Int((self.texture?.size().width)!), height: Int((self.texture?.size().height)!))?.cgImage!
            self.texture = SKTexture(cgImage: image!)
            
        }
    }
    var color2: UIColor! = UIColor.black{
        didSet {
            let newCols = changeColors(from: oldValue, to: color2)
            let image = newCols.imageFromBitmap(width: Int((self.texture?.size().width)!), height: Int((self.texture?.size().height)!))?.cgImage!
            self.texture = SKTexture(cgImage: image!)
        }
    }
    
    
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        
        let image = UIImage(cgImage: (texture?.cgImage())!).resizeImage(scale: size.width/(texture?.size().width)!)
        let texture1 = SKTexture(cgImage: (image.cgImage!))
        super.init(texture: texture1, color: UIColor.white, size:texture1.size())
        self.tscale = size.width/(texture?.size().width)!
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func displayTamagotchis() {
        var count = 0
        tamagotchis.forEach({tamagotchi in
            if !self.children.contains(tamagotchi) {
                self.addChild(tamagotchi)
                let xOffset = (self.size.width/CGFloat(tamagotchis.count+1))
                let setPoint = CGPoint(x:(-self.size.width/2) + xOffset , y: (-self.size.height/2)+(0.27 * self.size.height))
                tamagotchi.position = setPoint
                tamagotchi.zPosition = 1
                
            }
            count = count + 1
        })
    }
    
    
    
    func changeColors(from: UIColor, to: UIColor) -> [PixelData] {
        var colors = self.texture?.cgImage().colors?.1
        for i in 0..<colors!.count {
            if colors![i] == PixelData(color: from) {
                colors![i] = PixelData(color: to)
                
            }
        }
        return colors!
    }
    
    
    
}


