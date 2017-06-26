//
//  TodayViewController.swift
//  TamaWidget
//
//  Created by Qualan Woodard on 6/26/17.
//  Copyright © 2017 Qualan Woodard. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreGraphics
class TodayViewController: UIViewController, NCWidgetProviding {
    
    let context = CoreDataStack.sharedInstance.managedObjectContext
    var sceneEntities: [TamaSceneEntity]! = []
    var currentScene: TamaSceneEntity!
    
    @IBOutlet weak var goToAppB: UIButton!
    @IBAction func goToAppButton(_ sender: Any) {
        openContainingApp()
    }
    @IBOutlet weak var hungerView: UIView!
    @IBOutlet weak var sceneView: UIView!
    
    func getScenes() -> [TamaSceneEntity] {
        var entities: [TamaSceneEntity]! = []
        do {
            entities = try context.fetch(TamaSceneEntity.fetchRequest())
        }catch {
            print("Error fetching data from CoreData")
        }
        print (entities.count)
        return entities
    }
    
    
    
    func save() {
        if context.hasChanges {
            do {
                try CoreDataStack.sharedInstance.saveContext()
            } catch {
                let nserror = error as NSError
                print("\(nserror.localizedDescription)")
            }
        }
    }
    
    func openContainingApp() {
        extensionContext?.open(URL(string: "tamahivemain://")! , completionHandler: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goToAppB.isHidden = true
        
        sceneEntities = getScenes()
        if sceneEntities.count > 0 {
            currentScene = sceneEntities[0]
            setupTamagotchis()
            giveHunger()
        } else {
            sceneView.backgroundColor = UIColor.clear
            goToAppB.isHidden = false
            
        }
        
        var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(moveTamagotchis(_:)), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}



