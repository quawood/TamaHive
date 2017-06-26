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
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        
        // 4
        let modelURL = Bundle.main.url(forResource: "TamaHive", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    
    lazy var persistentContainer:PersistentContainer = {
        let container = PersistentContainer(name: "TamaHive", managedObjectModel: CoreDataStack.sharedInstance.managedObjectModel)
        container.loadPersistentStores(completionHandler: { (storeDescription:NSPersistentStoreDescription, error:Error?) in
            if let error = error as NSError?{
                fatalError("UnResolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    func saveContext () {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.localizedDescription)")
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


