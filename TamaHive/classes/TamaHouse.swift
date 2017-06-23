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
    var tama: [Tamagotchi]! = []
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
    
    func displayTama() {
        var count = CGFloat(0)
        let k = (self.size.width/2) - 20
        let randomxOffset = -(CGFloat.random() * k)
        tama.forEach({
            if !self.children.contains($0) {
                self.addChild($0)
                $0.position = CGPoint(x: CGFloat(randomxOffset) + (count * ((self.size.width/188) * CGFloat(130/tama.count))), y: -(self.size.height/2) + 40)
                $0.zPosition = 1
                
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


