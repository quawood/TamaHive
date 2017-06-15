//
//  Extends.swift
//  TamaHive
//
//  Created by Qualan Woodard on 6/9/17.
//  Copyright 2017 Qualan Woodard. All rights reserved.
//

import Foundation
import UIKit
import GameKit
import SpriteKit
//get pixel data from image
extension CGImage {
    var colors: ([UInt8], [PixelData])? {
        let scale = 4
        var coloredRawData = [PixelData]()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let cgImage = self
            
        
        
        var rawData = [UInt8](repeating: 0, count: width * height * 4)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bytesPerComponent = 8
        
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        let context = CGContext(data: &rawData,
                                width: width,
                                height: height,
                                bitsPerComponent: bytesPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo)
        
        let drawingRect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        context?.draw(cgImage, in: drawingRect)
        //var testArray = [UInt8]()
        
        //rawData = testArray
        let l = width * height
        var holderArray = [PixelData](repeating: PixelData(a: 0, r: 0, g: 0, b: 0), count: l)
        var count = 0
        for x in 0..<width {
            for y in 0..<height {
                let byteIndex = 4*((width * y) + x)
                let ppixel = PixelData(a: rawData[byteIndex + 3], r: rawData[byteIndex], g: rawData[byteIndex + 1], b: rawData[byteIndex + 2])
                coloredRawData.append(ppixel)
                
                let index =  (count % height)*width+(count / height)
                let pixel = coloredRawData[count]
                
                holderArray[index] = pixel
                count += 1
            }
            
        }
        
        coloredRawData = holderArray
        return (rawData, holderArray)
    }
    
    
    
}

//resize image
extension UIImage {
    func resizeImage(scale: CGFloat) -> (UIImage) {
        let newSize = CGSize(width: scale * self.size.width, height: scale * self.size.height)
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // Set the quality level to use when rescaling
        context!.interpolationQuality = CGInterpolationQuality.none
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
        
        context!.concatenate(flipVertical)
        // Draw into the context; this scales the image
        context?.draw(self.cgImage!, in: CGRect(x: 0.0,y: 0.0, width: newRect.width, height: newRect.height))
        
        let newImageRef = context!.makeImage()! as CGImage
        let newImage = UIImage(cgImage: newImageRef)
        
        // Get the resized image from the context and a UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

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
        self.init(a: UInt8(color.components.alpha * 255), r: UInt8(color.components.red * 255), g: UInt8(color.components.green * 255), b: UInt8(color.components.blue * 255))
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


//size initializer for sprite nodes
extension SKSpriteNode {
    convenience init(textureNamed: String, scale: Int) {
        let texture1 = SKTexture(imageNamed: textureNamed)
        let newSize = CGSize(width: scale * Int(texture1.size().width), height: scale*Int(texture1.size().height))
        self.init(texture: texture1, color: UIColor.white, size:newSize)
        
    }
}

