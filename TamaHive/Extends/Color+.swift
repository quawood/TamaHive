//
//  Color+.swift
//  TamaHive
//
//  Created by Qualan Woodard on 6/28/17.
//  Copyright © 2017 Qualan Woodard. All rights reserved.
//

import Foundation
import UIKit
import GameKit
import SpriteKit


extension UIColor {
    convenience init(pixelData: PixelData) {
        self.init(red: CGFloat(pixelData.r/255), green: CGFloat(pixelData.g/255), blue: CGFloat(pixelData.b/255), alpha: CGFloat(pixelData.a/255))
    }
}
struct PixelData:Equatable {
    var a: UInt8 = 0
    var r: UInt8 = 0
    var g: UInt8 = 0
    var b: UInt8 = 0
    
    public static func ==(lhs: PixelData, rhs: PixelData) -> Bool{
        return
            lhs.a == rhs.a &&
                lhs.r == rhs.r &&
                lhs.g == rhs.g &&
                lhs.b == rhs.b
    }
    
    init(a: UInt8, r: UInt8, g: UInt8, b: UInt8) {
        self.a = a
        self.r = r
        self.g = g
        self.b = b
        
    }
    init(color: UIColor) {
        var comps = [color.components.alpha * 255,color.components.red * 255,color.components.green * 255,color.components.blue * 255]
        for i in 0..<comps.count {
            if comps[i] > 255 {
                comps[i] = 255
            }
        }
        self.init(a: UInt8(comps[0]), r: UInt8(comps[1]), g: UInt8(comps[2]), b: UInt8(comps[3]))
    }
}

//get image from pixel data
extension Array where Element == PixelData{
    func imageFromBitmap(width: Int, height: Int) -> UIImage? {
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let bitsPerComponent:UInt = 8
        let bitsPerPixel:UInt = 32
        
        assert(self.count == Int(width * height))
        
        var data = self // Copy to mutable []
        let providerRef = CGDataProvider(
            data: NSData(bytes: &data, length: data.count * MemoryLayout<PixelData>.size)
        )
        
        let cgim = CGImage(
            width: width,
            height: height,
            bitsPerComponent: Int(bitsPerComponent),
            bitsPerPixel: Int(bitsPerPixel),
            bytesPerRow: Int(UInt(width) * UInt(MemoryLayout<PixelData>.size)),
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef!,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent
        )
        return UIImage(cgImage: cgim!)
    }
    
}


//easier color component information
extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }
}
