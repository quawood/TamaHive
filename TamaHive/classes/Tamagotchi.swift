//
//  Tamagotchi.swift
//  TamaHive
//
//  Created by Qualan Woodard on 6/12/17.
//  Copyright  2017 Qualan Woodard. All rights reserved.
//

import UIKit
import GameKit
import SpriteKit
class Tamagotchi: SKSpriteNode {
    var hunger: Int = 5
    var happiness: Int = 5
    var age: Int = 0
    var generation: Int = 1
    var tamaName: String!
    var tscale: CGFloat = 1
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let image = UIImage(cgImage: (texture?.cgImage())!).resizeImage(scale: size.width/(texture?.size().width)!)
        let pixelData: [PixelData] = (image.cgImage!.colors!.1)
     //   print(pixelData.count)
        
        let tamaImg = pixelData.imageFromBitmap(width: Int((image.size.width)), height: Int((image.size.height)))
        let texture1 = SKTexture(cgImage: (tamaImg?.cgImage!)!)
        super.init(texture: texture1, color: UIColor.white, size:texture1.size())
        self.tscale = size.width/(texture?.size().width)!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func move() {
      let randomdir = Int(arc4random_uniform(3)) - 1
        var testRandom = randomdir
        if randomdir == 0 {
            testRandom = Int(arc4random_uniform(2))
            testRandom = (2*testRandom) - 1
        }
        let flip = SKAction.scaleX(to: CGFloat(-testRandom), duration: 0)
        self.run(flip)
        
        let nextPos = CGPoint(x: CGFloat((randomdir) * Int(tscale) * 3 ) + self.position.x, y: self.position.y)
        if abs(nextPos.x) < abs((self.parent?.scene?.size.width)!/3 - 30) {
            self.position = nextPos
        }
        
    }
    
    
    
    
}

