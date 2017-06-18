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
    var tama: Tamagotchi!
    var tscale: CGFloat!
    var isBeingDragged: Bool!
    var spot: Int!
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
    
    func displayTama() {
        self.addChild(tama)
        tama.position = CGPoint(x: 0, y: -self.size.height/5 )
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
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        
        let image = UIImage(cgImage: (texture?.cgImage())!).resizeImage(scale: size.width/(texture?.size().width)!)
       /* let pixelData: [PixelData] = (image.cgImage!.colors!.1)
        //   print(pixelData.count)
        
        let tamaImg = pixelData.imageFromBitmap(width: Int((image.size.width)), height: Int((image.size.height)))*/
        let texture1 = SKTexture(cgImage: (image.cgImage!))
        super.init(texture: texture1, color: UIColor.white, size:texture1.size())
        self.tscale = size.width/(texture?.size().width)!
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


