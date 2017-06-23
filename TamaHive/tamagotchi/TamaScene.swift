//
//  TamaScene.swift
//  TamaHive
//
//  Created by Qualan Woodard on 6/12/17.
//  Copyright © 2017 Qualan Woodard. All rights reserved.
//

import UIKit
import GameKit
import SpriteKit

class TamaScene: SKSpriteNode {
    var id: Int!
    var tama: Tamagotchi!
    
    func displayTama() {
        self.addChild(tama)
    }
    func testTame() {
        let pixels = tama.texture?.cgImage().colors?.1
        let width = Int((tama.texture?.size().width)!)
        let height = Int((tama.texture?.size().height)!)
        for w in 0..<width {
            for h in 0..<height{
                let index = ((w*height) + h)
                let pixel = SKSpriteNode(color:UIColor(red: CGFloat(pixels![index].r)/255, green: CGFloat(pixels![index].g)/255, blue: CGFloat(pixels![index].b)/255, alpha: CGFloat(pixels![index].a)/255), size: CGSize(width: CGFloat(width), height: CGFloat(height)))
                pixel.position = CGPoint(x: w, y: -h)
                self.addChild(pixel)
                
            }
        }
    }
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let texture = texture
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
