//
//  CoreDataStack.swift
//  TamaWidget
//
//  Created by Qualan Woodard on 6/26/17.
//  Copyright © 2017 Qualan Woodard. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    // 1
    static let sharedInstance = CoreDataStack()
    
    // 2
    // private init -> prevent multiple instances
    private init() {}
    
    // 3
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TamaHive")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
}


class PersistentContainer: NSPersistentContainer{
    override class func defaultDirectoryURL() -> URL{
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.Anjour.TamaHive")!
    }
    
    override init(name: String, managedObjectModel model: NSManagedObjectModel) {
        super.init(name: name, managedObjectModel: model)
    }
}

