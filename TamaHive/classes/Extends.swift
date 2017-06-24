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


//size initializer for sprite nodes
extension SKSpriteNode {
    convenience init(textureNamed: String, scale: Int) {
        let texture1 = SKTexture(imageNamed: textureNamed)
        let newSize = CGSize(width: scale * Int(texture1.size().width), height: scale*Int(texture1.size().height))
        self.init(texture: texture1, color: UIColor.white, size:newSize)
    }
}

extension Int {
    func sign() -> Int {
        return (self < 0 ? -1 : 1)
    }
    /* or, use signature: func sign() -> Self */
}
extension CGFloat {
    func sign() -> Int {
        return (self < 0 ? -1 : 1)
    }
}


import SpriteKit

class FTButtonNode: SKSpriteNode {
    var action: () -> () = {}
    enum FTButtonActionType: Int {
        case TouchUpInside = 1,
        TouchDown, TouchUp
    }
    
    var isEnabled: Bool = true {
        didSet {
            if (disabledTexture != nil) {
                texture = isEnabled ? defaultTexture : disabledTexture
            }
        }
    }
    var isSelected: Bool = false {
        didSet {
            texture = isSelected ? selectedTexture : defaultTexture
        }
    }
    
    var defaultTexture: SKTexture
    var selectedTexture: SKTexture
    var label: SKLabelNode
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(normalTexture defaultTexture: SKTexture!, selectedTexture:SKTexture!, disabledTexture: SKTexture?) {
        
        self.defaultTexture = defaultTexture
        self.selectedTexture = selectedTexture
        self.disabledTexture = disabledTexture
        self.label = SKLabelNode(fontNamed: "Helvetica");
        
        super.init(texture: defaultTexture, color: UIColor.white, size: defaultTexture.size())
        isUserInteractionEnabled = true
        
        //Creating and adding a blank label, centered on the button
        self.label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center;
        self.label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center;
        addChild(self.label)
        
        // Adding this node as an empty layer. Without it the touch functions are not being called
        // The reason for this is unknown when this was implemented...?
        let bugFixLayerNode = SKSpriteNode(texture: nil, color: UIColor.clear, size: defaultTexture.size())
        bugFixLayerNode.position = self.position
        addChild(bugFixLayerNode)
        
    }
    
    /**
     * Taking a target object and adding an action that is triggered by a button event.
     */
    func setButtonAction(target: AnyObject, triggerEvent event:FTButtonActionType, action:Selector) {
        
        switch (event) {
        case .TouchUpInside:
            targetTouchUpInside = target
            actionTouchUpInside = action
        case .TouchDown:
            targetTouchDown = target
            actionTouchDown = action
        case .TouchUp:
            targetTouchUp = target
            actionTouchUp = action
        }
        
    }
    
    /*
     New function for setting text. Calling function multiple times does
     not create a ton of new labels, just updates existing label.
     You can set the title, font type and font size with this function
     */
    
    func setButtonLabel(title: NSString, font: String, fontSize: CGFloat) {
        self.label.text = title as String
        self.label.fontSize = fontSize
        self.label.fontName = font
    }
    
    var disabledTexture: SKTexture?
    var actionTouchUpInside: Selector?
    var actionTouchUp: Selector?
    var actionTouchDown: Selector?
    weak var targetTouchUpInside: AnyObject?
    weak var targetTouchUp: AnyObject?
    weak var targetTouchDown: AnyObject?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!isEnabled) {
            return
        }
        isSelected = true
        if (targetTouchDown != nil && targetTouchDown!.responds(to: actionTouchDown)) {
            UIApplication.shared.sendAction(actionTouchDown!, to: targetTouchDown, from: self, for: nil)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (!isEnabled) {
            return
        }
        
        let touch: AnyObject! = touches.first
        let touchLocation = touch.location(in: parent!)
        
        if (frame.contains(touchLocation)) {
            isSelected = true
        } else {
            isSelected = false
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!isEnabled) {
            return
        }
        
        isSelected = false
        
        if (targetTouchUpInside != nil && targetTouchUpInside!.responds(to: actionTouchUpInside!)) {
            let touch: AnyObject! = touches.first
            let touchLocation = touch.location(in: parent!)
            
            if (frame.contains(touchLocation) ) {
                UIApplication.shared.sendAction(actionTouchUpInside!, to: targetTouchUpInside, from: self, for: nil)
            }
            
        }
        
        if (targetTouchUp != nil && targetTouchUp!.responds(to: actionTouchUp!)) {
            UIApplication.shared.sendAction(actionTouchUp!, to: targetTouchUp, from: self, for: nil)
        }
    }
    
}


extension Date {
    
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
}
extension TamasScene {
    func generateRandomTama(_ n: Int, appendingPC: String) -> [String] {
        let appends:[String] = appendingPC.components(separatedBy: ",")
        var tamas: [String]! = []
        var resourcePath = NSURL(string: Bundle.main.resourcePath!)?.appendingPathComponent("tamahive.bundle")?.appendingPathComponent("tamas")
        appends.forEach({
            resourcePath?.appendPathComponent($0)
        })
        let resourcesContent = try! FileManager().contentsOfDirectory(at: resourcePath!, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
        
        for url in resourcesContent {
            tamas.append(url.lastPathComponent)
            
        }
        var returnArray: [String] = []
        for _ in 0..<n {
            let randInd = arc4random_uniform(UInt32(tamas.count))
            returnArray.append(tamas[Int(randInd)])
        }
        
        return returnArray
        
    }
    
    func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
        
        /*return UIColor(red:   .random() + 0.6,
                       green: .random() + 0.6,
                       blue:  .random() + 0.8,
                       alpha: 1.0)*/
    }
    
    
}

extension CGFloat {
    static func random() -> CGFloat {
        let ret = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return ret
    }
}
extension Array where Element: Collection, Element.Index == Int {
    func countFromLeft(_ index: Int) -> (Any, [Any]){
        var holder = [Any]()
        for i in 0..<self.count {
            for j in self[i] {
                holder.append(j)
            }
        }
        return (holder[index] as Any, holder)
    }
    
    func count() -> Int {
        return (countFromLeft(1).1.count)
    }
    
    func rowedIndex(_ i: Int) -> (Any, Int, Int){
        let f = i / (Int(self[0].count))
        let s = i % (Int(self[0].count))
        return (self[f][s], f, s)
    }
    
    
}




extension Array where Element == CGRect{
    func anyContains(_ point: CGPoint) -> Bool {
        var doAnyContain = false
        print(point)
        self.forEach({rect in
            if rect.contains(point) {
                doAnyContain = true
                
            }
            
        })
        return doAnyContain
    }
}

