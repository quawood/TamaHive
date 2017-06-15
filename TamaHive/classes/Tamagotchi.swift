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
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let image = UIImage(cgImage: (texture?.cgImage())!).resizeImage(scale: 5)
        let pixelData: [PixelData] = (image.cgImage!.colors!.1)
     //   print(pixelData.count)
        
        let tamaImg = pixelData.imageFromBitmap(width: Int((image.size.width)), height: Int((image.size.height)))
        let texture1 = SKTexture(cgImage: (tamaImg?.cgImage!)!)
        super.init(texture: texture1, color: UIColor.white, size:image.size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
}

