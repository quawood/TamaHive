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
    
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let texture = texture
        super.init(texture: texture, color: color, size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

