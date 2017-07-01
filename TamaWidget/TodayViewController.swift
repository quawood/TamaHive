//
//  TodayViewController.swift
//  TamaWidgetsu
//
//  Created by Qualan Woodard on 6/26/17.
//  Copyright © 2017 Qualan Woodard. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreGraphics
class TodayViewController: UIViewController, NCWidgetProviding {
    
    var context = CoreDataStack.sharedInstance.managedObjectContext
    var sceneEntities: [TamaSceneEntity]! = []
    var currentScene: TamaSceneEntity!
    

    var goToAppB: UIButton!
    var hungerView: UIView!
    var sceneView: UIView!
    var timer: Timer!
    func getScenes() -> [TamaSceneEntity] {
        var entities: [TamaSceneEntity]! = []
        do {
            entities = try context.fetch(TamaSceneEntity.fetchRequest())
        }catch {
            print("Error fetching data from CoreData")
        }
        return entities
    }
    
    
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("\(nserror.localizedDescription)")
            }
        }
    }
    
    @objc func openContainingApp(_ sender: Any) {
        extensionContext?.open(URL(string: "tamahivemain://")! , completionHandler: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        context = CoreDataStack.sharedInstance.managedObjectContext
        sceneView = UIView(frame: self.view.frame)
        hungerView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 156, height: 11)))
        goToAppB = UIButton(frame: CGRect(origin: self.view.center, size: CGSize(width: 156, height: 30)))
        goToAppB.addTarget(self, action: #selector(openContainingApp(_:)), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(sceneView)
        sceneView.addSubview(hungerView)
        self.view.addSubview(goToAppB)
        goToAppB.isHidden = true
        
        sceneEntities = getScenes()
        if sceneEntities.count > 0 {
            if let slInd = UserDefaults(suiteName: "group.Anjour.TamaHive")!.object(forKey: "spotlightInd") as? Int {
                currentScene = sceneEntities.first(where: {$0.id == Int16(slInd)})!
            } else {
                currentScene = sceneEntities[0]
            }
            
            setupTamagotchis()
            giveHunger()
        } else {
            sceneView.backgroundColor = UIColor.clear
            goToAppB.isHidden = false
            
        }
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateTamagotchis(_:)), userInfo: nil, repeats: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
        timer.invalidate()
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



