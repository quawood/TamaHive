//
//  TAttributes.swift
//  TamaWidget
//
//  Created by Qualan Woodard on 6/26/17.
//  Copyright © 2017 Qualan Woodard. All rights reserved.
//

import Foundation
import UIKit
class TAttributes {
    
    static let marriageAge: Int! = 8
    static let leaveAge: Int! = 6
    static let childAge: Int! = 10
    static let tunit: Calendar.Component! = .second
    static let tint: Int! = 1
    static let maxHealth: Int! = 5
    
    static let maxTamas: Int! = 5
    
    static var sceneEntites: [TamaSceneEntity]! = []
    static let familyNames = ["mame","meme","kuchi","large","ninja","secret","small","space","violet"]
    static let forms = ["baby","toddler","teen","adult","parents"]
    static let colors  = [
        UIColor(red: 242/255, green: 210/255, blue: 193/255, alpha: 1),
        UIColor(red: 224/255, green: 195/255, blue: 195/255, alpha: 1),
        UIColor(red: 152/255, green: 182/255, blue: 177/255, alpha: 1),
        UIColor(red: 133/255, green: 179/255, blue: 184/255, alpha: 1),
        UIColor(red: 80/255, green: 88/255, blue: 112/255, alpha: 1),
        
    ]
    private init() {
        
    }
    
   static func generateRandomTama(_ n: Int, appendingPC: String) -> [String] {
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
    
    
}
