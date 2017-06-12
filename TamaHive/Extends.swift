//
//  Extends.swift
//  TamaHive
//
//  Created by Qualan Woodard on 6/9/17.
//  Copyright © 2017 Qualan Woodard. All rights reserved.
//

import Foundation
import UIKit
extension CGImage {
    var colors: [UIColor]? {
        
        var colors = [UIColor]()
        
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
        
        for x in 0..<width {
            for y in 0..<height {
                let byteIndex = 4*((width * y) + x)
                
                let red = CGFloat(rawData[byteIndex]) / 255.0
                let green = CGFloat(rawData[byteIndex + 1]) / 255.0
                let blue = CGFloat(rawData[byteIndex + 2]) / 255.0
                let alpha = CGFloat(rawData[byteIndex + 3]) / 255.0
                
                let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                colors.append(color)
            }
        }
        
        
        /*for l in 0..<(width * height) {
            let byteIndex = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
            
            let red = CGFloat(rawData[byteIndex]) / 255.0
            let green = CGFloat(rawData[byteIndex + 1]) / 255.0
            let blue = CGFloat(rawData[byteIndex + 2]) / 255.0
            let alpha = CGFloat(rawData[byteIndex + 3]) / 255.0
            
            let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            colors.append(color)
        }*/
        
        return colors
    }
}

