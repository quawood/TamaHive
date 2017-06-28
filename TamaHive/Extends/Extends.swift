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




// Tramslate between string and point
extension String {
    func toPoint() -> CGPoint{
        let stringARray = self.components(separatedBy: ",")
        let point = CGPoint(x:Int(stringARray[0])!, y:Int(stringARray[1])!)
        return point
    }
}

extension CGPoint {
    func toString() -> String {
        return "\(Int(self.x)),\(Int(self.y))"
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







extension Date {
    
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
}


extension CGFloat {
    static func random() -> CGFloat {
        let ret = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return ret/36
        
    }
    static func randomoz() -> CGFloat {
        var random = Int(arc4random_uniform(2))
        random = (random * 2) + 1
        return CGFloat(random)
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
        self.forEach({rect in
            if rect.contains(point) {
                doAnyContain = true
                
            }
            
        })
        return doAnyContain
    }
}


