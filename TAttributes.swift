//
//  TAttributes.swift
//  TamaWidget
//
//  Created by Qualan Woodard on 6/26/17.
//  Copyright © 2017 Qualan Woodard. All rights reserved.
//

import Foundation

class TAttributes {
    
    static let marriageAge: Int! = 8
    static let leaveAge: Int! = 6
    static let childAge: Int! = 10
    static let tunit: Calendar.Component! = .second
    static let tint: Int! = 5
    static let maxHealth: Int! = 5
    
    static let maxTamas: Int! = 10
    
    static var sceneEntites: [TamaSceneEntity]! = []
    static let familyNames = ["mame","meme","kuchi","large","ninja","secret","small","space","violet"]
    static let forms = ["baby","toddler","teen","adult","parents"]
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
