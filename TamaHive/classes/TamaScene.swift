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

class TamaScene: SKSpriteNode {
    var id: Int!
    var tama: Tamagotchi!
    
    func displayTama() {
        self.addChild(tama)
    }
    
    func setupGrid() {
        let tamaImage = tama.texture?.cgImage()
        let arrayColors = tamaImage?.colors?.0
        let w = Int((tamaImage?.width)!)
        let h = Int((tamaImage?.height)!)
        var count = 0
        for i in 0...w-1 {
            for j in 0...h-1 {
                let pixel = SKSpriteNode(color: (arrayColors?[count])!, size: CGSize(width: 2, height: 2))
                pixel.position = CGPoint(x: 3*i, y:-3*j )
                //grid[i, j] = pixel
                self.addChild(pixel)
                count += 1
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

