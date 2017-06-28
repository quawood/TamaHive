//
//  Image+.swift
//  TamaHive
//
//  Created by Qualan Woodard on 6/28/17.
//  Copyright © 2017 Qualan Woodard. All rights reserved.
//

import Foundation
import UIKit
import GameKit
import SpriteKit

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

//resize image
extension UIImage {
    func resizeImage(scale: CGFloat) -> (UIImage) {
        let scale = scale/2
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
