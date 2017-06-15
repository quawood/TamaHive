//
//  Extends.swift
//  TamaHive
//
//  Created by Qualan Woodard on 6/9/17.
//  Copyright 2017 Qualan Woodard. All rights reserved.
//

import Foundation
import UIKit
extension CGImage {
    var colors: ([UInt8], [PixelData])? {
        
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
extension UIImage {
    func resizeImage(scale: CGFloat) -> UIImage {
        
        let newWidth = scale * self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}
struct PixelData {
    var a: UInt8 = 0
    var r: UInt8 = 0
    var g: UInt8 = 0
    var b: UInt8 = 0
}


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


extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }
}
